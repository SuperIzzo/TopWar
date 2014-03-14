--===========================================================================--
--  Dependencies
--===========================================================================--
local Array2D			= require 'src.util.collection.Array2D'
local MathUtils 		= require 'src.math.MathUtils'
local ImageData			= require 'src.graphics.ImageData'
local ImageUtils		= require 'src.graphics.ImageUtils'

local clamp				= MathUtils.Clamp;
local bilerp			= MathUtils.Bilerp;
local floor				= math.floor
local ceil				= math.ceil


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
--  NormalMap:Set : Sets the depth at x, y
-------------------------------------------------------------------------------
function NormalMap:Set(x, y, vec)
	return self.map:Set(x, y, vec);
end


-------------------------------------------------------------------------------
--  NormalMap:Get : Returns the depth at x, y
-------------------------------------------------------------------------------
function NormalMap:Get(x, y)
	local width = self.map:GetWidth();
	local height = self.map:GetHeight();
	
	if x>=0 and x<=width-2 and y>=0 and y<=height-2 then
		local ax, ay = floor(x), floor(y);
		local bx, by = ax+1, ay+1;
		local t1, t2 = x - ax, y - ay;
		
		if t1 == 0 and t2 == 0 then
			return self.map:Get(ax,ay);
		else					
			local n00_x, n00_y, n00_z = unpack( self.map:Get(ax,ay) or {0,0,0} );
			local n01_x, n01_y, n01_z = unpack( self.map:Get(ax,by) or {0,0,0} );
			local n10_x, n10_y, n10_z = unpack( self.map:Get(bx,ay) or {0,0,0} );
			local n11_x, n11_y, n11_z = unpack( self.map:Get(bx,by) or {0,0,0} );
			
			local nx = bilerp( n00_x, n01_x, n10_x, n11_x, t1, t2 );
			local ny = bilerp( n00_y, n01_y, n10_y, n11_y, t1, t2 );
			local nz = bilerp( n00_z, n01_z, n10_z, n11_z, t1, t2 );
			
			return {nx, ny, nz}
		end
	else
		return {127,127,0};
	end
end


-------------------------------------------------------------------------------
--  NormalMap:Get : Returns the depth at x, y
-------------------------------------------------------------------------------
function NormalMap:GetNormal(x, y)
	local normal = self:Get( x, y );
	
	normal[1] = (normal[1] - 127)/255;
	normal[2] = (normal[2] - 127)/255;
	normal[3] = (   normal[3]   )/255;
	
	return normal;
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
function NormalMap:GenerateFromHeightMap( heightMap, depth )
	local heightImage = ImageData:new( heightMap );
	self.map = Array2D:new( heightImage:getDimensions() );
	local normalImage = ImageData:new( self.map );
	
	ImageUtils.DepthToNormalMap( heightImage, normalImage, depth )
end


--===========================================================================--
--  Initialization
--===========================================================================--
return NormalMap