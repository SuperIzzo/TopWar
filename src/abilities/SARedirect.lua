--===========================================================================--
--  Dependencies
--===========================================================================--
local SpecialAbility	= require 'src.abilities.SpecialAbility'
local Vector			= require 'src.math.Vector'



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class SARedirect: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local SARedirect = setmetatable({}, SpecialAbility)
SARedirect.__index = SARedirect;


-------------------------------------------------------------------------------
--  SARedirect:new : Creates a new SARedirect
-------------------------------------------------------------------------------
function SARedirect:new(dyzk)
	local obj = SpecialAbility:new(dyzk)
	
	obj._stopFactor 	= 0.7;
	obj._redirectFactor = 0.8;
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  SARedirect:Activate : activates the ability
-------------------------------------------------------------------------------
function SARedirect:OnActivationStart()		
	local vel  = Vector:new(self.dyzk:GetVelocity());
		
	self._speed = vel:Length() * self._redirectFactor;
		
	vel = vel * (1-self._stopFactor);
	self.dyzk:SetVelocity( vel.x, vel.y );
end


-------------------------------------------------------------------------------
--  SARedirect:OnActivationEnd : activates the ability
-------------------------------------------------------------------------------
function SARedirect:OnActivationEnd()	
	local vel  = Vector:new(self.dyzk:GetVelocity());
	local ctrl = Vector:new(self.dyzk:GetControlVector());
		
	if ctrl:Length() <= 0 then
		ctrl = vel:Unit();
	end
	
	self.dyzk:SetVelocity(
			vel.x + ctrl.x*self._speed, 
			vel.y + ctrl.y*self._speed  );
end


-------------------------------------------------------------------------------
--  SARedirect:OnActivationUpdate : activates the ability
-------------------------------------------------------------------------------
function SARedirect:OnActivationUpdate( ds )
	-- Disable manual control over the dyzk
	self.dyzk:SetControlVector(0,0);
end



--===========================================================================--
--  Initialization
--===========================================================================--
return SARedirect