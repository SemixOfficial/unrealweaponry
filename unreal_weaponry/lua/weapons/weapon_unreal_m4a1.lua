DEFINE_BASECLASS("weapon_unreal_base");
SWEP.Spawnable = true;
SWEP.AdminOnly = false;

-- General weapon stuff.
-- Weapon name.
SWEP.PrintName = "M4A1";
-- Weapon category.
SWEP.Category = "Unreal Weaponry"
-- Slot
SWEP.Slot = 2;

-- Weapon appearance and sounds.
-- View model.
SWEP.ViewModel	= Model("models/weapons/v_rif_m4a1.mdl");
-- World model.
SWEP.WorldModel = Model("models/weapons/w_rif_m4a1.mdl");
-- Field of view of the viewmodel.
SWEP.ViewModelFOV = 78;
-- Changes if you are holding the gun left or right handed.
SWEP.ViewModelFlip = true;
-- How do you hold this gun?
SWEP.HoldType	= "ar2";
-- This sound will be played when the gun is fired.
SWEP.FireSound	= "Weapon_M4A1.Single";

-- Weapon charachteristics
-- How many cycles per second this weapon can do, this is the delay between firing the gun again after shooting it.
SWEP.CycleRate	= 750;
-- How many bullets can fit in one magazine.
SWEP.ClipSize	= 30;
-- What ammo type does this weapon use?
SWEP.AmmoType	= "smg1";
-- Initial or "raw" damage of the weapon at zero range against unarmored opponents.
SWEP.Damage		= 39;
-- Caliber lol idk what to say about this, it's just a fucking caliber, you know the word used to describe diameter of bullet.
SWEP.Caliber	= 5.56;
-- Velocity of bullet when it exists gun barrel, in meters per second.
SWEP.MuzzleVelocity		= 930;
-- Weight of the bullet (without shell casing obviously) in grams.
SWEP.ProjectileMass		= 5.12;
-- Length of the bullet in milimeters.
SWEP.ProjectileLength	= 45;
-- Base Inaccuracy of the weapon.
SWEP.InaccuracyStand    = 0.29;
-- Base Inaccuracy of the weapon when crouched.
SWEP.InaccuracyCrouch   = 0.21;
-- Inaccuracy from firing.
SWEP.InaccuracyFire	= 0.23;
-- Inaccuracy from movement.
SWEP.InaccuracyMove	= 0.64;
-- Max Inaccuracy from firing.
SWEP.InaccuracyMax	= 1.99;
-- How long does it take to regain max accuracy from max inaccuracy.
SWEP.RecoveryTimeStand  = 1.17;