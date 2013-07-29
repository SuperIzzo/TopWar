--===========================================================================--
--  Dependencies
--===========================================================================--
require 'gd'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class GDImageWrapper : CG image wrapper, that looks like a Love image
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local GDImageWrapper = {}
GDImageWrapper.__index = GDImageWrapper;


-------------------------------------------------------------------------------
--  GDImageWrapper:new : Creates a wrapper around a cg image
-------------------------------------------------------------------------------
function GDImageWrapper:new( image )
	local obj = {}
	
	obj._image = image;
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  GDImageWrapper:newImageData : A more love conventional constructor
-------------------------------------------------------------------------------
function GDImageWrapper:newImageData( width, height )
	return self:new( gd.createTrueColor(width, height) );
end


-------------------------------------------------------------------------------
--  GDImageWrapper:setPixel : Plots a pixels
-------------------------------------------------------------------------------
function GDImageWrapper:setPixel(x,y, r,g,b,a)
	local img = self._image
	local color = img:colorAllocate(r, g, b)

	img:setPixel(x, y, color);
end


-------------------------------------------------------------------------------
--  GDImageWrapper:getPixel : Returns the pixel at x,y
-------------------------------------------------------------------------------
function GDImageWrapper:getPixel(x,y)
	local img = self._image
	local color = img:getPixel(x,y)
	
	return 	img:red(color),
			img:green(color),
			img:blue(color),
			img:alpha(color)
end


-------------------------------------------------------------------------------
--  GDImageWrapper:getWidth : Returns the width of the image
-------------------------------------------------------------------------------
function GDImageWrapper:getWidth()
	local img = self._image
	return img:sizeX()
end


-------------------------------------------------------------------------------
--  GDImageWrapper:getHeight : Returns the height of the image
-------------------------------------------------------------------------------
function GDImageWrapper:getHeight()
	local img = self._image
	return img:sizeY()
end


--===========================================================================--
--  Initialization
--===========================================================================--
return GDImageWrapper