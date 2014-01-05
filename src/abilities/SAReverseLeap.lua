--===========================================================================--
--  Dependencies
--===========================================================================--
local SpecialAbility	= require 'src.abilities.SpecialAbility'
local Vector			= require 'src.math.Vector'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class SAReverseLeap: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local SAReverseLeap = setmetatable({}, SpecialAbility);
SAReverseLeap.__index = SAReverseLeap;


-------------------------------------------------------------------------------
--  SAReverseLeap constants
-------------------------------------------------------------------------------
SAReverseLeap.cooldown		= 10;


-------------------------------------------------------------------------------
--  SAReverseLeap:new : Creates a new SAReverseLeap
-------------------------------------------------------------------------------
function SAReverseLeap:new(dyzk, arena)
	local obj = SpecialAbility:new(dyzk)
	
	obj._leapDistance = 600;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  SAReverseLeap:Activate : activates the ability
-------------------------------------------------------------------------------
function SAReverseLeap:OnActivationEnd()
	local vel  = Vector:new(self.dyzk:GetVelocity());
	local valMagnitude = vel:Length();
	local unitVel = vel/valMagnitude;
	
	local posX, posY  = self.dyzk:GetPosition();
	self.dyzk:SetPosition( 
			posX + self._leapDistance * unitVel.x,
			posY + self._leapDistance * unitVel.y )
			
	self.dyzk:SetVelocity( -vel.x,	-vel.y );
end


--===========================================================================--
--  Initialization
--===========================================================================--
return SAReverseLeap