--===========================================================================--
--  Dependencies
--===========================================================================--
local Vector		= require 'src.math.Vector'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class SAReverseLeap: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local SAReverseLeap = {}
SAReverseLeap.__index = SAReverseLeap;


-------------------------------------------------------------------------------
--  SAReverseLeap:new : Creates a new SAReverseLeap
-------------------------------------------------------------------------------
function SAReverseLeap:new(dyzk, arena)
	local obj = {}
		
	obj._dyzk = dyzk;
	obj._leapDistance = 600;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  SAReverseLeap:Activate : activates the ability
-------------------------------------------------------------------------------
function SAReverseLeap:Activate( on )	
	if not on then
		self._trigger = true;
	end
end


-------------------------------------------------------------------------------
--  SAReverseLeap:Update : updates the ability
-------------------------------------------------------------------------------
function SAReverseLeap:Update( dt )	
	if self._trigger then
		self._trigger = false;
		
		local vel  = Vector:new(self._dyzk:GetVelocity());
		local valMagnitude = vel:Length();
		local unitVel = vel/valMagnitude;
		
		local posX, posY  = self._dyzk:GetPosition();
		self._dyzk:SetPosition( 
				posX + self._leapDistance * unitVel.x,
				posY + self._leapDistance * unitVel.y )
				
		print( posX, posX + self._leapDistance * unitVel.x );
				
		self._dyzk:SetVelocity( -vel.x,	-vel.y );
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return SAReverseLeap