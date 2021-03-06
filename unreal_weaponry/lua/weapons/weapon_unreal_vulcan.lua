DEFINE_BASECLASS("weapon_unreal_base");
SWEP.Spawnable = true;
SWEP.AdminOnly = true;

-- General weapon stuff.
-- Weapon name.
SWEP.PrintName = "M163 Vulcan";
-- Weapon category.
SWEP.Category = "Unreal Weaponry"
-- Slot
SWEP.Slot = 2;

-- Weapon appearance and sounds.
-- View model.
SWEP.ViewModel	= Model("models/weapons/c_pistol.mdl");
-- World model.
SWEP.WorldModel = Model("models/weapons/w_pistol.mdl");
-- Field of view of the viewmodel.
SWEP.ViewModelFOV = 78;
-- Changes if you are holding the gun left or right handed.
SWEP.ViewModelFlip = false;
-- How do you hold this gun?
SWEP.HoldType	= "pistol";
-- This sound will be played when the gun is fired.
SWEP.FireSound	= "Weapon_Pistol.Single";

-- Weapon charachteristics
-- How many cycles per second this weapon can do, this is the delay between firing the gun again after shooting it.
SWEP.CycleRate	= 6000;
-- How many bullets can fit in one magazine.
SWEP.ClipSize	= -1;
-- What ammo type does this weapon use?
SWEP.AmmoType	= "smg1";
-- Initial or "raw" damage of the weapon at zero range against unarmored opponents.
SWEP.Damage		= 128;
-- Caliber lol idk what to say about this, it's just a fucking caliber, you know the word used to describe diameter of bullet.
SWEP.Caliber	= 20;
-- Velocity of bullet when it exists gun barrel, in meters per second.
SWEP.MuzzleVelocity		= 1030;
-- Weight of the bullet (without shell casing obviously) in grams.
SWEP.ProjectileMass		= 102;
-- Length of the bullet in milimeters.
SWEP.ProjectileLength	= 102;
-- Base Inaccuracy of the weapon.
SWEP.InaccuracyStand    = 1.33;
-- Base Inaccuracy of the weapon when crouched.
SWEP.InaccuracyCrouch   = 1.17;
-- Inaccuracy from firing.
SWEP.InaccuracyFire	= 0.09;
-- Inaccuracy from movement.
SWEP.InaccuracyMove	= 0.47;
-- Max Inaccuracy from firing.
SWEP.InaccuracyMax	= 2.97;
-- How long does it take to regain max accuracy from max inaccuracy.
SWEP.RecoveryTimeStand  = 1.07;