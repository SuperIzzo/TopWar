--===========================================================================--
--  Dependencies
--===========================================================================--
local SpecialAbility	= require 'src.abilities.SpecialAbility'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class SADash : An ability... 
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  Overwrite one or more of the following methods to define the behaviour of 
--  the ability:
--		OnActivationStart()			- Called when the ability cast begins
--									  (usually at key/button-press)
--		OnActivationUpdate( dt )	- Called while the ability is being cast
--									  (usually called while the key is down)
--		OnActivationEnd()			- Called when the ability cast is over
--									  (key/button release or cast time is over)
--		OnEffectUpdate( dt )		- Called after the activation is over while
--									  the ability is still in effect
--		OnDeactivation()			- Called when the effect is over
--		OnPassiveUpdate( dt )		- Called while the ability is not active
--		OnDyzkCollision( report )	- Called if the dyzk collides another dyzk
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--

local SADash = setmetatable({}, SpecialAbility)
SADash.__index = SADash;


-------------------------------------------------------------------------------
--  SABoost constants
-------------------------------------------------------------------------------
SADash.effectDuration			= 0.2;
SADash.activationHold			= 0;


-------------------------------------------------------------------------------
--  SADash:new : Creates a new SADash
-------------------------------------------------------------------------------
function SADash:new( dyzk )
	local obj = SpecialAbility:new(dyzk)
	
	self._dashSpeed = dyzk:GetSpeed()*0.5 + 2000;
	self._velX = 0;
	self._velY = 0;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  SADash:new : Creates a new SADash
-------------------------------------------------------------------------------
function SADash:OnActivationStart()
	self._velX, self._velY = self.dyzk:GetVelocity();
	local cx, cy = self.dyzk:GetControlVector();
		
	self.dyzk:SetVelocity( cx*self._dashSpeed, 
						   cy*self._dashSpeed );
end


-------------------------------------------------------------------------------
--  SADash:new : Creates a new SADash
-------------------------------------------------------------------------------
function SADash:OnDeactivation()
	self.dyzk:SetVelocity( self._velX, self._velY);
end


--===========================================================================--
--  Initialization
--===========================================================================--
return SADash