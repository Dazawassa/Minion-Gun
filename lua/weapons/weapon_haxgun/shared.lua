resource.AddFile( "materials/weapons/haxicon.vmt" )
resource.AddFile( "materials/weapons/haxicon.vtf" )
resource.AddFile( "models/weapons/c_pfinger.mdl" )
resource.AddFile( "models/weapons/c_pfinger.vvd" )
resource.AddFile( "models/weapons/c_pfinger.dx80.vtx" )
resource.AddFile( "models/weapons/c_pfinger.dx90.vtx" )
resource.AddFile( "models/weapons/c_pfinger.sw.vtx" )


SWEP.Author = "Dazawassa although I based it off a SWEP for the HAX gun."
SWEP.Contact = "Dazawassa"
SWEP.Purpose = "Made for a friend as a shitpost"
SWEP.Instructions = "Shoot minion"

SWEP.Spawnable = true 
SWEP.AdminSpawnable = true 

SWEP.ViewModel = "models/weapons/c_pfinger.mdl" 
SWEP.WorldModel = "models/gru/gru_pm.mdl"
SWEP.UseHands = false
SWEP.ViewModelFOV = 95


SWEP.Primary.ClipSize = -1 
SWEP.Primary.DefaultClip = -1 
SWEP.Primary.Automatic = false 
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1 
SWEP.Secondary.DefaultClip = -1 
SWEP.Secondary.Automatic = false 
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false

SWEP.HoldType = "default"

local ShootSound = Sound ("../sound/minion/banana.wav")
local ShootSound2 = Sound ("weapons/iceaxe/iceaxe_swing1.wav")
local ScoutSound = Sound ("vo/scout_jeers04.mp3")

function SWEP:Deploy()
	self.Weapon:SetNoDraw( true )
end 

function SWEP:Reload() 

end 

function SWEP:Initialize()
	self.ActivityTranslate = {}
	self.ActivityTranslate[ACT_HL2MP_IDLE] = ACT_HL2MP_IDLE_MELEE
	self.ActivityTranslate[ACT_HL2MP_WALK] = ACT_HL2MP_WALK_MELEE
	self.ActivityTranslate[ACT_HL2MP_RUN] = ACT_HL2MP_RUN_MELEE
	self.ActivityTranslate[ACT_HL2MP_IDLE_CROUCH] = ACT_HL2MP_IDLE_MELEE
	self.ActivityTranslate[ACT_HL2MP_WALK_CROUCH] = ACT_HL2MP_WALK_CROUCH_MELEE
	self.ActivityTranslate[ACT_HL2MP_GESTURE_RANGE_ATTACK] = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
	self.ActivityTranslate[ACT_HL2MP_GESTURE_RELOAD] = ACT_HL2MP_GESTURE_RELOAD_MELEE
	self.ActivityTranslate[ACT_HL2MP_JUMP] = ACT_HL2MP_JUMP_MELEE
	self.ActivityTranslate[ACT_RANGE_ATTACK1] = ACT_RANGE_ATTACK_MELEE
end 

function SWEP:Think() 
end 

function SWEP:throw_attack()

if !IsValid(self) or !IsValid(self.Owner) then return end


if (SERVER) then
	--self.Weapon:EmitSound (ShootSound2)
	self:SetHoldType("melee")
	timer.Simple(0.275, function()
		if !IsValid(self) then return end
		
		if self:GetHoldType() != "pistol" then
			self:SetHoldType("normal")
		end
	end)
	
	self:SendWeaponAnim(ACT_VM_IDLE)
	
	self.Owner:SetAnimation(PLAYER_ATTACK1)
		self.Monitor = ents.Create("monitor")
		self.Monitor:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 16))
		self.Monitor:SetAngles( self.Owner:EyeAngles() )
		self.Monitor:SetPhysicsAttacker(self.Owner)
		self.Monitor:SetOwner(self.Owner)
		self.Monitor:Spawn()
		
		local phys = self.Monitor:GetPhysicsObject() 
		local tr = self.Owner:GetEyeTrace()
		local PlayerPos = self.Owner:GetShootPos()
 	 
 	local shot_length = tr.HitPos:Length() 
 	phys:ApplyForceCenter (self.Owner:GetAimVector():GetNormalized() *  math.pow(shot_length, 3))
	phys:ApplyForceOffset(VectorRand()*math.Rand(10000,30000),PlayerPos + VectorRand()*math.Rand(0.5,1.5))

	end

end

function SWEP:PrimaryAttack() 
	self:SetHoldType("pistol")
    self.Weapon:EmitSound (ShootSound)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Weapon:SetNextPrimaryFire( CurTime() + 1.3 )
	
 	timer.Simple(1.01, function()
	if !IsValid(self) then return end
		
		self:throw_attack() 
	end )
	
	if GetConVarNumber("hax_slowmo") == 1 then
	
		if (SERVER) then
			timer.Simple(1.02, function() game.SetTimeScale( 0.3 ) end)
    		timer.Simple(1.03, function() game.ConsoleCommand( "pp_motionblur 1\n" ) end)
    		timer.Simple(1.3, function() game.ConsoleCommand( "pp_motionblur 0\n" ) end)
    		timer.Simple(1.3, function() game.SetTimeScale( 1 ) end)
    		
    	end
    end
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + 4 )
	
	local tr = self.Owner:GetEyeTrace()
	if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
		tr.Entity:EmitSound (ScoutSound)
	end
end