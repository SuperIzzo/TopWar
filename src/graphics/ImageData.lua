--===========================================================================--
--  Dependencies
--===========================================================================--



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class ImageData: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local ImageData = {}
ImageData.__index = ImageData;


-------------------------------------------------------------------------------
--  ImageData:new : Creates a new ImageData
-------------------------------------------------------------------------------
function ImageData:new( width, height)
	local obj = {}
	
	obj.width	= width; 
	obj.height	= height;
	obj.pixels	= {};

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  ImageData:getHeight : Returns the height of the image
-------------------------------------------------------------------------------
function ImageData:getHeight()
	return self.height;
end


-------------------------------------------------------------------------------
--  ImageData:getWidth : Returns the height of the image
-------------------------------------------------------------------------------
function ImageData:getWidth()
	return self.width;
end


-------------------------------------------------------------------------------
--  ImageData:getDimensions : Returns the width and height of the image
-------------------------------------------------------------------------------
function ImageData:getDimensions()
	return self.width, self.height;
end


-------------------------------------------------------------------------------
--  ImageData:getPixel : Returns the height of the image
-------------------------------------------------------------------------------
function ImageData:_getCoordsIndex(x,y)
	if x<0 or x>=self.width or y<0 or y>=self.height then
		error( "Pixel out of bounds" );
	end
	
	return x + y*self.width;
end


-------------------------------------------------------------------------------
--  ImageData:getPixel : Returns the height of the image
-------------------------------------------------------------------------------
function ImageData:getPixel(x,y)
	local pixelIdx = self:_getCoordsIndex(x,y)
	local pixel = self.pixels[pixelIdx];
	
	if pixel then
		return pixel[1], pixel[2], pixel[3], pixel[4];
	else
		return 0,0,0,0;
	end
end


-------------------------------------------------------------------------------
--  ImageData:setPixel : Sets a pixel in the image
-------------------------------------------------------------------------------
function ImageData:setPixel(x,y, r,g,b,a)
	local pixelIdx = self:_getCoordsIndex(x,y)
	local pixel = self.pixels[pixelIdx] or {};
	
	pixel[1] = r;
	pixel[2] = g;
	pixel[3] = b;
	pixel[4] = a or 255;
	
	self.pixels[pixelIdx] = pixel;
end


-------------------------------------------------------------------------------
--  ImageData:copy : Copies the image to another image
-------------------------------------------------------------------------------
function ImageData.copy( source, dest, dx, dy, sx, sy, sw, sh )
	for x = 1, sw do
		for y = 1, sh do
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