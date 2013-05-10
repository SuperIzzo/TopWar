--===========================================================================--
--  Dependencies
--===========================================================================--
-- Modules
local Utils		 		= require 'src.math.Utils'

-- Aliases
local setmetatable		= setmetatable
local sqrt				= math.sqrt



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class NormalImageFilter: a filter which normalizes the color
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local NormalImageFilter = {}
NormalImageFilter.__index = NormalImageFilter;


-------------------------------------------------------------------------------
--  NormalImageFilter:new : Creates a new NormalImageFilter
-------------------------------------------------------------------------------
function NormalImageFilter:new( image )
	local obj = {}
	
	self.image = image;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  NormalImageFilter:getWidth : returns the width of the image
-------------------------------------------------------------------------------
function NormalImageFilter:getWidth()
	return self.image:getWidth();
end


-------------------------------------------------------------------------------
--  NormalImageFilter:getHeight : returns the height of the image
-------------------------------------------------------------------------------
function NormalImageFilter:getHeight()
	return self.image:getHeight();
end


-------------------------------------------------------------------------------
--  NormalImageFilter:getSize : returns the width and the height of the image
-------------------------------------------------------------------------------
function NormalImageFilter:getSize()
	return self:getWidth(), self:getHeight();
end


-------------------------------------------------------------------------------
--  NormalImageFilter:getPixel : return a gradient pixel based on ccords
-------------------------------------------------------------------------------
function NormalImageFilter:getPixel( x, y )	
	local r, g, b, a = self.image:getPixel(x,y);
	
	local nx, ny, nz = Utils.ColorToNormal( r, g, b );
	local len = sqrt(nx^2 + ny^2 + nz^2);
	r, g, b = Utils.NormalToColor( nx/len, ny/len, nz/len );

	return r, g, b, a;
end



--===========================================================================--
--  Initialization
--===========================================================================--
return NormalImageFilter