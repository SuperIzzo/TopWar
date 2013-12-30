--===========================================================================--
--  Dependencies
--===========================================================================--
local Vector		= require 'src.math.Vector'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class SABoost: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local SABoost = {}
SABoost.__index = SABoost;


-------------------------------------------------------------------------------
--  SABoost:new : Creates a new SABoost
-------------------------------------------------------------------------------
function SABoost:new(dyzk, arena)
	local obj = {}
		
	obj._dyzk = dyzk;
	obj._active = false;
	
	
	obj._initialBoost = 200;	-- impulse
	obj._continuousBoost = 600;	-- pixels per seconds

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  SABoost:Activate : activates the ability
-------------------------------------------------------------------------------
function SABoost:Activate( on )	
	self._active = on;
	
	if on then
		local cx, cy = self._dyzk:GetControlVector();
		local vx, vy = self._dyzk:GetVelocity();		
		
		self._dyzk:SetVelocity( 
				vx + cx*self._initialBoost, 
				vy + cy*self._initialBoost );
	end
end


-------------------------------------------------------------------------------
--  SABoost:Update : updates the ability
-------------------------------------------------------------------------------
function SABoost:Update( dt )	
	if self._active then	
		local cx, cy = self._dyzk:GetControlVector();
		local vx, vy = self._dyzk:GetVelocity();		
		
		print( dt );
		
		self._dyzk:SetVelocity(
				vx + cx*self._continuousBoost*dt, 
				vy + cy*self._continuousBoost*dt );
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return SABoost