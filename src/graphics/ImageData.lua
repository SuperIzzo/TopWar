--===========================================================================--
--  Dependencies
--===========================================================================--
local Array2D			= require 'src.util.collection.Array2D'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class ImageData: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local ImageData = {}
ImageData.__index = ImageData;


-------------------------------------------------------------------------------
--  ImageData:new : Creates a new ImageData
-------------------------------------------------------------------------------
function ImageData:new( width, height )
	local obj = {}

	if type(width) == "number" then
		obj.data = Array2D:new( width, height )
	elseif type(width) == "table" then
		obj.data = width;
	end

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  ImageData:getHeight : Returns the height of the image
-------------------------------------------------------------------------------
function ImageData:getHeight()
	return self.data:GetHeight();
end


-------------------------------------------------------------------------------
--  ImageData:getWidth : Returns the height of the image
-------------------------------------------------------------------------------
function ImageData:getWidth()
	return self.data:GetWidth();
end


-------------------------------------------------------------------------------
--  ImageData:getDimensions : Returns the width and height of the image
-------------------------------------------------------------------------------
function ImageData:getDimensions()
	return self:getWidth(), self:getHeight();
end


-------------------------------------------------------------------------------
--  ImageData:getPixel : Returns the height of the image
-------------------------------------------------------------------------------
function ImageData:getPixel(x,y)
	local pixel = self.data:Get( x, y );
	
	if type(pixel) == "table" then
		return pixel[1], pixel[2], pixel[3], (pixel[4] or 255);
	elseif type(pixel) == "number" then
		return pixel, pixel, pixel, 255;
	else
		return 0,0,0,0;
	end
end


-------------------------------------------------------------------------------
--  ImageData:setPixel : Sets a pixel in the image
-------------------------------------------------------------------------------
function ImageData:setPixel(x,y, r,g,b,a)
	local pixel = self.data:Get( x, y )
	
	if type(pixel) == "table" then
		pixel[1] = r;
		pixel[2] = g;
		pixel[3] = b;
		pixel[4] = a;
	elseif type(pixel) == "number" then
		self.data:Set( x, y, r );	
	else
		self.data:Set( x, y, { r, g, b, a } );
	end	
end


-------------------------------------------------------------------------------
--  ImageData:copy : Copies the image to another image
-------------------------------------------------------------------------------
function ImageData.copy( source, dest, dx, dy, sx, sy, sw, sh )
	local dx, dy = (dx or 0), (dy or 0);
	local sx, sy = (sx or 0), (sy or 0); 
	local sw, sh = (sw or source:getWidth()), (sh or source:getHeight());
	
	for x = 0, sw-1 do
		for y = 0, sh-1 do
			dest:setPixel( dx+x, dy+y, source:getPixel(sx+x, sy+y) );
		end
	end
end


-------------------------------------------------------------------------------
--  ImageData:paste : Pastes into the image from another image
-------------------------------------------------------------------------------
function ImageData.paste( dest, source, ... )
	return ImageData.copy( source, dest, ... );
end


--===========================================================================--
--  Initialization
--===========================================================================--
return ImageData;