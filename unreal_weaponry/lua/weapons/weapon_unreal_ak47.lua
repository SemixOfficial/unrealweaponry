DEFINE_BASECLASS("weapon_unreal_base");
SWEP.Spawnable = true;
SWEP.AdminOnly = false;

-- General weapon stuff.
-- Weapon name.
SWEP.PrintName = "AK-47";
-- Weapon category.
SWEP.Category = "Unreal Weaponry"
-- Slot
SWEP.Slot = 2;

-- Weapon appearance and sounds.
-- View model.
SWEP.ViewModel	= Model("models/weapons/v_rif_ak47.mdl");
-- World model.
SWEP.WorldModel = Model("models/weapons/w_rif_ak47.mdl");
-- Field of view of the viewmodel.
SWEP.ViewModelFOV = 78;
-- Changes if you are holding the gun left or right handed.
SWEP.ViewModelFlip = true;
-- How do you hold this gun?
SWEP.HoldType	= "ar2";
-- This sound will be played when the gun is fired.
SWEP.FireSound	= "Weapon_AK47.Single";

-- Weapon charachteristics
-- How many cycles per second this weapon can do, this is the delay between firing the gun again after shooting it.
SWEP.CycleRate	= 600;
-- How many bullets can fit in one magazine.
SWEP.ClipSize	= 30;
-- Initial or "raw" damage of the weapon at zero range against unarmored opponents.
SWEP.Damage		= 67;
-- Caliber lol idk what to say about this, it's just a fucking caliber, you know the word used to describe diameter of bullet.
SWEP.Caliber	= 7.62;
-- Velocity of bullet when it exists gun barrel, in meters per second.
SWEP.MuzzleVelocity		= 710;
-- Weight of the bullet (without shell casing obviously) in grams.
SWEP.ProjectileMass		= 9;
-- Base Inaccuracy of the weapon.
SWEP.InaccuracyStand    = 0.47;
-- Base Inaccuracy of the weapon when crouched.
SWEP.InaccuracyCrouch   = 0.39;
-- Inaccuracy from firing.
SWEP.InaccuracyFire	= 0.29;
-- Inaccuracy from movement.
SWEP.InaccuracyMove	= 0.77;
-- Max Inaccuracy from firing.
SWEP.InaccuracyMax	= 2.27;
-- How long does it take to regain max accuracy from max inaccuracy.
SWEP.RecoveryTimeStand  = 1.37;