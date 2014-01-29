--===========================================================================--
--  Dependencies
--===========================================================================--
local ArenaModel			= require 'src.model.ArenaModel'
local ImageUtils 			= require 'src.graphics.ImageUtils'

local Array					= require 'src.util.Array'



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
		local depthMap  = love.image.newImageData( maskFileName );
		local normalMap
		
		if normFileName then
			local rawNormalMap = love.image.newImageData( normFileName );
			
			normalMap = love.image.newImageData( 
					rawNormalMap:getWidth(), 
					rawNormalMap:getHeight() );
			
			ImageUtils.NormalizeImage( rawNormalMap, normalMap );
		else
			normalMap = love.image.newImageData( 
					depthMap:getWidth(), 
					depthMap:getHeight() );
					
			ImageUtils.DepthToNormalMap( depthMap, normalMap )
		end
		
		model:SetDepthMask( depthMap );
		model:SetNormalMask( normalMap );
		
		obj.normalMap 	= love.graphics.newImage( normalMap );
		obj.image 		= love.graphics.newImage( imgFileName );
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
		end	
	end
end


-------------------------------------------------------------------------------
--  Arena:GetModel : Returns the model of the arena
-------------------------------------------------------------------------------
function Arena:GetModel()
	return self.model;
end


-------------------------------------------------------------------------------
--  Arena:Draw : Draws the arena
-------------------------------------------------------------------------------
function Arena:Draw()
	local xScale, yScale = self.model:GetScale();
	
	if self._lightingShader then
		love.graphics.setShader( self._lightingShader );
		self._lightingShader:send("normalMap",  self.normalMap );
		--lightingShader:send("lightPos",  self.normalMap );
	end
	
	love.graphics.draw( self.image, 0, 0, 0, xScale, yScale );
	
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
--  Arena:AddDyzk : Adds a dyzk to the arena
-------------------------------------------------------------------------------
function Arena:SetScale( x, y, z )
	self.model:SetScale(x,y,z);
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Arena