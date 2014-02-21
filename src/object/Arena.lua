--===========================================================================--
--  Dependencies
--===========================================================================--
local ArenaModel			= require 'src.model.ArenaModel'
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
function Arena:new( imgFileName, maskFileName, normFileName )
	local obj = {}
	
	self:_InitOneTime();
			
	obj.image = nil;
	obj.model = ArenaModel:new();
	obj.dyzx = {};
	
	---------------------------
	local model = obj.model;
	
	if imgFileName and maskFileName then
	
		obj.image 		= love.graphics.newImage( imgFileName );
	
	
		local tempDepthMap  = love.image.newImageData( maskFileName );
		local normalMap;
		
		local depthMap = ImageData:new( 
			tempDepthMap:getWidth()*2, 
			tempDepthMap:getHeight()*2 
		);
		
		normalMap = love.image.newImageData( 
			depthMap:getWidth(), 
			depthMap:getHeight() 
		);
		
		ImageUtils.ScaleImage( tempDepthMap, depthMap, 5 );
		ImageUtils.DepthToNormalMap( depthMap, normalMap )
		
		model:SetDepthMask( depthMap );
		model:SetNormalMask( normalMap );
		
		obj.normalMap 	= love.graphics.newImage( normalMap );
	end
	---------------------------
	
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
	Array.RemoveFirst( self.dyzx, dyzk );	
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