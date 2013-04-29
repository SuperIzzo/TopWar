--===========================================================================--
--  Dependencies
--===========================================================================--
local PolarVector	= require 'src.math.PolarVector'

local assert 		= _G.assert
local sqrt			= _G.math.sqrt
local log			= _G.math.log
local max			= _G.math.max
local floor			= _G.math.floor
local asin			= _G.math.asin
local pi			= _G.math.pi

local log2			= log(2);




--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Top : A spinning top object
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Top =
{
}


-------------------------------------------------------------------------------
--  Top:new : Creates a new top instance
-------------------------------------------------------------------------------
function Top:new()
	local obj = {}
	
	obj._weigth 	= 0;
	obj._jaggedness = 0;
	obj._radius 	= 0;
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Top:GetWeight : Returns the weight of the top
-------------------------------------------------------------------------------
function Top:GetWeight()
	return self._weigth;
end


-------------------------------------------------------------------------------
--  Top:GetJaggedness : Returns the jaggedness of the top
-------------------------------------------------------------------------------
function Top:GetJaggedness()
	return self._jaggedness;
end


-------------------------------------------------------------------------------
--  Top:GetRadius : Returns the radius of the top
-------------------------------------------------------------------------------
function Top:GetRadius()
	return self._radius;
end


-------------------------------------------------------------------------------
--  Top:SetWeight : Sets the weight of the top
-------------------------------------------------------------------------------
function Top:SetWeight( weigth )
	assert( weigth >= 0 )
	
	self._weigth = weigth;
end


-------------------------------------------------------------------------------
--  Top:SetJaggedness : Sets the jaggedness of the top
-------------------------------------------------------------------------------
function Top:SetJaggedness( jag )
	assert( jag >= 0 )
	
	self._jaggedness = jag;
end


-------------------------------------------------------------------------------
--  Top:SetRadius : Sets the radius of the top
-------------------------------------------------------------------------------
function Top:SetRadius( rad )
	assert( rad >= 0 )
	
	self._radius = rad;
end


-------------------------------------------------------------------------------
--  Top:SetImage : Sets the properties of a tpp from an image
-------------------------------------------------------------------------------
function Top:SetImage( imgData )
	local imgWidth  = imgData:getWidth();
	local imgHeight = imgData:getHeight();
	
	local halfWidth  = imgWidth/2;
	local halfHeight = imgHeight/2;
	local radSpan = sqrt( halfWidth*halfWidth + halfHeight*halfHeight );
	
	-- Limit the angle loop to 1 pixel from a specific circle of precision 
	-- angSpan is an integer number that maps angles to a new range based on the
	-- radius of precision, because interger 0..360 may leave a lot of holes
	local radiusOfPrecision = max(halfWidth, halfHeight);
	local angSpan = pi*2 / asin( 1/radiusOfPrecision );
	
	local maxRad = 0;
	local allRads = {};
	
	for pxX = 0, imgWidth-1 do
		for pxY = 0, imgHeight-1 do
			local _, _, _, a = imgData:getPixel( pxX, pxY );
			
			if a > 125 then
				local polCoord = PolarVector:new();
				polCoord:FromCartesian( pxX - halfWidth, pxY - halfHeight );
			
				-- Compare the max radius
				if polCoord.r > maxRad then
					maxRad = polCoord.r;
				end
				
				-- Collect all radiuses
				local angIdx = floor( polCoord.a/(pi*2) * angSpan );
				if (not allRads[angIdx]) or (polCoord.r > allRads[angIdx]) then
					allRads[angIdx] = polCoord.r;
				end
			end
		end
	end
	
	local jag = 0;
	local rad = maxRad;
	
	-- Sum up jaggedness from all angles
	for ang =0, angSpan do
		rad = allRads[ang] or 0;
		jag = jag + log( maxRad - rad + 1);
	end
	
	-- Normalize
	jag = jag / (angSpan * log(128))
	
	self:SetRadius( maxRad );
	self:SetJaggedness( jag );
end





--===========================================================================--
--  Initialization
--===========================================================================--
Top.__index = Top;

return Top