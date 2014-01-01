--===========================================================================--
--  Dependencies
--===========================================================================--
local SpecialAbility	= require 'src.abilities.SpecialAbility'
local Vector			= require 'src.math.Vector'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class SABoost: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local SABoost = setmetatable({}, SpecialAbility)
SABoost.__index = SABoost;


-------------------------------------------------------------------------------
--  SABoost:new : Creates a new SABoost
-------------------------------------------------------------------------------
function SABoost:new(dyzk, arena)
	local obj = SpecialAbility:new(dyzk)
			
	obj._initialBoost = 100;	-- impulse
	obj._continuousBoost = 400;	-- pixels per seconds

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  SABoost:OnActivationStart : activates the ability
-------------------------------------------------------------------------------
function SABoost:OnActivationStart()	
	local cx, cy = self.dyzk:GetControlVector();
	local vx, vy = self.dyzk:GetVelocity();		
		
	self.dyzk:SetVelocity( 
			vx + cx*self._initialBoost, 
			vy + cy*self._initialBoost );
end


-------------------------------------------------------------------------------
--  SABoost:OnActivationUpdate : updates the ability
-------------------------------------------------------------------------------
function SABoost:OnActivationUpdate( dt )	
	local cx, cy = self.dyzk:GetControlVector();
	local vx, vy = self.dyzk:GetVelocity();		
		
	print( dt );
		
	self.dyzk:SetVelocity(
			vx + cx*self._continuousBoost*dt, 
			vy + cy*self._continuousBoost*dt );
end


--===========================================================================--
--  Initialization
--===========================================================================--
return SABoost