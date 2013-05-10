--===========================================================================--
--  Dependencies
--===========================================================================--
-- Modules
local PolarVector	= require 'src.math.PolarVector'
local Vector		= require 'src.math.Vector'
local Utils			= require 'src.math.Utils'

-- Aliases
local assert 		= assert
local sqrt			= math.sqrt
local log			= math.log
local max			= math.max
local floor			= math.floor
local clamp			= Utils.Clamp
local asin			= math.asin
local pi			= math.pi





--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Top : The physical data and logic of a spinning top object
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Top = {}
Top.__index = Top;


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--  Local donstants
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local EFFECTIVE_ALPHA_THRESHOLD = 125


-------------------------------------------------------------------------------
--  Top:new : Creates a new top instance
-------------------------------------------------------------------------------
function Top:new()
	local obj = {}
	
	-- Physics
	obj.x = 0;
	obj.y = 0;
	obj.xVelocity = 0;
	obj.yVelocity = 0;	
	
	-- Statistics
	obj._weigth 	= 0;
	obj._jaggedness = 0;
	obj._radius 	= 0;
	obj._balance	= 0;
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Top:Update : Updates the top position
-------------------------------------------------------------------------------
function Top:Update( dt )
	self.x = self.x + self.xVelocity*dt;
	self.y = self.y + self.yVelocity*dt;
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
--  Top:GetRadius : Returns the radius of the top
-------------------------------------------------------------------------------
function Top:GetBalance()
	return self._balance;
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
	assert( jag >= 0 and jag <= 1 )
	
	self._jaggedness = jag;
end


-------------------------------------------------------------------------------
--  Top:SetBalance : Sets the balance of the top
-------------------------------------------------------------------------------
function Top:SetRadius( rad )
	assert( rad >= 0 )
	
	self._radius = rad;
end


-------------------------------------------------------------------------------
--  Top:SetBalance : Sets the balance of the top
-------------------------------------------------------------------------------
function Top:SetBalance( balance )
	assert( balance >= 0 and balance <= 1)
	
	self._balance = balance;
end


-------------------------------------------------------------------------------
-- Top:SetFromImageData : Sets the properties of a top from an image
-------------------------------------------------------------------------------
function Top:SetFromImageData( imgData )
	local imgSize	= Vector:new( imgData:getWidth(), imgData:getHeight() );	
	local halfSize	= imgSize/2;
	local radSpan	= halfSize:Length();
	
	-- Limit the angle loop to 1 pixel from a specific circle of precision 
	-- angSpan is an integer number that maps angles to a new range based on
	-- the radius of precision, as interger 0..360 may leave a lot of holes
	local radiusOfPrecision = max( halfSize.x, halfSize.y );
	local angSpan = pi*2 / asin( 1/radiusOfPrecision );
	
	local maxRad = 0;
	local allRads = {};
	local numPixels = 0;
	local centerOfMass = Vector:new(0,0);
	local balanceY = 0;
	
	for pxX = 0, imgSize.x-1 do
		for pxY = 0, imgSize.y-1 do
			local _, _, _, a = imgData:getPixel( pxX, pxY );			
			
			if a > EFFECTIVE_ALPHA_THRESHOLD then				
				-- Count the number of non-transparent pixels
				numPixels = numPixels + 1;
				
				-- Accumulate coordinates
				centerOfMass.x = centerOfMass.x + pxX;
				centerOfMass.y = centerOfMass.y + pxY;
			
				-- Turn into polar coordinates, so that we can collect radiuses
				local polCoord = PolarVector:new();
				polCoord:FromCartesian( pxX - halfSize.x, pxY - halfSize.y );
			
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

	-- Sum up jaggedness from all angles
	-- Logarithms ensure that jagedness is only effetive at the contour	
	local jag = 0;
	for ang =0, angSpan do
		local rad = allRads[ang] or 0;
		jag = jag + log( maxRad - rad + 1);
	end
	
	-- Normalize
	jag = jag / (angSpan * log(128))
	jag = clamp( jag, 0, 1 );	
	
	-- Calculate center of mass
	centerOfMass = centerOfMass/numPixels;
	
	-- Calculate balance as 1 - the normalized offset of the center of the mass
	local balance = 1 - (centerOfMass - halfSize):Length()/maxRad;
	balance = clamp( balance, 0, 1 );
	
	-- Normalize ( base unit will be grams, each 1px = 1mg )
	local weight = numPixels/1000; 	
	
	self:SetRadius( maxRad );
	self:SetJaggedness( jag );
	self:SetWeight( weight );
	self:SetBalance( balance );
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Top