--===========================================================================--
--  Dependencies
--===========================================================================--
local floor				= math.floor


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Array2D : A 2-dimensional array data structure
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Array2D = {}
Array2D.__index = Array2D;


-------------------------------------------------------------------------------
--  Array2D:new : Creates a new Array2D
-------------------------------------------------------------------------------
function Array2D:new( width, height, obj )
	local obj = obj or {}

	obj.w	= width;
	obj.h	= height;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Array2D:GetWidth : Returns the width of the map
-------------------------------------------------------------------------------
function Array2D:GetWidth()
	return self.w;
end


-------------------------------------------------------------------------------
--  Array2D:GetHeight : Returns the height of the map
-------------------------------------------------------------------------------
function Array2D:GetHeight()
	return self.h;
end


-------------------------------------------------------------------------------
--  Array2D:_GetCoordinatesIndex : Returns an index constructed from the coords
-------------------------------------------------------------------------------
function Array2D:_GetCoordinatesIndex( x, y )
	assert( type(self.w) == "number", "Incorrect 'w' key of Array2D" );
	
	if x<0 or x>=self.w or y<0 or y>=self.h then
		error( "Array2D coordinates out of bounds: " .. x .. ", " .. y );
	end
	
	return x + y*self.w +1;
end


-------------------------------------------------------------------------------
--  Array2D:Get : Returns the item at location x, y
-------------------------------------------------------------------------------
function Array2D:Get( x, y )		
	local idx = self:_GetCoordinatesIndex( x,y );
	return self[idx];
end


-------------------------------------------------------------------------------
--  Array2D:Set : Sets the item at location x, y
-------------------------------------------------------------------------------
function Array2D:Set( x, y, item )
	local idx = self:_GetCoordinatesIndex( x,y );	
	self[idx] = item;
end


-------------------------------------------------------------------------------
--  Array2D:Items : Returns an iterator to the array items
-------------------------------------------------------------------------------
function Array2D:Items()
	local i = 0;
	
	return function ()
		i=i+1;
		return self[i], i;
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Array2D