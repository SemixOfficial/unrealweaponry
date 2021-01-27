resource.AddFile("materials/effects/bullet_tracer.vmt");

UNITS_PER_FEET			= 16;
UNITS_PER_METER			= 39.3700787;
FEET_PER_METER			= 3.2808399;
GRAMS_PER_KILOGRAM		= 1000;
MILIMETERS_PER_INCH		= 0.0393700787;

UNREAL_AMMO_SPECIAL_NONE		= 0;
UNREAL_AMMO_SPECIAL_INCENDARY	= 1;
UNREAL_AMMO_SPECIAL_FRAG		= 2;
UNREAL_AMMO_SPECIAL_COUNT		= 3;

UNREAL_AIR_DENSITY	=  0.00237; -- slug/ft3

Unreal = {};
Unreal.CurrentTime = 0;
local bullets = {};
local m_hLastUnrealWeapon = nil;

function Unreal.FireBullets(firebulletsinfo)
	if (SERVER) then
		for idx, player in next, player.GetAll() do
			if (player == firebulletsinfo.owner || player:IsBot()) then
				continue;
			end

			Unreal.SendBullet(player, firebulletsinfo);
		end

		m_hLastUnrealWeapon = firebulletsinfo.owner:GetActiveWeapon();
		return;
	end

	if (!IsFirstTimePredicted()) then
		return;
	end

	table.insert(bullets, 1, firebulletsinfo);
	Unreal.BulletSimulate(1, bullets[1]);
end

if (SERVER) then
	util.AddNetworkString("unreal_networkbullets");
	util.AddNetworkString("unreal_networkhits");

	function Unreal.SendBullet(player, bullet)
		net.Start("unreal_networkbullets", false);
		net.WriteTable(bullet);
		net.Send(player);
	end

	net.Receive("unreal_networkhits", function(length, player)
		if (!IsValid(m_hLastUnrealWeapon) || !m_hLastUnrealWeapon.IsUnreal) then
			-- Not a valid weapon.
			return;
		end

		local weapon			= m_hLastUnrealWeapon;
		local damagepos			= net.ReadVector();
		local damagevec			= net.ReadVector():GetNormalized();
		local terminalvelocity	= math.min(net.ReadFloat(), weapon.MuzzleVelocity);
		local damageforce		= (weapon.ProjectileMass / 10) * terminalvelocity;
		local hitgroup			= net.ReadInt(8);
		local victim			= net.ReadEntity();
		local dmginfo			= DamageInfo();

		if (!IsValid(victim)) then
			return;
		end

		dmginfo:SetAmmoType(game.GetAmmoID(weapon.AmmoType));
		dmginfo:SetAttacker(player);
		dmginfo:SetBaseDamage(weapon.Damage);
		dmginfo:SetDamage(weapon.Damage);
		dmginfo:SetDamageBonus(0);
		--dmgInfo:SetDamageCustom(DMG_UNREAL_BULLET);
		dmginfo:SetDamageForce(damagevec * damageforce);
		dmginfo:SetDamagePosition(damagepos);
		dmginfo:SetDamageType(DMG_BULLET);
		dmginfo:SetInflictor(weapon);

		if (victim:IsPlayer()) then
			hook.Run("ScalePlayerDamage", victim, hitgroup, dmginfo);
		elseif (victim:IsNPC() || victim:IsNextBot()) then
			hook.Run("ScaleNPCDamage", victim, hitgroup, dmginfo);
		end

		victim:TakeDamageInfo(dmginfo);
	end);
end

if (CLIENT) then
	local BULLET_DEBUG_TICKRATE = 144;
	local BULLET_DIST_MAXSOLID = 90; -- Max distance bullet can travel through solid walls.
	local BULLET_TRACER_MAT_BODY = Material("effects/bullet_tracer");
	local BULLET_TRACER_MAT_FRONT = Material("effects/yellowflare");

	net.Receive("unreal_networkbullets", function(length, player)
		local bulletinfo = net.ReadTable();
		bulletinfo.simulationtime = Unreal.CurrentTime;
		table.insert(bullets, bulletinfo);
	end);

	function Unreal.BulletTrace(ply, from, to)

		--[[
		for idx, entity in next, player.GetAll() do
			debugoverlay.Box(entity:GetPos(), entity:OBBMins(), entity:OBBMaxs(), 0.1, Color(0, 255, 0, 0));

			for hitboxset = 0, entity:GetHitboxSetCount() - 1 do
				for hitbox = 0, entity:GetHitBoxCount(hitboxset) - 1 do
					local bone = entity:GetHitBoxBone(hitbox, hitboxset);
					local matrix = entity:GetBoneMatrix(bone);

					if (!matrix) then
						continue; end

					local pos = matrix:GetTranslation();
					local ang = matrix:GetAngles();
					local mins, maxs = entity:GetHitBoxBounds(hitbox, hitboxset);
					debugoverlay.BoxAngles(pos, mins, maxs, ang, 0.1, Color(255, 0, 0, 0));
				end
			end
		end
		]]--

		return util.TraceLine({
			start	= from,
			endpos	= to;
			filter	= ply,
			mask	= MASK_SHOT
		});
	end

	function Unreal.BulletMoveSolid()

	end

	function Unreal.HandleBulletImpact(trace, bullet)
		bullet.owner:FireBullets({
			Src = trace.StartPos,
			Dir = trace.Normal,
			Damage = 1,
			Force = 0,
			Tracer = 0
		});

		local effect = EffectData();
		effect:SetOrigin(trace.HitPos + trace.HitNormal);
		effect:SetNormal(trace.Normal);
		util.Effect("AR2Impact", effect);

		print("BulletImpact", trace.Entity, bullet.owner, LocalPlayer());
		if (IsValid(trace.Entity) && bullet.owner == LocalPlayer()) then
			net.Start("unreal_networkhits", false);
			net.WriteVector(trace.HitPos);
			net.WriteVector(trace.Normal * 10000); -- Compression sucks
			net.WriteFloat(bullet.velocity:Length());
			net.WriteInt(trace.HitGroup, 8);
			net.WriteEntity(trace.Entity);
			net.SendToServer();
		end
	end

	function Unreal.TryBulletMove(bullet, pos, dest)
		local trace = Unreal.BulletTrace(bullet.owner, pos, dest);
		if (trace.Fraction != 1 || trace.StartSolid) then
			Unreal.HandleBulletImpact(trace, bullet);

			return false;
		end

		bullet.lastorigin = bullet.origin;
		bullet.origin = trace.HitPos;
		return true;
	end

	function Unreal.BulletSimulate(index, bulletinfo)
		local currentpos		= bulletinfo.origin;
		local currentvel		= bulletinfo.velocity * UNITS_PER_METER;
		local simulationtime	= bulletinfo.simulationtime;
		local deltatime			= 1 / BULLET_DEBUG_TICKRATE;

		-- Precompute the new origin and velocity of the bullet.
		local dragforce		= 0.5 * currentvel:LengthSqr() * bulletinfo.frontalarea * bulletinfo.dragcoefficient * UNREAL_AIR_DENSITY;
		local dragvector	= currentvel:GetNormalized() * dragforce * deltatime;
		local gravityvector	= physenv.GetGravity() * bulletinfo.mass;
		local acceleration	= (gravityvector - dragvector) / bulletinfo.mass;
		local nextvelocity	= currentvel + acceleration * deltatime;
		local nextorigin	= currentpos + nextvelocity * deltatime;

		-- Try moving the bullet to the new position.
		if (!Unreal.TryBulletMove(bulletinfo, currentpos, nextorigin)) then
			return false;
		end

		bulletinfo.velocity = nextvelocity / UNITS_PER_METER;
		bulletinfo.simulationtime = simulationtime + deltatime;
		return true;
	end


	function Unreal.HandleBullets()
		Unreal.CurrentTime = CurTime();

		for idx, bullet in next, bullets do
			while (Unreal.CurrentTime >= bullet.simulationtime) do
				if (!Unreal.BulletSimulate(idx, bullet)) then
					table.remove(bullets, idx);
					break;
				end
			end
		end
	end

	function Unreal.BulletRender()
		local currenttime = CurTime();
		local tickinterval = (1 / BULLET_DEBUG_TICKRATE);

		for idx, bullet in next, bullets do
			local interp = 1 - (bullet.simulationtime - currenttime) / tickinterval
			if (interp > 1) then
				interp = 1;
			end

			local renderorigin = LerpVector(interp, bullet.lastorigin, bullet.origin);
			local haha = bullet.velocity:GetNormalized() * bullet.length * 2;
			local frontsize = bullet.caliber;

			render.SetMaterial(BULLET_TRACER_MAT_FRONT);
			render.DrawSprite(renderorigin + haha, frontsize, frontsize, color_white);

			render.SetMaterial(BULLET_TRACER_MAT_BODY);
			render.DrawBeam(renderorigin, renderorigin + haha, bullet.caliber, 0, 1, color_white);
		end
	end

	hook.Add("Think", "unreal_weaponry", Unreal.HandleBullets);
	hook.Add("PostDrawOpaqueRenderables", "unreal_weaponry", Unreal.BulletRender);
end