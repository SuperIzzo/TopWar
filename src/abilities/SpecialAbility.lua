--===========================================================================--
--  Dependencies
--===========================================================================--
local Vector		= require 'src.math.Vector'
local Timer			= require 'src.util.Timer'



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class SpecialAbility : a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local SpecialAbility = {}
SpecialAbility.__index = SpecialAbility;


-------------------------------------------------------------------------------
--  SpecialAbility constants (a couple of defaults)
-------------------------------------------------------------------------------
SpecialAbility.cooldown 				= 1;
SpecialAbility.globalCooldown 			= 0.3;
SpecialAbility.effectDuration			= 0;
SpecialAbility.activationHold			= 1/0;  -- = +INF


-------------------------------------------------------------------------------
--  SpecialAbility:new : Creates a new special ability
-------------------------------------------------------------------------------
function SpecialAbility:new(dyzk, arena)
	local obj = {}
		
	obj.dyzk 					= dyzk;
	obj.active 					= false;
	obj._activationDown			= false;
	
	
	-- Timer variables
	obj._cooldownTimer 			= Timer:new();
	obj._activationHoldTimer	= Timer:new();
	obj._effectTimer			= Timer:new();
	

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  SpecialAbility:SetCooldown : resets the cooldown timer
-------------------------------------------------------------------------------
function SpecialAbility:SetCooldown( cd )
	self._cooldownTimer:Reset( cd );
end


-------------------------------------------------------------------------------
--  SpecialAbility:GetCooldown : returns the remaining cooldown time
-------------------------------------------------------------------------------
function SpecialAbility:GetCooldown()
	return self._cooldownTimer:GetTimeLeft();
end


-------------------------------------------------------------------------------
--  SpecialAbility:GetCooldownPeriod : returns the cooldown period
-------------------------------------------------------------------------------
function SpecialAbility:GetCooldownPeriod()
	return self.cooldown;
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
			self._activationHoldTimer:Reset( self.activationHold );
			
			self:OnActivationStart();
		end;		
	elseif self._activationDown then
		self._activationDown = false;

		self:OnActivationEnd();	
		
		self._effectTimer:Reset( self.effectDuration );
	end
	
end


-------------------------------------------------------------------------------
--  SpecialAbility:Update : updates the ability
-------------------------------------------------------------------------------
function SpecialAbility:Update( dt )
	
	self._cooldownTimer:Update( dt );
	
	-- A complicated if-then-else tree to handle possible all ability states
	if not self._activationHoldTimer:IsRunning() then
		self._activationHoldTimer:Update( dt );
	
		if self._activationHoldTimer:IsStopped() then
			self:Activate( false )
		elseif self._activationDown then
			self:OnActivationUpdate( dt );
		end		
	elseif self._effectTimer:IsRunning() then
		self._effectTimer:Update( dt );
		
		if self._effectTimer:IsStopped() then
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