--===========================================================================--
--  Dependencies
--===========================================================================--
local SpecialAbility	= require 'src.abilities.SpecialAbility'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class SAJump : An ability... 
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

local SAJump = setmetatable({}, SpecialAbility)
SAJump.__index = SAJump;


-------------------------------------------------------------------------------
--  SAJump:new : Creates a new SAJump
-------------------------------------------------------------------------------
function SAJump:new( dyzk )
	local obj = SpecialAbility:new(dyzk)


	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  SAJump:new : Creates a new SAJump
-------------------------------------------------------------------------------
function SAJump:OnActivationStart()
	local jumpAmount = 3000;
	local vx,vy,vz = self.dyzk:GetVelocity();
	self.dyzk:SetVelocity(vx, vy, vz+jumpAmount);
end


--===========================================================================--
--  Initialization
--===========================================================================--
return SAJump