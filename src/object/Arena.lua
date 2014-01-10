--===========================================================================--
--  Dependencies
--===========================================================================--
local ArenaModel			= require 'src.model.ArenaModel'
local ImageUtils 			= require 'src.graphics.ImageUtils'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--  Lighting shader
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local lightingShader;
if love.graphics.isSupported( "shader" ) then
	lightingShader = love.graphics.newShader[[
	uniform Image normalMap;
	uniform vec3 lightPos;
	
	vec4 blur( Image texture, vec2 coords, float span )
	{
		vec4 a = 	texture2D( texture, coords );
		vec4 b1 = 	texture2D( texture, coords - vec2(0.0f,  span) );
		vec4 b2 = 	texture2D( texture, coords - vec2(0.0f, -span) );
		vec4 b3 = 	texture2D( texture, coords - vec2(span,  0.0f) );
		vec4 b4 = 	texture2D( texture, coords - vec2(-span, 0.0f) );
		vec4 c1 = 	texture2D( texture, coords - vec2(span,  span) );
		vec4 c2 = 	texture2D( texture, coords - vec2(span, -span) );
		vec4 c3 = 	texture2D( texture, coords - vec2(-span, span) );
		vec4 c4 = 	texture2D( texture, coords - vec2(-span,-span) );
		
		return (a*4.0f + b1*2.0f + b2*2.0f + b3*2.0f + b4*2.0f + c1 + c2 + c3 + c4)/16.0f;
	}
	
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
	{
		vec4 diffuse = texture2D( texture, texture_coords );
		
		/*
		vec4 blur0 = blur( normalMap, texture_coords, 1.0f/1024.0f );
		vec4 blur1 = blur( normalMap, texture_coords, 1.5f/1024.0f )*3;
		vec4 blur2 = blur( normalMap, texture_coords, 3.0f/1024.0f )*2;
		vec4 blur3 = blur( normalMap, texture_coords, 4.5f/1024.0f )*1.5;
		vec4 blur4 = blur( normalMap, texture_coords, 6.5f/1024.0f );
		vec4 blur5 = blur( normalMap, texture_coords, 9.0f/1024.0f )*0.5;
		vec4 blur6 = blur( normalMap, texture_coords, 9.0f/1024.0f )*0.25;
		
		vec3 normalVec = normalize( (blur0+blur1+blur2+blur3+blur4+blur5+blur6).xyz );
		*/
		vec3 normalVec = normalize( texture2D( normalMap, texture_coords ).xyz );
		
		vec3 lightVec = normalize( vec3(10.0f,-5.0f,2.0f));
		
		float i = dot( normalVec, lightVec ) * 1.0f;
		
		return vec4( diffuse.x * i, diffuse.y * i, diffuse.z * i, diffuse.w );
	}
	]]
end



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
	
	obj.image = nil;
	
	local phArena = ArenaModel:new();
	
	---------------------------
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
		
		phArena:SetDepthMask( depthMap );
		phArena:SetNormalMask( normalMap );
		
		obj.normalMap 	= love.graphics.newImage( normalMap );
		obj.image 		= love.graphics.newImage( imgFileName );
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
	
	if lightingShader then
		love.graphics.setShader( lightingShader );
		lightingShader:send("normalMap",  self.normalMap );
		--lightingShader:send("lightPos",  self.normalMap );
	end
	
	love.graphics.draw( self.image, 0, 0, 0, xScale, yScale );
	
	-- Unset spin blur
	if lightingShader then
		love.graphics.setShader( nil );
	end
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
	self.phArena:AddDyzk( dyzk:GetModel() );
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