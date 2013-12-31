--===========================================================================--
--  Dependencies
--===========================================================================--
local ArenaModel			= require 'src.model.ArenaModel'
local ImageUtils 		= require 'src.graphics.ImageUtils'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Arena : An arena game object
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Arena = {}
Arena.__index = Arena;


-------------------------------------------------------------------------------
--  Arena:new : Creates a new arena game object
-------------------------------------------------------------------------------
function Arena:new( fname )
	local obj = {}
	
	obj.image = nil;
	
	local phArena = ArenaModel:new();
	
	---------------------------
	if fname then
		local depthMap  = love.image.newImageData( fname );
		local normalMap = love.image.newImageData( 
				depthMap:getWidth(), 
				depthMap:getHeight() );
				
		ImageUtils.DepthToNormalMap( depthMap, normalMap )
		
		phArena:SetDepthMask( depthMap );
		phArena:SetNormalMask( normalMap );
		
		obj.image = love.graphics.newImage( normalMap );
	end
	---------------------------
	
	obj.phArena = phArena;
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  Arena:Draw : Draws the arena
-------------------------------------------------------------------------------
function Arena:Draw()
	local xScale, yScale = self.phArena:GetScale();
	love.graphics.draw( self.image, 0, 0, 0, xScale, yScale );
end


-------------------------------------------------------------------------------
--  Arena:Update : Updates the arena
-------------------------------------------------------------------------------
function Arena:Update(dt)
	self.phArena:Update(dt);
end


-------------------------------------------------------------------------------
--  Arena:AddDyzk : Adds a dyzk to the arena
-------------------------------------------------------------------------------
function Arena:AddDyzk( dyzk )
	self.phArena:AddDyzk( dyzk.phDyzk );
end


-------------------------------------------------------------------------------
--  Arena:AddDyzk : Adds a dyzk to the arena
-------------------------------------------------------------------------------
function Arena:SetScale( x, y, z )
	self.phArena:SetScale(x,y,z);
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Arena