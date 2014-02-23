--===========================================================================--
--  Dependencies
--===========================================================================--
local setmetatable 			= setmetatable
local sqrt					= math.sqrt
local max					= math.max
local min					= math.min




--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Vector : a mathematical vector 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Vector = {}
Vector.__index = Vector;


-------------------------------------------------------------------------------
--  Vector Constants
-------------------------------------------------------------------------------
Vector.__remappedKeys = { x=1, y=2, z=3, w=4 }


-------------------------------------------------------------------------------
--  Vector:new : Creates a new vector instance
-------------------------------------------------------------------------------
function Vector:new( ... )
	local obj = {...}
	
	obj.n = #obj;
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Vector:__index : defines the vector indexing
-------------------------------------------------------------------------------
function Vector:__index( key )

	-- Default value for numeric keys is 0 rather than nil
	if type(key) == "number" then
		return 0;
	
	-- If the data is an axis name we remap it
	elseif type(key)== "string" then
		local remapedKey = Vector.__remappedKeys[ key ];
		if remapedKey then
			return self[remapedKey];
		end
	end
	
	-- Finally fallback to the class
	return Vector[key];
end


-------------------------------------------------------------------------------
--  Vector:__index : defines the vector indexing
-------------------------------------------------------------------------------
function Vector:__newindex( key, value )
	
	-- If the data is a number check if we have to increase our dimension
	if type(key)== "number" then
		if (not self.n) or self.n<key then
			self.n = key;
			rawset( self, key, value );
		end
	
	-- If the data is an axis name we remap it
	elseif type(key)== "string" then
		local remapedKey = Vector.__remappedKeys[ key ];
		if remapedKey then
			self[remapedKey] = value;
		end
		
	-- else, we just set it
	else
		rawset( self, key, value );
	end
end


-------------------------------------------------------------------------------
--  Vector:__add : vector addition
-------------------------------------------------------------------------------
function Vector:__add( other )
	local result = Vector:new();
	local len = max( #self, #other );
	
	for i=1, len do
		result[i] = self[i] + other[i];
	end
	
	return result;
end


-------------------------------------------------------------------------------
--  Vector:__sub : vector subtraction
-------------------------------------------------------------------------------
function Vector:__sub( other )
	local result = Vector:new();
	local len = max( #self, #other );
	
	for i=1, len do
		result[i] = self[i] - other[i];
	end
	
	return result;
end


-------------------------------------------------------------------------------
--  Vector:__mul : vector scalar multiplication
-------------------------------------------------------------------------------
function Vector:__mul( scalar )
	local result = Vector:new();
	
	for i=1, #self do
		result[i] = self[i]*scalar;
	end
	
	return result;
end


-------------------------------------------------------------------------------
--  Vector:__div : vector scalar division
-------------------------------------------------------------------------------
function Vector:__div( scalar )
	local result = Vector:new();
	
	for i=1, #self do
		result[i] = self[i]/scalar;
	end
	
	return result;
end


-------------------------------------------------------------------------------
--  Vector:__len : return dimension of the vector
-------------------------------------------------------------------------------
function Vector:__len()
	return self.n;
end


-------------------------------------------------------------------------------
--  Vector:__string : return text representation of the vector
-------------------------------------------------------------------------------
function Vector:__tostring()
	local str = "Vector(" .. self[1];
	
	for i=2, #self do
		str = str .. "," .. self[i];
	end
	
	return str..")";
end


-------------------------------------------------------------------------------
--  Vector:Length : vector length
-------------------------------------------------------------------------------
function Vector:Length()
	local squareSum = self[1]^2;
	
	for i=2, #self do
		squareSum = squareSum + self[i]^2;
	end
	
	return squareSum^0.5;
end


-------------------------------------------------------------------------------
--  Vector:Dot : vector dot product
-------------------------------------------------------------------------------
function Vector:Dot( other )
	local len = min( #self, #other );
	local dot = 0;
	
	for i=1, len do
		dot = dot + self[i] * other[i];
	end
	
	return dot;
end


-------------------------------------------------------------------------------
--  Vector:Unit : turns the vector into a unit vector
-------------------------------------------------------------------------------
function Vector:Unit()
	local result = Vector:new();
	local len = self:Length();
	
	if len>0 then
		for i=1, #self do
			result[i] = self[i]/len;
		end
	end
	
	return result, len;
end



--===========================================================================--
--  Initialization
--===========================================================================--
return Vector