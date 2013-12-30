--===========================================================================--
--  Dependencies
--===========================================================================--
local Vector		= require 'src.math.Vector'



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class SARedirect: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local SARedirect = {}
SARedirect.__index = SARedirect;


-------------------------------------------------------------------------------
--  SARedirect:new : Creates a new SARedirect
-------------------------------------------------------------------------------
function SARedirect:new(dyzk)
	local obj = {}
		
	obj._dyzk = dyzk;
	
	obj._stopFactor 	= 0.8;
	obj._redirectFactor = 0.7;
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  SARedirect:Activate : activates the ability
-------------------------------------------------------------------------------
function SARedirect:Activate( on )		
	local vel  = Vector:new(self._dyzk:GetVelocity());
	
	self._active = on;
	
	if on then						
		self._speed = vel:Length() * self._redirectFactor;
		
		vel = vel * (1-self._stopFactor);
		self._dyzk:SetVelocity( vel.x, vel.y );
	else
		local ctrl = Vector:new(self._dyzk:GetControlVector());
		
		if ctrl:Length() <= 0 then
			ctrl = vel:Unit();
		end
		
		self._dyzk:SetVelocity(
				vel.x + ctrl.x*self._speed, 
				vel.y + ctrl.y*self._speed  );
	end
end


-------------------------------------------------------------------------------
--  SARedirect:Activate : activates the ability
-------------------------------------------------------------------------------
function SARedirect:Update( ds )
	if self._active then		
		-- Disable manual control over the dyzk
		self._dyzk:SetControlVector(0,0);
	end
end



--===========================================================================--
--  Initialization
--===========================================================================--
return SARedirect