--===========================================================================--
--  Dependencies
--===========================================================================--
local Vector		= require 'src.math.Vector'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class SpecialAbility : a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local SpecialAbility = {}
SpecialAbility.__index = SpecialAbility;


-------------------------------------------------------------------------------
--  SpecialAbility:new : Creates a new special ability
-------------------------------------------------------------------------------
function SpecialAbility:new(dyzk, arena)
	local obj = {}
		
	obj.dyzk 					= dyzk;
	obj.active 					= false;
	obj._activationDown			= false;
	
	-- Timer settings
	obj.cooldown 				= 0;
	obj.globalCooldown 			= 1;
	obj.effectDuration			= 0;
	obj.activationHold			= 1/0;
	
	-- Timer variables
	obj._cooldownTimer 			= 0;
	obj._activationHoldTimer	= 0;
	obj._effectTimer			= 0;
	

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  SpecialAbility:SetCooldown : resets the cooldown timer
-------------------------------------------------------------------------------
function SpecialAbility:SetCooldown( cd )
	self._cooldownTimer = cd;
end


-------------------------------------------------------------------------------
--  SpecialAbility:GetCooldown : returns the remaining cooldown time
-------------------------------------------------------------------------------
function SpecialAbility:GetCooldown()
	return self._cooldownTimer;
end


-------------------------------------------------------------------------------
--  SpecialAbility:Activate : activates the ability
-------------------------------------------------------------------------------
function SpecialAbility:Activate( on )
	
	if  on  then
		local isCooldownOver 		=  self:GetCooldown() <= 0;
		local isGlobalCooldownOver 	=  self.dyzk:GetGlobalCooldown() <= 0;
		
		-- Cooldown periods will prevent a consequent activation, 
		if isCooldownOver and isGlobalCooldownOver then
			self:SetCooldown( self.cooldown );
			self.dyzk:SetGlobalCooldown( self.globalCooldown );
						
			self.active 				= true;
			self._activationDown 		= true;
			self._activationHoldTimer	= self.activationHold;
			
			self:OnActivationStart();
		end;		
	elseif self._activationDown then
		self._activationDown = false;

		self:OnActivationEnd();	
		
		self._effectTimer = self.effectDuration;
	end
	
end


-------------------------------------------------------------------------------
--  SpecialAbility:Update : updates the ability
-------------------------------------------------------------------------------
function SpecialAbility:Update( dt )
	
	if self._cooldownTimer > 0 then
		self._cooldownTimer = self._cooldownTimer - dt;
	end	
	if self._cooldownTimer < 0 then
		self._cooldownTimer = 0;
	end
	
	-- A complicated if-then-else tree to handle possible all ability states
	if self._activationHoldTimer > 0 then
		self._activationHoldTimer = self._activationHoldTimer - dt;
	
		if self._activationHoldTimer <= 0 then
			self._activationHoldTimer = 0;
			self:Activate( false )
		elseif self._activationDown then
			self:OnActivationUpdate( dt );
		end		
	elseif self._effectTimer > 0 then
		self._effectTimer = self._effectTimer - dt;	
		
		if self._effectTimer <= 0 then
			self._effectTimer = 0;			
			
			self:OnDeactivation()
			self.active = false;
		else
			self:OnEffectUpdate( dt );
		end
	elseif self.active then
		-- I can't think of a way to avoid this repetition
		-- whithout skipping a frame
		self:OnDeactivation();
		self.active = false;
	else
		self:OnPassiveUpdate( dt );
	end
end


-------------------------------------------------------------------------------
--  SpecialAbility:OnActivationStart : Activation start hook
-------------------------------------------------------------------------------
function SpecialAbility:OnActivationStart()
end


-------------------------------------------------------------------------------
--  SpecialAbility:OnActivationUpdate : Activation update hook
-------------------------------------------------------------------------------
function SpecialAbility:OnActivationUpdate( dt )
end


-------------------------------------------------------------------------------
--  SpecialAbility:OnActivationEnd : Activation end hook
-------------------------------------------------------------------------------
function SpecialAbility:OnActivationEnd()
end


-------------------------------------------------------------------------------
--  SpecialAbility:OnEffectUpdate : Effect update hook
-------------------------------------------------------------------------------
function SpecialAbility:OnEffectUpdate( dt )
end


-------------------------------------------------------------------------------
--  SpecialAbility:OnDeactivation : Deactivation hook
-------------------------------------------------------------------------------
function SpecialAbility:OnDeactivation()
end


-------------------------------------------------------------------------------
--  SpecialAbility:OnPassiveUpdate : Passive update hook
-------------------------------------------------------------------------------
function SpecialAbility:OnPassiveUpdate( dt )
end


--===========================================================================--
--  Initialization
--===========================================================================--
return SpecialAbility