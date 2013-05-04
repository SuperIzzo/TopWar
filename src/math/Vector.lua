--===========================================================================--
--  Dependencies
--===========================================================================--
local setmetatable 		= _G.setmetatable
local sqrt				= _G.math.sqrt




--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Vector : a mathematical vector 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Vector = {}
Vector.__index = Vector;


-------------------------------------------------------------------------------
--  Vector:new : Creates a new vector instance
-------------------------------------------------------------------------------
function Vector:new( x, y )
	local obj = {}
	
	obj.x =  x or 0;
	obj.y =  y or 0;
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Vector:__add : vector addition
-------------------------------------------------------------------------------
function Vector:__add( other )
	return Vector:new( self.x+other.x, self.y+other.y );
end


-------------------------------------------------------------------------------
--  Vector:__sub : vector subtraction
-------------------------------------------------------------------------------
function Vector:__sub( other )
	return Vector:new( self.x-other.x, self.y-other.y );
end


-------------------------------------------------------------------------------
--  Vector:__mul : vector scalar multiplication
-------------------------------------------------------------------------------
function Vector:__mul( scalar )
	return Vector:new( self.x*scalar, self.y*scalar );
end


-------------------------------------------------------------------------------
--  Vector:__div : vector scalar division
-------------------------------------------------------------------------------
function Vector:__div( scalar )
	return Vector:new( self.x/scalar, self.y/scalar );
end


-------------------------------------------------------------------------------
--  Vector:Length : vector length
-------------------------------------------------------------------------------
function Vector:Length()
	return sqrt(self.x^2 + self.y^2);
end


-------------------------------------------------------------------------------
--  Vector:Dot : vector dot product
-------------------------------------------------------------------------------
function Vector:Dot( other )
	return self.x*other.x + self.y*other.y;
end


-------------------------------------------------------------------------------
--  Vector:Unit : turns the vector into a unit vector
-------------------------------------------------------------------------------
function Vector:Unit()
	local len = self:Length();
	
	return Vector:new( self.x/len, self.y/len );
end




--===========================================================================--
--  Initialization
--===========================================================================--
return Vector