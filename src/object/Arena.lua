--===========================================================================--
--  Dependencies
--===========================================================================--
local ArenaModel			= require 'src.model.ArenaModel'
local HeightMap				= require 'src.model.HeightMap'
local NormalMap				= require 'src.model.NormalMap'
local ImageUtils 			= require 'src.graphics.ImageUtils'
local ImageData 			= require 'src.graphics.ImageData'

local Array					= require 'src.util.Array'
local Vector				= require 'src.math.Vector'



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Arena : An arena game object
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Arena = {}
Arena.__index = Arena;


-------------------------------------------------------------------------------
--  Arena:new : Creates a new arena game object
-------------------------------------------------------------------------------
function Arena:new( arenaPath, width, height, depth )
	local obj = {}
	
	self:_InitOneTime();
			
	obj.image = nil;
	obj.model = ArenaModel:new();
	obj.dyzx = {};
	
	---------------------------
	local model = obj.model;
	
	local heightMap = self:LoadHeightMap( arenaPath, width, height );
	local normalMap = self:LoadNormalMap( arenaPath, width, height, heightMap );
	obj.image = love.graphics.newImage( arenaPath .. "/image.png" );
	
	model:SetDepthMask( heightMap );
	model:SetNormalMask( normalMap );
	
	self.SetSize( obj, width, height, depth );
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  Arena:_InitOneTime : Loads common resoources
-------------------------------------------------------------------------------
function Arena:_InitOneTime()
	if self._classInitialised then
		return
	end
	self._classInitialised = true;
	
	if love.graphics.isSupported( "shader" ) then
		local shaderCode = love.filesystem.read( "data/gfx/shaders/lighting.frag" );
		local ok, shader = pcall( love.graphics.newShader, shaderCode );
		
		if ok then
			self._lightingShader = shader;
		else
			print( shader );
		end
		
	end
end


-------------------------------------------------------------------------------
--  Arena:LoadHeightMap : Loads the height map of the arena
-------------------------------------------------------------------------------
function Arena:LoadHeightMap( arenaPath, width, height )
	local heightMap = nil
	local fidPath = arenaPath .. "/depth.fid";	
		
	-- Try loading from a fid file
	if not heightMap then		
		local heightMapFile = io.open(fidPath, "rb");
		if heightMapFile then
			heightMap = HeightMap:new();
			heightMap:LoadFromFile( heightMapFile );
			heightMapFile:close();
		end
	end
	
	-- Try loading and running a generator
	if not heightMap then
		local ok, loader;	
		ok, loader = pcall( love.filesystem.load, arenaPath .. "/depth.lua" );
		ok = ok and loader or false;
		
		local generator, env;
		if ok then			
			env = {}
			env.math = {};
			env.math.sin = math.sin;
			env.math.cos = math.cos;
			env.math.pi  = math.pi;
			env.print	 = print;
			
			setfenv( loader, env );
			ok, generator = pcall( loader );
		end
		
		local Get, SetSize;
		if ok then
			ok, Get, SetSize = pcall( 
				function() 
					return generator.Get, generator.SetSize;
				end );
		end
				
		if ok and type(SetSize)=="function" then
			ok = pcall( SetSize, generator, width, height );
		end
		
		if ok and Get then
			heightMap = HeightMap:new();
			heightMap:CreateEmpty( width, height );
						
			for x=0, heightMap:GetWidth()-1 do
				for y=0, heightMap:GetWidth()-1 do
					local depth;
					ok, depth = pcall( Get, generator, x, y );
					ok = ok and (type(depth)=="number");
					
					if ok then
						heightMap:Set( x, y, depth*255 );
					else
						break;
					end
				end
			end
		end
		
		if not ok then
			heightMap = nil;
		end
	end
	
	-- If failed, try loading from a png
	if not heightMap then
		local ok, depthImg = pcall(	love.image.newImageData, 
								arenaPath .. "/depth.png");
								
		depthImg = love.image.newImageData( arenaPath .. "/depth.png" );
					
		if ok then
			local scaledDepthImg =	ImageData:new( 512, 512 );
			ImageUtils.ScaleImage( depthImg, scaledDepthImg, 5 );
			
			heightMap = HeightMap:new();
			heightMap:LoadFromImageData( scaledDepthImg );
			
			local heightMapFile = io.open(fidPath, "wb");
			if heightMapFile then
				heightMap:SaveToFile( heightMapFile );
				heightMapFile:close();
			end
		end
	end
	
	return heightMap;
end


-------------------------------------------------------------------------------
--  Arena:LoadHeightMap : Loads the height map of the arena
-------------------------------------------------------------------------------
function Arena:LoadNormalMap( arenaPath, height, width, heightMap )
	local normalMap = nil
	
	-- If failed, try loading from a png
	if not normalMap then
		local ok, normalImg = pcall(	love.image.newImageData, 
										arenaPath .. "/normal.png" );
		if ok then
			normalMap = NormalMap:new();
			normalMap:LoadFromImageData( normalImg );
		end
	end
	
	if not normalMap then
		if heightMap then
			normalMap = NormalMap:new();
			normalMap:GenerateFromHeightMap( heightMap );
		end
	end
	
	if normalMap then
		local mapImgData = ImageData:new( normalMap );
		local loveImageData = love.image.newImageData( 
								mapImgData:getDimensions() );
		mapImgData:copy( loveImageData );
		
		self.normalMap = love.graphics.newImage( loveImageData );
	end
	
	return normalMap;
end


-------------------------------------------------------------------------------
--  Arena:GetModel : Returns the model of the arena
-------------------------------------------------------------------------------
function Arena:GetModel()
	return self.model;
end


local lights = {}
lights[1] = {}
lights[1].position = Vector:new(10, -5, 2):Unit()
lights[1].diffuse  = {1, 1, 1, 1}
lights[1].ambient  = {0, 0, 0, 0}


-------------------------------------------------------------------------------
--  Arena:Draw : Draws the arena
-------------------------------------------------------------------------------
function Arena:Draw()
	local modelW, modelH = self.model:GetSize();
	local imageW, imageH = self.image:getWidth(), self.image:getHeight();
	local xScale, yScale = modelW/imageW, modelH/imageH;
	
	if self._lightingShader then
		love.graphics.setShader( self._lightingShader );
		self._lightingShader:send("normalMap",  self.normalMap );
		for i=1, #lights do
			local light = "lights["..(i-1).. "].";
			
			self._lightingShader:send( light .. "position",
				{
					lights[i].position[1],
					lights[i].position[2],
					lights[i].position[3],
					lights[i].position[4],
				}
			);
			
			self._lightingShader:send( light .. "diffuse",
				{
					lights[i].diffuse[1],
					lights[i].diffuse[2],
					lights[i].diffuse[3],
					lights[i].diffuse[4],
				}
			);			
			
			self._lightingShader:send( light .. "ambient",
				{
					lights[i].ambient[1],
					lights[i].ambient[2],
					lights[i].ambient[3],
					lights[i].ambient[4],
				}
			);			
		end
	end	
	
	love.graphics.draw( self.image, 0, 0, 0, xScale, yScale );
	--love.graphics.draw( self.normalMap, 0, 0, 0, xScale, yScale );
	
	-- Unset spin blur
	if self._lightingShader then
		love.graphics.setShader( nil );
	end
end


-------------------------------------------------------------------------------
--  Arena:Update : Updates the arena
-------------------------------------------------------------------------------
function Arena:Update( dt )
	self.model:Update( dt );
end


-------------------------------------------------------------------------------
--  Arena:AddDyzk : Adds a dyzk to the arena
-------------------------------------------------------------------------------
function Arena:AddDyzk( dyzk )
	self.dyzx[ #self.dyzx+1 ] = dyzk;
	self.model:AddDyzk( dyzk:GetModel() );
end


-------------------------------------------------------------------------------
--  Arena:RemoveDyzk : Removes a dyzk from the arena
-------------------------------------------------------------------------------
function Arena:RemoveDyzk( dyzk )
	self.model:RemoveDyzk( dyzk:GetModel() );
	Array.RemoveItem( self.dyzx, dyzk );	
end


-------------------------------------------------------------------------------
--  RemoveAllDyzx:RemoveDyzk : Removes a dyzk from the arena
-------------------------------------------------------------------------------
function Arena:RemoveAllDyzx()
	self.dyzx = {};	
	self.model:RemoveAllDyzx();
end


-------------------------------------------------------------------------------
--  Arena:Dyzx : Returns an iterator to all dyzx objects in the arena
-------------------------------------------------------------------------------
function Arena:Dyzx()
	local idx = 0;
	
	return function()
		if idx<#self.dyzx then
			idx = idx+1;
			return self.dyzx[ idx ];
		end
	end
	
end


-------------------------------------------------------------------------------
--  Arena:GetDyzkCount : Returns the number of dyzx left
-------------------------------------------------------------------------------
function Arena:GetDyzkCount()
	return #self.dyzx;
end


-------------------------------------------------------------------------------
--  Arena:AddDyzk : Adds a dyzk to the arena
-------------------------------------------------------------------------------
function Arena:SetScale( x, y, z )
	self.model:SetScale(x,y,z);
end


-------------------------------------------------------------------------------
--  Arena:SetSize : Sets the size of the arena
-------------------------------------------------------------------------------
function Arena:SetSize( w, h, d )
	self.model:SetSize(w,h,d);
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Arena