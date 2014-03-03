--===========================================================================--
--  Dependencies
--===========================================================================--
local Byter				= require 'src.util.Byter'
local Array2D			= require 'src.util.Array2D'

local uint2bytes		= Byter.UIntegerToBytes
local bytes2uint		= Byter.BytesToUInteger
local double2bytes		= Byter.DoubleToBytes
local bytes2double		= Byter.BytesToDouble

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class HeightMap : a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local HeightMap = {}
HeightMap.__index = HeightMap;


-------------------------------------------------------------------------------
--  HeightMap:new : Creates a new HeightMap
-------------------------------------------------------------------------------
function HeightMap:new()
	local obj = {}
	
	obj.map = nil

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  HeightMap:CreateEmpty : Creates an empty height map
-------------------------------------------------------------------------------
function HeightMap:CreateEmpty( w, h )
	self.map = Array2D:new( w, h );
end


-------------------------------------------------------------------------------
--  HeightMap:Get : Returns the depth at x, y
-------------------------------------------------------------------------------
function HeightMap:Get(x, y)
	return self.map:Get(x, y);
end


-------------------------------------------------------------------------------
--  HeightMap:Set : Sets the depth at x, y
-------------------------------------------------------------------------------
function HeightMap:Set(x, y, depth)
	assert( type(depth) == "number" );
	return self.map:Set(x, y, depth);
end


-------------------------------------------------------------------------------
--  HeightMap:GetWidth : Returns the width of the height map
-------------------------------------------------------------------------------
function HeightMap:GetWidth()
	return self.map:GetWidth();
end


-------------------------------------------------------------------------------
--  HeightMap:GetHeight : Returns the height of the height map
-------------------------------------------------------------------------------
function HeightMap:GetHeight()
	return self.map:GetHeight();
end


-------------------------------------------------------------------------------
--  HeightMap:LoadFromFile : Loads the data from a binary file
-------------------------------------------------------------------------------
function HeightMap:LoadFromFile( file )
	
	local sig = file:read(4);
	if sig == "fid\1" then
		local widthB  = file:read(4);
		local heightB = file:read(4);
		local width  = bytes2uint( widthB  );
		local height = bytes2uint( heightB );
		
		local rawData = {}
		for i = 1, width*height do		
			local depthB = file:read(8);
			rawData[i] = bytes2double( depthB );
		end
			
		self.map = Array2D:new( width, height, rawData );
	end
end


-------------------------------------------------------------------------------
--  HeightMap:SaveToFile : Loads the data from a binary file
-------------------------------------------------------------------------------
function HeightMap:SaveToFile( file )
	local char = string.char;
	
	file:write( "fid\1" );
	file:write( char( uint2bytes(self.map:GetWidth(),4))  );
	file:write( char( uint2bytes(self.map:GetHeight(),4)) );
	
	for depth in self.map:Items() do
		file:write( char(double2bytes( depth )) );
	end
	
	file:flush();
end


-------------------------------------------------------------------------------
--  HeightMap:LoadFromImageData : Sets the depth from image data
-------------------------------------------------------------------------------
function HeightMap:LoadFromImageData( img )
	self.map = Array2D:new( img:getWidth(), img:getHeight() );
	
	for x=0, img:getWidth()-1 do
		for y=0, img:getHeight()-1 do
			-- use just the red channel
			local depth = img:getPixel(x,y);
			self:Set( x, y, depth );
		end
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return HeightMap