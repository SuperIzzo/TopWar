--===========================================================================--
--  Dependencies
--===========================================================================--
local setmetatable 		= setmetatable
local floor				= math.floor




--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	GradientTestImage
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local GradientTestImage = {}
GradientTestImage.__index = GradientTestImage


-------------------------------------------------------------------------------
--  GradientTestImage:new : creates a gradient image
-------------------------------------------------------------------------------
function GradientTestImage:new( w, h, xstep, ystep, value )
	local obj = {};

	obj.width  = w;
	obj.height = h;
	obj.xstep = xstep;
	obj.ystep = ystep;
	obj.startVal = value or 0;

	return setmetatable( obj, self )
end 


-------------------------------------------------------------------------------
--  GradientTestImage:getWidth : returns the width of the image
-------------------------------------------------------------------------------
function GradientTestImage:getWidth()
	return self.width;
end


-------------------------------------------------------------------------------
--  GradientTestImage:getHeight : returns the height of the image
-------------------------------------------------------------------------------
function GradientTestImage:getHeight()
	return self.height;
end


-------------------------------------------------------------------------------
--  GradientTestImage:getSize : returns the width and the height of the image
-------------------------------------------------------------------------------
function GradientTestImage:getSize()
	return self.width, self.height;
end


-------------------------------------------------------------------------------
--  GradientTestImage:getPixel : return a gradient pixel based on ccords
-------------------------------------------------------------------------------
function GradientTestImage:getPixel( x, y )
	local value = 
			self.startVal
			+ floor(x)*self.xstep 
			+ floor(y)*self.ystep;

	value = floor( value );

	return value, value, value, 255;
end



--===========================================================================--
--  Initialization
--===========================================================================--
return GradientTestImage;