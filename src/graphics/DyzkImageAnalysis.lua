--===========================================================================--
--  Dependencies
--===========================================================================--
local Vector		= require 'src.math.Vector'
local PolarVector	= require 'src.math.PolarVector'
local MathUtils		= require 'src.math.MathUtils'

local max			= math.max
local log			= math.log
local floor			= math.floor
local asin			= _G.math.asin
local pi			= _G.math.pi
local clamp			= MathUtils.Clamp
local warp			= MathUtils.Warp


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class DyzkImageAnalysis: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local DyzkImageAnalysis = {}
DyzkImageAnalysis.__index = DyzkImageAnalysis;


-------------------------------------------------------------------------------
--  DyzkImageAnalysis constants
-------------------------------------------------------------------------------
DyzkImageAnalysis.GRAMS_PER_PIXEL			= 0.001;
DyzkImageAnalysis.EFFECTIVE_ALPHA_THRESHOLD = 125


-------------------------------------------------------------------------------
--  DyzkImageAnalysis:new : Creates a new DyzkImageAnalysis
-------------------------------------------------------------------------------
function DyzkImageAnalysis:new()
	local obj = {}
	
	obj._imageData	= nil;
	obj._scale		= nil;
	obj._angleSpan	= nil;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  DyzkImageAnalysis:AnalyzeImage : Analyzes image data and computes stats
-------------------------------------------------------------------------------
function DyzkImageAnalysis:AnalyzeImage( imgData, scale )
	local scale 	= scale or 1;	
	
	local imgSize			= Vector:new(	imgData:getWidth(),
											imgData:getHeight() );
	local scaledImgSize 	= imgSize * scale;
	local halfScaledSize	= scaledImgSize/2;
	
	-- Limit the angle loop to 1 pixel from a specific circle of precision
	-- angSpan is an integer number that maps angles to a new range based on
	-- the radius of precision, as interger 0..360 may leave a lot of holes
	local radiusOfPrecision = max( halfScaledSize.x, halfScaledSize.y );
	local angSpan = pi*2 / asin( 1/radiusOfPrecision );
	
	local maxRad = 0;
	local allRads = {};
	local numOpaquePixels = 0;
	local centerOfMass = Vector:new(0,0);
	
	local polarImage = {}
	
	for pxX = 0, scaledImgSize.x-1 do
		for pxY = 0, scaledImgSize.y-1 do			
			local r, g, b, a = imgData:getPixel( pxX/scale, pxY/scale );									
			
			-- Concern only with opaque pixels
			if a > self.EFFECTIVE_ALPHA_THRESHOLD then				
				-- Count the number of non-transparent pixels
				numOpaquePixels = numOpaquePixels + 1;
				
				-- Accumulate coordinates
				centerOfMass.x = centerOfMass.x + pxX;
				centerOfMass.y = centerOfMass.y + pxY;
			
				-- Turn into polar coordinates, so that we can collect radiuses
				local polCoord = PolarVector:new();
				polCoord:FromCartesian( pxX - halfScaledSize.x,
										pxY - halfScaledSize.y );
				
				-- Angle index - converted from radiants to a custom integer scale
				local angIdx = floor( polCoord.a/(pi*2) * angSpan );
			
				-- Compare the max radius
				if polCoord.r > maxRad then
					maxRad = polCoord.r;
				end
								
				-- Collect all radiuses				
				if (not allRads[angIdx]) or (polCoord.r > allRads[angIdx]) then
					allRads[angIdx] = polCoord.r;
				end
				
				-- Store the image for later
				polarImage[angIdx] = polarImage[angIdx] or {};				
				polarImage[angIdx][r] = {r,g,b,a}
			end
		end
	end
	
	
	-- Calculate center of mass
	centerOfMass = centerOfMass/numOpaquePixels;	
	
	self._imageData			= imgData;
	self._imageSize			= imgSize;
	self._scale 			= scale;
	self._angleSpan			= angSpan;
	self._numOpaquePixels	= numOpaquePixels;
	self._centerOfMass		= centerOfMass;
	self._radiuses			= allRads;
	self._maxRadius			= maxRad;
end


-------------------------------------------------------------------------------
--  DyzkImageAnalysis:GetOriginalImageSize : Returns the image size (prescaled)
-------------------------------------------------------------------------------
function DyzkImageAnalysis:GetOriginalImageSize()
	return self._imageSize;
end


-------------------------------------------------------------------------------
--  DyzkImageAnalysis:GetImageSize : Returns the image size (after scaling)
-------------------------------------------------------------------------------
function DyzkImageAnalysis:GetImageSize()
	return self:GetOriginalImageSize() * self:GetImageScale();
end


-------------------------------------------------------------------------------
--  DyzkImageAnalysis:GetImageScale : Returns the image scaling
-------------------------------------------------------------------------------
function DyzkImageAnalysis:GetImageScale()
	return self._scale;
end


-------------------------------------------------------------------------------
--  DyzkImageAnalysis:GetNumOpaquePixels : Returns number of opaque pixels
-------------------------------------------------------------------------------
function DyzkImageAnalysis:GetNumOpaquePixels()
	return self._numOpaquePixels;
end


-------------------------------------------------------------------------------
--  DyzkImageAnalysis:GetWeight : Returns the weight of the dyzk
-------------------------------------------------------------------------------
function DyzkImageAnalysis:GetWeight()
	return self:GetNumOpaquePixels() * self.GRAMS_PER_PIXEL;
end


-------------------------------------------------------------------------------
--  DyzkImageAnalysis:GetCenterOfMass : Returns the center of the mass
-------------------------------------------------------------------------------
function DyzkImageAnalysis:GetCenterOfMass()
	return self._centerOfMass;
end


-------------------------------------------------------------------------------
--  DyzkImageAnalysis:GetCenterOfMass : Returns the balance
-------------------------------------------------------------------------------
function DyzkImageAnalysis:GetBalance()	
	local maxRad				= self:GetMaxRadius();
	local centerOfRotation  	= self:GetImageSize()/2;
	local centerOfMass			= self:GetCenterOfMass();
	
	-- Calculate balance as 1- the offset of the center fo mass from the pivot
	local massOffset = (centerOfMass - centerOfRotation):Length();
	local balance = 1 - massOffset/maxRad;
	balance = clamp( balance, 0, 1 );
	
	return balance;
end


-------------------------------------------------------------------------------
--  DyzkImageAnalysis:GetAngleSpan : Returns the angle span 
-------------------------------------------------------------------------------
function DyzkImageAnalysis:GetAngleSpan()
	return self._angleSpan;
end


-------------------------------------------------------------------------------
--  DyzkImageAnalysis:GetMaxRadius : Returns the maximal dyzk radius found
-------------------------------------------------------------------------------
function DyzkImageAnalysis:GetMaxRadius()
	return self._maxRadius;
end


-------------------------------------------------------------------------------
--  DyzkImageAnalysis:GetRadiusAS : Returns the maximal dyzk radius found
-------------------------------------------------------------------------------
function DyzkImageAnalysis:GetRadiusAS( angle )
	if self._radiuses then		
		local angle = floor(angle);
		angle = warp( angle, 0, self:GetAngleSpan() );
		
		return self._radiuses[angle] or 0;
	end
end


-------------------------------------------------------------------------------
--  DyzkImageAnalysis:GetJaggedness : Returns the jaggedness of the dyzk
-------------------------------------------------------------------------------
function DyzkImageAnalysis:GetJaggedness()
	if self._jaggedness then
		return self._jaggedness;
	end
	
	local jag = 0;
	local maxRad = self:GetMaxRadius();
		
	-- Sum up jaggedness from all angles
	-- Logarithms ensure that jagedness is only effetive at the contour		
	for ang =0, self:GetAngleSpan() do			
		local difference = maxRad - self:GetRadiusAS(ang);
		
		-- tolerate a difference of up to 2 pixels
		difference = max(difference-2, 0);
		
		jag = jag + log( difference + 1);
	end
	
	-- Normalize:
	jag = jag / self:GetAngleSpan()  -- divide by the number of angle measures
	jag = jag / log(128)			 -- rebase the log at 128 (adjustable)
	jag = clamp( jag, 0, 1 );		 -- clamp to (0.0, 1.0)
	
	self._jaggedness = jag;	
	return jag;
end


--===========================================================================--
--  Initialization
--===========================================================================--
return DyzkImageAnalysis