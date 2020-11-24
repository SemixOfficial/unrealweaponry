AddCSLuaFile();
DEFINE_BASECLASS("weapon_base");

SWEP.Spawnable	= false;
SWEP.UseHands	= true;
SWEP.DrawAmmo	= true;
SWEP.Category	= "Unreal Weaponry";
SWEP.IsUnreal	= true;

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "Inaccuracy", nil);
	self:NetworkVar("Float", 2, "NextIdleTime", nil);
	self:NetworkVar("Int", 1, "SpreadRandomSeed", nil);
	self:NetworkVar("Int", 2, "SpecialAmmoType", nil);
	self:NetworkVar("Int", 3, "SpecialAmmoCount", nil);
end

function SWEP:Initialize()
	self:SetSpreadRandomSeed(0);
	self:SetHoldType(self.HoldType);

	--[[
	if (CLIENT) then
		local class = self:GetClass();
		if (!killicon.Exists(class) && self.UsesFontIcons) then
			killicon.AddFont(class, self.KillFont, self.KillIcon, Color(255, 80, 0, 255));
		else
			killicon.Add(class, self.KillIcon, Color(255, 80, 0, 255));
		end
	end
	]]--

	-- TODO: This is bad.
	self.Primary.ClipSize		= self.ClipSize;
	self.Primary.Ammo			= "smg1";
	self.Primary.DefaultClip	= self.ClipSize * 3;
	self.Primary.Automatic		= true;
	self.Secondary = nil;
end

function SWEP:Reload()
	self:SetInaccuracy(0);
	BaseClass.Reload(self);
end

function SWEP:GetCone()
	local owner = self:GetOwner();
	local speed = owner:GetAbsVelocity():Length2D();
	local frac = speed / owner:GetWalkSpeed();
	-- Normalize the fraction to steps of 0.1 to make it less jittery.
	frac = 0.1 * math.ceil(frac / 0.1);
	local inaccuracyMove = frac * self.InaccuracyMove;

	local baseInaccuracy = self.InaccuracyStand;
	if (owner:Crouching() && owner:IsFlagSet(FL_ONGROUND)) then
		baseInaccuracy = self.InaccuracyCrouch;
	end

	return math.rad(baseInaccuracy + self:GetInaccuracy() + inaccuracyMove);
end

-- https://developer.valvesoftware.com/wiki/CShotManipulator
function SWEP:GetSpreadVector(direction, inaccuracy)
	local heading	= direction:Angle();
	local right		= heading:Right();
	local up		= heading:Up();

	math.randomseed(math.random(0, 0x7FFFFFFF));

	local radius	= math.Rand(0, 1) * math.Rand(0.5, 1);
	local theta		= math.Rand(0, math.rad(360));
	-- Convert to cartesian (X/Y) coordinates
	local x = radius * math.sin(theta);
	local y = radius * math.cos(theta);

	return direction + x * inaccuracy * right + y * inaccuracy * up;
end

function SWEP:UpdateInaccuracy()
	local recoveryTime = self.RecoveryTimeStand;

	local inaccuracyDecay = (self.InaccuracyMax / recoveryTime) * FrameTime();
	self:SetInaccuracy(math.max(self:GetInaccuracy() - inaccuracyDecay, 0));
end

function SWEP:IdleThink()
	if (CurTime() <= self:GetNextIdleTime()) then
		return;
	end

	self:SendWeaponAnim(ACT_VM_IDLE);
	self:SetNextIdleTime(CurTime() + self:SequenceDuration());
end


function SWEP:Think()
	self:IdleThink();
	self:UpdateInaccuracy();
end

function SWEP:GetBulletInfo()
	local owner			= self:GetOwner();
	local aimdir		= (owner:GetAimVector():Angle() + owner:GetViewPunchAngles()):Forward();
	local shotdir		= self:GetSpreadVector(aimdir, self:GetCone());
	local velocity		= (shotdir * self.MuzzleVelocity) + (owner:GetVelocity() / UNITS_PER_METER);
	local frontalarea	= math.pi * ((0.5 * (self.Caliber * MILIMETERS_PER_INCH)) ^ 2);
	local info			= {};

	info.owner		= owner;
	info.origin		= owner:GetShootPos();
	info.velocity	= velocity;
	info.mass		= self.ProjectileMass / GRAMS_PER_KILOGRAM;
	info.caliber	= self.Caliber;
	info.frontalarea	= frontalarea;
	info.dragcoefficient= 0.04;
	info.simulationtime	= Unreal.CurrentTime;

	return info;
end

function SWEP:PrimaryAttack()
	if (!self:CanPrimaryAttack()) then
		return;
	end

	-- We have to do this mess to make firerate framerate independent lol.
	local shots = 0;
	local seed = self:GetSpreadRandomSeed();
	local owner = self:GetOwner();
	local cycletime = (60 / self.CycleRate);
	self:SetNextPrimaryFire(CurTime() - engine.TickInterval());
	while (self:GetNextPrimaryFire() <= CurTime()) do
		shots = shots + 1;
		self:SetNextPrimaryFire(self:GetNextPrimaryFire() + cycletime);
	end

	owner:MuzzleFlash();
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
	self:SetSpreadRandomSeed(math.fmod(seed + 1, 0x7FFFFFFF));
	owner:SetAnimation(PLAYER_ATTACK1);
	math.randomseed(seed);
	shots = math.min(shots, self:Clip1());

	for i = 1, shots do
		self:EmitSound(self.FireSound, 75, 100, 1, CHAN_WEAPON);
		self:SetInaccuracy(math.min(self:GetInaccuracy() + self.InaccuracyFire, self.InaccuracyMax));
		Unreal.FireBullets(self:GetBulletInfo());
	end
end

function SWEP:SecondaryAttack()

end

function SWEP:DoDrawCrosshair(x, y)
	local owner = LocalPlayer();
	if (!IsValid(owner) || !owner:Alive()) then
		return;
	end

	local spreadFov = math.deg(self:GetCone());
	local screenFov = 0.5 * math.deg(2 * math.atan((ScrW() / ScrH()) * (3 / 4) * math.tan(0.5 * math.rad(owner:GetFOV())))); --To calculate your actual fov based on your aspect ratio
	local srAngle = 180 - (90 + screenFov);
	local scrSide = ((0.5 * ScrW()) * math.sin(math.rad(srAngle))) / math.sin(math.rad(screenFov));
	local arAngle = 180 - (90 + spreadFov);
	local fixedFov = (scrSide * math.sin(math.rad(spreadFov))) / math.sin(math.rad(arAngle))
	local maxFov = math.sqrt(((0.5 * ScrW()) ^ 2) + ((0.5 * ScrH()) ^ 2));

	if (spreadFov > 0 && fixedFov <= maxFov && spreadFov <= owner:GetFOV()) then
		local eyeTrace = owner:GetEyeTrace();
		local gap = math.ceil(fixedFov);
		local color = Color(0, 255, 0, 255);
		local hitEntity = eyeTrace.Entity;
		if (IsValid(hitEntity) && (hitEntity:IsPlayer() || hitEntity:IsNPC() || hitEntity:IsNextBot())) then
			color = Color(255, 0, 0);
		end

		surface.SetDrawColor(Color(0, 0, 0, 205));
		surface.DrawRect(x - 1, y - 1, 3, 3);
		surface.DrawRect((x - 1) + gap, y - 1, 8, 3);
		surface.DrawRect((x - 1) - (5 + gap), y - 1, 8, 3);
		surface.DrawRect((x - 1), (y - 1) + gap, 3, 8);
		surface.DrawRect((x - 1), (y - 1) - (5 + gap), 3, 8);

		surface.SetDrawColor(color);
		surface.DrawRect(x, y, 1, 1);
		surface.DrawRect(x + gap, y, 6, 1);
		surface.DrawRect(x - (5 + gap), y, 6, 1);
		surface.DrawRect(x, y + gap, 1, 6);
		surface.DrawRect(x, y - (5 + gap), 1, 6);
	end

	return true;
end