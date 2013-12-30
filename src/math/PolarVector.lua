--===========================================================================--
--  Dependencies
--===========================================================================--
local sin		 		= _G.math.sin
local cos				= _G.math.cos
local sqrt				= _G.math.sqrt
local atan				= _G.math.atan
local pi				= _G.math.pi





--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class PolarVector : a mathematical vector in polar coordinate system
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--    Polar vectors have two components - angle (a) and radius (r) which 
--  indicate a point on circle. (a=0, r=0) is the center. The higher `r' is the
--  further away the point is from the center. `a' indicates the direction of
--  the displacement in radiants, 0 is (usually) right and pi (~3.14) is left.
--    PolarVectors can be converted from and to vectors in the Cartesian 
--  coordinate system.
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local PolarVector =
{
}


-------------------------------------------------------------------------------
--  PolarVector:new : Creates a new vector instance
-------------------------------------------------------------------------------
function PolarVector:new( a, r )
	local obj = {}
	
	obj.r =  r or 0;
	obj.a =  a or 0;
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  PolarVector:ToCartesian : transforms the vector to cartesian coords
-------------------------------------------------------------------------------
function PolarVector:ToCartesian()
	return cos(self.a)*self.r, -sin(self.a)*self.r;
end


-------------------------------------------------------------------------------
--  PolarVector:FromCartesian : sets the polar vector from cartesian coords
-------------------------------------------------------------------------------
function PolarVector:FromCartesian(x, y)
	self.r = sqrt(x^2 + y^2);
	
	if x>0.001 or x<-0.001 then
		self.a = atan(-y/x);
		
		if y > 0 then
			self.a = self.a + pi;
			
			if x > 0 then
				self.a = pi+self.a;
			end
		elseif x < 0 then
				self.a = self.a + pi;
		end
	elseif y > 0 then
		self.a = pi*3/2
	else
		self.a = pi/2;
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
PolarVector.__index = PolarVector;

return PolarVector