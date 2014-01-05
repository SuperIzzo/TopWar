--===========================================================================--
--  Dependencies
--===========================================================================--
local MathUtils 	= require 'src.math.MathUtils'

local round 		= MathUtils.Round



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class RPMDamageAnim: Damage to the RPM meter animation
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local RPMDamageAnim = {}
RPMDamageAnim.__index = RPMDamageAnim;


-------------------------------------------------------------------------------
--  RPMDamageAnim constants
-------------------------------------------------------------------------------
RPMDamageAnim.DISPLAY_TIME = 1.2;


-------------------------------------------------------------------------------
--  RPMDamageAnim:new : Creates a new RPMDamageAnim
-------------------------------------------------------------------------------
function RPMDamageAnim:new( meter, number )
	local obj = {}

	obj.meter 	= meter;
	obj.number 	= number;
	obj.counter = self.DISPLAY_TIME;
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Sparks:Update : Updates the sparks animation counter
-------------------------------------------------------------------------------
function RPMDamageAnim:Update( dt )
	if not self:IsAnimOver() then
		self.counter = self.counter - dt;
	end
end


-------------------------------------------------------------------------------
--  RPMDamageAnim:IsAnimOver : returns true when the animation is over
-------------------------------------------------------------------------------
function RPMDamageAnim:IsAnimOver()
	return self.counter <= 0;
end


-------------------------------------------------------------------------------
--  RPMDamageAnim:Draw : Creates a new RPMDamageAnim
-------------------------------------------------------------------------------
function RPMDamageAnim:Draw()
	local animElapsed = 1 - self.counter/self.DISPLAY_TIME;
	
	love.graphics.print("" .. self.number, 
			self.meter.x + 40 + (animElapsed^0.3)*25, 
			self.meter.y + animElapsed*50);
end



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class RPMMeter : HUD element
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local RPMMeter = {}
RPMMeter.__index = RPMMeter


-------------------------------------------------------------------------------
--  RPMMeter:new : Creates a new meter
-------------------------------------------------------------------------------
function RPMMeter:new( dyzk, x, y )
	local obj = {};
	
	obj.dyzk = dyzk;
	obj.x	 = x;
	obj.y	 = y;
	
	obj.animations = {};
	
	-- Sign up for collision reports
	dyzk:AddCollisionListener( self.OnDyzkCollision, obj );
	
	return setmetatable( obj, self )
end


-------------------------------------------------------------------------------
--  RPMMeter:Update : Updates the meter
-------------------------------------------------------------------------------
function RPMMeter:Update(ds)
	for i= 1, #self.animations do
		self.animations[i]:Update(ds);
	end	
end


-------------------------------------------------------------------------------
--  RPMMeter:Draw : Draws the meter
-------------------------------------------------------------------------------
function RPMMeter:Draw()
	love.graphics.print("" .. round(self.dyzk:GetRPM()), self.x, self.y);
	
	for i= 1, #self.animations do
		local anim = self.animations[i];
		if anim and not anim:IsAnimOver() then			
			anim:Draw();
		else
			table.remove( self.animations, i );
			i = i-1;  -- turn the loop counter back by one (this is vile)
		end
	end		
end


-------------------------------------------------------------------------------
--  RPMMeter:OnDyzkCollision : Acts on dyzk collision
-------------------------------------------------------------------------------
function RPMMeter:OnDyzkCollision( report )
	local damage = round(report:GetRPMDamage1());
	
	if damage ~= 0 then
		local newAnim = RPMDamageAnim:new( self, -damage );	
		table.insert( self.animations, newAnim );
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return RPMMeter;