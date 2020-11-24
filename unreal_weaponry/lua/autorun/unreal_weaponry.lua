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

function Unreal.FireBullets(firebulletsinfo)
	if (SERVER) then
		for idx, player in next, player.GetAll() do
			if (player == firebulletsinfo.owner || player:IsBot()) then
				continue;
			end

			Unreal.SendBullet(player, firebulletsinfo);
		end

		return;
	end

	if (!IsFirstTimePredicted()) then
		return;
	end

	table.insert(bullets, firebulletsinfo);
end

if (SERVER) then
	util.AddNetworkString("unreal_networkbullets");

	function Unreal.SendBullet(player, bullet)
		net.Start("unreal_networkbullets", false);
		net.WriteTable(bullet);
		net.Send(player);
	end
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

	function Unreal.BulletTrace(player, from, to)
		return util.TraceLine({
			start	= from,
			endpos	= to;
			filter	= player,
			mask	= MASK_SHOT
		});
	end

	function Unreal.BulletMoveSolid()

	end

	function Unreal.TryBulletMove(bullet, pos, dest)
		local trace = Unreal.BulletTrace(bullet.owner, pos, dest);
		if (trace.Fraction != 1) then
			bullet.owner:FireBullets({
				Src = trace.StartPos,
				Dir = trace.Normal,
				Damage = 0,
				Force = 0,
				Tracer = 0
			});

			return false;
		end

		bullet.origin = trace.HitPos;
		return true;
	end

	function Unreal.BulletSimulate(index, bulletinfo)
		local currentpos		= bulletinfo.origin;
		local currentvel		= bulletinfo.velocity * UNITS_PER_METER;
		local simulationtime	= bulletinfo.simulationtime;
		local deltatime			= 1 / BULLET_DEBUG_TICKRATE;

		-- Precompute the next origin of the bullet.
		local dragforce		= 0.5 * currentvel:LengthSqr() * bulletinfo.frontalarea * bulletinfo.dragcoefficient * UNREAL_AIR_DENSITY;
		local dragvector	= currentvel:GetNormalized() * dragforce * deltatime;
		local gravityvector	= physenv.GetGravity() * bulletinfo.mass;
		local acceleration	= (gravityvector - dragvector) / bulletinfo.mass;
		local nextvelocity	= currentvel + acceleration * deltatime;
		local nextorigin	= currentpos + nextvelocity * deltatime;

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
		for idx, bullet in next, bullets do
			local renderorigin = bullet.origin;
			local haha = bullet.velocity:GetNormalized() * bullet.caliber * 16;
			local frontsize = bullet.caliber;

			render.SetMaterial(BULLET_TRACER_MAT_FRONT);
			render.DrawSprite(renderorigin + haha, frontsize, frontsize, color_white);

			render.SetMaterial(BULLET_TRACER_MAT_BODY);
			render.DrawBeam(renderorigin, renderorigin + haha, bullet.caliber * 2, 0, 1, color_white);
		end
	end

	hook.Add("Think", "unreal_weaponry", Unreal.HandleBullets);
	hook.Add("PostDrawOpaqueRenderables", "unreal_weaponry", Unreal.BulletRender);
end