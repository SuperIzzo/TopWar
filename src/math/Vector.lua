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
	local obj = {}
	
	obj.data = {...};
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Vector:__index : defines the vector indexing
-------------------------------------------------------------------------------
function Vector:__index( key )

	-- Vector axes can be accessed by numbers
	if type(key) == "number" then
		return self.data[key] or 0;
	
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

	-- Vector axes can be accessed by numbers
	if type(key) == "number" then
		self.data[key] = value;
	
	-- If the data is an axis name we remap it
	elseif type(key)== "string" then
		local remapedKey = Vector.__remappedKeys[ key ];
		if remapedKey then
			self[remapedKey] = value;
		end
		
	-- Finally, just set it
	else
		rawset( self, key, value );
	end
end


-------------------------------------------------------------------------------
--  Vector:__add : vector addition
-------------------------------------------------------------------------------
function Vector:__add( other )
	local result = Vector:new();
	local len = max( #self.data, #other.data );
	
	for i=1, len do
		result.data[i] = self[i] + other[i];
	end
	
	return result;
end


-------------------------------------------------------------------------------
--  Vector:__sub : vector subtraction
-------------------------------------------------------------------------------
function Vector:__sub( other )
	local result = Vector:new();
	local len = max( #self.data, #other.data );
	
	for i=1, len do
		result.data[i] = self[i] - other[i];
	end
	
	return result;
end


-------------------------------------------------------------------------------
--  Vector:__mul : vector scalar multiplication
-------------------------------------------------------------------------------
function Vector:__mul( scalar )
	local result = Vector:new();
	
	for i=1, #self.data do
		result.data[i] = self.data[i]*scalar;
	end
	
	return result;
end


-------------------------------------------------------------------------------
--  Vector:__div : vector scalar division
-------------------------------------------------------------------------------
function Vector:__div( scalar )
	local result = Vector:new();
	
	for i=1, #self.data do
		result.data[i] = self.data[i]/scalar;
	end
	
	return result;
end


-------------------------------------------------------------------------------
--  Vector:__string : return text representation of the vector
-------------------------------------------------------------------------------
function Vector:__tostring()
	local str = "Vector(" .. self.data[1];
	
	for i=2, #self.data do
		str = str .. "," .. self.data[i];
	end
	
	return str..")";
end


-------------------------------------------------------------------------------
--  Vector:Length : vector length
-------------------------------------------------------------------------------
function Vector:Length()
	local squareSum = self.data[1]^2;
	
	for i=2, #self.data do
		squareSum = squareSum + self.data[i]^2;
	end
	
	return squareSum^0.5;
end


-------------------------------------------------------------------------------
--  Vector:Dot : vector dot product
-------------------------------------------------------------------------------
function Vector:Dot( other )
	local len = min( #self.data, #other.data );
	local dot = 0;
	
	for i=1, len do
		dot = dot + self.data[i] * other.data[i];
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
		for i=1, #self.data do
			result.data[i] = self.data[i]/len;
		end
	end
	
	return result, len;
end



--===========================================================================--
--  Initialization
--===========================================================================--
return Vector