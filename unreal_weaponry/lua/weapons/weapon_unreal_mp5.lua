DEFINE_BASECLASS("weapon_unreal_base");
SWEP.Spawnable = true;
SWEP.AdminOnly = false;

-- General weapon stuff.
-- Weapon name.
SWEP.PrintName = "H&K MP5";
-- Weapon category.
SWEP.Category = "Unreal Weaponry"
-- Slot
SWEP.Slot = 2;

-- Weapon appearance and sounds.
-- View model.
SWEP.ViewModel	= Model("models/weapons/v_smg_mp5.mdl");
-- World model.
SWEP.WorldModel = Model("models/weapons/w_smg_mp5.mdl");
-- Field of view of the viewmodel.
SWEP.ViewModelFOV = 78;
-- Changes if you are holding the gun left or right handed.
SWEP.ViewModelFlip = true;
-- How do you hold this gun?
SWEP.HoldType	= "smg";
-- This sound will be played when the gun is fired.
SWEP.FireSound	= "Weapon_MP5Navy.Single";

-- Weapon charachteristics
-- How many cycles per second this weapon can do, this is the delay between firing the gun again after shooting it.
SWEP.CycleRate	= 800;
-- How many bullets can fit in one magazine.
SWEP.ClipSize	= 30;
-- Initial or "raw" damage of the weapon at zero range against unarmored opponents.
SWEP.Damage		= 49;
-- Caliber lol idk what to say about this, it's just a fucking caliber, you know the word used to describe diameter of bullet.
SWEP.Caliber	= 9.02;
-- Velocity of bullet when it exists gun barrel, in meters per second.
SWEP.MuzzleVelocity		= 340;
-- Weight of the bullet (without shell casing obviously) in grams.
SWEP.ProjectileMass		= 7.5;
-- Base Inaccuracy of the weapon.
SWEP.InaccuracyStand    = 0.57;
-- Base Inaccuracy of the weapon when crouched.
SWEP.InaccuracyCrouch   = 0.49;
-- Inaccuracy from firing.
SWEP.InaccuracyFire	= 0.17;
-- Inaccuracy from movement.
SWEP.InaccuracyMove	= 0.67;
-- Max Inaccuracy from firing.
SWEP.InaccuracyMax	= 2.47;
-- How long does it take to regain max accuracy from max inaccuracy.
SWEP.RecoveryTimeStand  = 1.57;