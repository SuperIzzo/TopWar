--===========================================================================--
--  Dependencies
--===========================================================================--
-- Modules
local Utils			= require 'src.math.Utils'

-- Aliases
local clamp			= Utils.Clamp
local bilerp		= Utils.Bilerp
local colorToNormal	= Utils.ColorToNormal
local floor			= math.floor
local assert		= assert


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Arena : The physical data and logic of a battle arena
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Arena = {}
Arena.__index = Arena;


-------------------------------------------------------------------------------
--  Arena:new : Creates a new arena
-------------------------------------------------------------------------------
function Arena:new( width, height, depth, depthMask, normMask )
	local obj = {}
	
	-- Shift arguments
	if type(width) == "table" then
		depthMask, normMask = width, height;
		width, height 		= nil, nil
	elseif type(height) == "table" then
		depthMask, normMask = height, depth;
		height, depth 		= nil, nil
	elseif type(depth) == "table" then
		depthMask, normMask = depth, depthMask;
		depth = nil;
	end
	
	obj._width	= width or 1024;
	obj._height = height or obj._width;
	obj._depth	= depth or 255;
	
	obj._depthMask  = depthMask;
	obj._normalMask = normMask;
	
	obj._tops = {};
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Arena:AddTop : Adds a top to the arena
-------------------------------------------------------------------------------
function Arena:AddTop( top )
	self._tops[ #self._tops+1 ] = top;
end


-------------------------------------------------------------------------------
--  Arena:Update : Updates the arena and all tops in it
-------------------------------------------------------------------------------
function Arena:Update( dt )
	for i = 1, #self._tops do
		local top = self._tops[i];
		
		local nx, ny, nz = self:GetNormal( top.x, top.y );
		top.xVelocity = top.xVelocity + nx;
		top.yVelocity = top.yVelocity + ny;
		
		top:Update( dt );
	end
end


-------------------------------------------------------------------------------
--  Arena:SetDepthMask : Sets the depth mask of the arena
-------------------------------------------------------------------------------
function Arena:SetDepthMask( mask )
	self._depthMask = mask;
end


-------------------------------------------------------------------------------
--  Arena:SetNormalMask : Sets the normal (incination) mask of the arena
-------------------------------------------------------------------------------
function Arena:SetNormalMask( mask )
	self._normalMask = mask;
end


-------------------------------------------------------------------------------
--  Arena:GetDepthMask : Returns the depth mask of the arena
-------------------------------------------------------------------------------
function Arena:GetDepthMask()
	return self._depthMask;
end


-------------------------------------------------------------------------------
--  Arena:GetNormalMask : Returns the normal (incination) mask of the arena
-------------------------------------------------------------------------------
function Arena:GetNormalMask()
	return self._normalMask;
end


-------------------------------------------------------------------------------
--  Arena:GetDepth : Returns the depth at a given point of the arena
-------------------------------------------------------------------------------
function Arena:GetDepth( x, y )
	local depthMask = assert( self._depthMask );
	local EPSILON = 0.000000001
	
	local unitX = x/(self._width-1);
	local unitY = y/(self._height-1);
	unitX = clamp(unitX, 0, 1-EPSILON );
	unitY = clamp(unitY, 0, 1-EPSILON );
	
	local depthX = unitX * ( depthMask:getWidth()-1  );
	local depthY = unitY * ( depthMask:getHeight()-1 );
	
	local depthLowX = floor(depthX);
	local depthLowY = floor(depthY);
	
	local a0 = depthMask:getPixel( depthLowX  ,   depthLowY   );
	local b0 = depthMask:getPixel( depthLowX+1,   depthLowY   );
	local a1 = depthMask:getPixel( depthLowX  ,   depthLowY+1 );
	local b1 = depthMask:getPixel( depthLowX+1,   depthLowY+1 );
	local weight1 = depthX - depthLowX ;
	local weight2 = depthY - depthLowY;

	return bilerp( a0, b0, a1, b1, weight1, weight2 );
end



-------------------------------------------------------------------------------
--  Arena:GetNormal : Returns the normal at a given point of the arena
-------------------------------------------------------------------------------
function Arena:GetNormal( x, y )
	local normalMask = assert( self._normalMask );
	local EPSILON = 0.000000001
	
	local unitX = x/(self._width-1);
	local unitY = y/(self._height-1);
	unitX = clamp(unitX, 0, 1-EPSILON );
	unitY = clamp(unitY, 0, 1-EPSILON );
	
	local normX = unitX * ( normalMask:getWidth()-1  );
	local normY = unitY * ( normalMask:getHeight()-1 );
	
	local normLowX = floor(normX);
	local normLowY = floor(normY);
	
	local a0x, a0y, a0z = normalMask:getPixel( normLowX  ,   normLowY   );
	local b0x, b0y, b0z = normalMask:getPixel( normLowX+1,   normLowY   );
	local a1x, a1y, a1z = normalMask:getPixel( normLowX  ,   normLowY+1 );
	local b1x, b1y, b1z = normalMask:getPixel( normLowX+1,   normLowY+1 );
	local weight1 = normX - normLowX ;
	local weight2 = normY - normLowY;

	local r, g, b =
			bilerp( a0x, b0x, a1x, b1x, weight1, weight2 ),
			bilerp( a0y, b0y, a1y, b1y, weight1, weight2 ),
			bilerp( a0z, b0z, a1z, b1z, weight1, weight2 );
			
	return colorToNormal( r, g, b );
end



--===========================================================================--
--  Initialization
--===========================================================================--
return Arena