--===========================================================================--
--  Dependencies
--===========================================================================--
local SpecialAbility	= require 'src.abilities.SpecialAbility'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class SAStone : An ability... 
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

local SAStone = setmetatable({}, SpecialAbility)
SAStone.__index = SAStone;


-------------------------------------------------------------------------------
--  SAReverseLeap constants
-------------------------------------------------------------------------------
SAStone.cooldown		= 10;


-------------------------------------------------------------------------------
--  SAStone:new : Creates a new SAStone
-------------------------------------------------------------------------------
function SAStone:new( dyzk )
	local obj = SpecialAbility:new(dyzk)

	obj.extraWeight  = 100;	
	obj.originalWeight = dyzk:GetWeight();

	return setmetatable(obj, self);
end



-------------------------------------------------------------------------------
--  SAStone:new : Creates a new SAStone
-------------------------------------------------------------------------------
function SAStone:OnActivationStart()
	self.originalWeight = self.dyzk:GetWeight();
	
	self.dyzk:SetWeight( self.originalWeight + self.extraWeight );
	self.dyzk:SetVelocity( 0, 0 );
end


-------------------------------------------------------------------------------
--  SAStone:new : Creates a new SAStone
-------------------------------------------------------------------------------
function SAStone:OnActivationEnd()
	self.dyzk:SetWeight( self.originalWeight );
end


-------------------------------------------------------------------------------
--  SAStone:OnActivationUpdate : activates the ability
-------------------------------------------------------------------------------
function SAStone:OnActivationUpdate( dt )
	-- Disable manual control over the dyzk
	self.dyzk:SetControlVector(0,0);
end


--===========================================================================--
--  Initialization
--===========================================================================--
return SAStone