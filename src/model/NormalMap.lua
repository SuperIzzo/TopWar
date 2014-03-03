--===========================================================================--
--  Dependencies
--===========================================================================--
local Array2D			= require 'src.util.Array2D'
local ImageData			= require 'src.graphics.ImageData'
local ImageUtils		= require 'src.graphics.ImageUtils'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class NormalMap: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local NormalMap = {}
NormalMap.__index = NormalMap;


-------------------------------------------------------------------------------
--  NormalMap:new : Creates a new NormalMap
-------------------------------------------------------------------------------
function NormalMap:new()
	local obj = {}

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  NormalMap:Get : Returns the depth at x, y
-------------------------------------------------------------------------------
function NormalMap:Get(x, y)
	return self.map:Get(x, y);
end


-------------------------------------------------------------------------------
--  NormalMap:Set : Sets the depth at x, y
-------------------------------------------------------------------------------
function NormalMap:Set(x, y, vec)
	return self.map:Set(x, y, vec);
end


-------------------------------------------------------------------------------
--  NormalMap:GetWidth : Returns the width of the height map
-------------------------------------------------------------------------------
function NormalMap:GetWidth()
	return self.map:GetWidth();
end


-------------------------------------------------------------------------------
--  NormalMap:GetHeight : Returns the height of the height map
-------------------------------------------------------------------------------
function NormalMap:GetHeight()
	return self.map:GetHeight();
end


-------------------------------------------------------------------------------
--  NormalMap:LoadFromImageData : Creates a new NormalMap
-------------------------------------------------------------------------------
function NormalMap:LoadFromImageData( imgData )	
	self.map = Array2D:new( imgData:getDimensions() );
	
	local normalImg = ImageData:new( self.map );
	normalImg:paste( imgData );
end


-------------------------------------------------------------------------------
--  NormalMap:GenerateFromHeightMap : Creates a new NormalMap
-------------------------------------------------------------------------------
function NormalMap:GenerateFromHeightMap( heightMap )
	local heightImage = ImageData:new( heightMap );
	self.map = Array2D:new( heightImage:getDimensions() );
	local normalImage = ImageData:new( self.map );
	
	ImageUtils.DepthToNormalMap( heightImage, normalImage )
end


--===========================================================================--
--  Initialization
--===========================================================================--
return NormalMap