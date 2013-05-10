--===========================================================================--
--  Dependencies
--===========================================================================--
-- Aliases
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
function GradientTestImage:new( w, h,
								xstep, ystep, value, 	 -- red
								xstep2, ystep2, value2,  -- green
								xstep3, ystep3, value3 ) -- blue
	local obj = {};

	obj.width  = w;
	obj.height = h;
	
	-- Red
	obj.xstep = xstep;	
	obj.ystep = ystep;
	obj.startVal = value or 0;
	
	--Green
	obj.xstep2 = xstep2 or obj.xstep;
	obj.ystep2 = ystep2 or obj.ystep;
	obj.startVal2 = value2 or obj.startVal;
	
	-- Blue
	obj.xstep3 = xstep3 or obj.xstep;
	obj.ystep3 = ystep3 or obj.ystep;		
	obj.startVal3 = value3 or obj.startVal;

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
	local value1 = 
			self.startVal
			+ floor(x)*self.xstep 
			+ floor(y)*self.ystep;
	value1 = floor( value1 );
	
	local value2 = 
			self.startVal2
			+ floor(x)*self.xstep2 
			+ floor(y)*self.ystep2;
	value2 = floor( value2 );
	
	local value3 = 
			self.startVal3
			+ floor(x)*self.xstep3 
			+ floor(y)*self.ystep3;
	value3 = floor( value3 );

	return value1, value2, value3, 255;
end



--===========================================================================--
--  Initialization
--===========================================================================--
return GradientTestImage;