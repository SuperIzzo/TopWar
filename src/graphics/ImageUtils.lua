--===========================================================================--
--  Dependencies
--===========================================================================--
local sqrt 					= math.sqrt
local BSpline				= require 'src.math.BSpline'
local Vector				= require 'src.math.Vector'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class ImagePointData2D : A point data wrapper around an image
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local ImagePointData2D = {}
ImagePointData2D.__index 	= ImagePointData2D;


-------------------------------------------------------------------------------
--  ImagePointData2D:new : Creates a new ImagePointData2D
-------------------------------------------------------------------------------
function ImagePointData2D:new( image )
	local obj = {}

	obj.image		= image;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  ImagePointData2D:GetDimension : Returns the dimension of the data
-------------------------------------------------------------------------------
function ImagePointData2D:GetDimension()
	return 2;
end


-------------------------------------------------------------------------------
--  ImagePointData2D:GetLimits : Returns the min and max of the array
-------------------------------------------------------------------------------
function ImagePointData2D:GetLimits( u )
	if u then
		return 1, self.image:getHeight();
	else
		return 1, self.image:getWidth();
	end
end


-------------------------------------------------------------------------------
--  ImagePointData2D:GetPoint : Returns point with the given index
-------------------------------------------------------------------------------
function ImagePointData2D:GetPoint( u, v )
	-- warp pixels in a vector
	local pixel = Vector:new( self.image:getPixel( u-1, v-1 ) );
	return pixel;
end



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class ImageUtils : general image processing routines 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local ImageUtils = {}
ImageUtils.__index = ImageUtils;


-------------------------------------------------------------------------------
--  ImageUtils.MakeNormalMap : Creates a new vector instance
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--   This algorithm tries to be as efficient as possible,  because the getPixel
--   and  setPixel routines  seem to be quite expensive.  First  we compute the 
--   horizontal, vertical and diagonal gradients and weight them using gaussian
--   distribution.
--   ________________   The gradient is computated using the kernel shown left.
--   | A0 | B0 | C0 |   C2 is the read cursor  where the new color is  obtained 
--   | A1 | B1 | C1 |   from the input image;  B1 is the write cursor where the 
--   | A2 | B2 | C2 |   generated gradients are stored in the output image. The
--   ----------------   loop operates vertically,  so the entire A and B colums
--     Fig. Kernel      from the input image as well as C0 and C1 need to be
--                      stored for later use.
--   To calculate the normal form a depth value the algorithm uses a few tricks
--   First, the normal is calculated in 2D space, for vertical gradient it uses
--   the YZ plane,  for horizontal XZ and for the diagonals -  diagonal planes.
--   2D normals are then easy to obtain: a 2D vector (i,j) has a normal (-j,i),
--   however  we know 'i' is 1 pixel  for the horizontal and vertical gradients
--   and for the diagonals it is 'sqrt(2)' (Pythagorean dist.). Because we know
--   the size and shape of the kernel  we can calculate 'i' in advance which is
--	 All 2D normal vectors are then summed, normalized and mapped to RGB range.
--   X, Y may assume negative values and are mapped to ranges 0-126 (negative) 
--   and 128-255 (for positive); Z can only ever be positive and is mapped to 
--   the full 0-255 range.
-------------------------------------------------------------------------------
function ImageUtils.DepthToNormalMap( inDepthData, outNormData, depthScale )	
	local width, height = inDepthData:getWidth(), inDepthData:getHeight();
	local depthScale = depthScale or 1;

	-- We need to store 2 columns of the original image
	local columnA = {}
	local columnB = {}

	-- Get the first column in advance
	for y = 0, height-1 do
		columnA[y] = inDepthData:getPixel( 0, y )*depthScale;
		columnB[y] = columnA[y];
	end	
	columnA[-1] = columnA[0]
	columnB[-1] = columnB[0]
	
	-- A few constants to help speed up the loop that's comming
	local diagonalWeight = 1/sqrt(2);
	local z = 1 + sqrt(2);
	local z_squared = z^2;
	local z_mul_255 = z*255;

	-- Process every pixel from the input image
	-- We poduce an image that is 4 rows and 4 colums smaller
	for x = 0, width-2 do	
		local C1 = inDepthData:getPixel( x, 0 )*depthScale;
		local C0 = C1;
		columnB[-1] = columnB[0];

		for y = 0, height-2 do
			local C2 = inDepthData:getPixel( x+1, y+1 )*depthScale;

			-- Diagonals have less weight
			local dg1 = ( columnA[y-1] - C2 ) * diagonalWeight;
			local dg2 = ( columnA[y+1] - C0 ) * diagonalWeight;

			-- We divide by 2 because of the symetry (8 neighbours, 4 pairs)
			local hr = (columnA[y] - C1 + dg1 + dg2)/2;
			local vr = (columnB[y-1] - columnB[y+1] + dg1 - dg2)/2;

			-- Update colors
			columnA[y-1] = columnB[y-1];	
			columnB[y-1] = C0;
			C0 = C1;
			C1 = C2;

			-- Length of the normal vector, needed for normalization
			local len = sqrt(hr^2 + vr^2 + z_squared )
			
			-- hr and vr need to be divided by len and multiplied by 127
			-- to turn into color space
			local term = 127/len;

			outNormData:setPixel( x, y,
			hr*term + 127, 
			vr*term + 127,
			z_mul_255/len,	
			255);
		end
	end
end


-------------------------------------------------------------------------------
--  ImageUtils.ScaleImage : Scales an image using a specified filter level
-------------------------------------------------------------------------------
function ImageUtils.ScaleImage( inImage, outImage, level )
	local bSpline = BSpline:new();
	local pointData = ImagePointData2D:new( inImage );
	local scaleX = outImage:getWidth()  / inImage:getWidth();
	local scaleY = outImage:getHeight() / inImage:getHeight();
	
	bSpline:SetPoints( pointData );
	bSpline:SetLevel( level );
	
	for x=0, outImage:getWidth()-1 do
		local scaledX = x/scaleX;
		
		for y=0, outImage:getHeight()-1 do
			local scaledY = y/scaleY;
			
			local pixel = bSpline:GetPoint( scaledX, scaledY );
			outImage:setPixel( x,y, pixel.x, pixel.y, pixel.z, 255 );
		end
	end
end




--===========================================================================--
--  Initialization
--===========================================================================--
return ImageUtils