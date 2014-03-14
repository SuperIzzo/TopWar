--===========================================================================--
--  Dependencies
--===========================================================================--
local LightSource			= require 'src.object.LightSource'
local Array					= require 'src.util.collection.Array'



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Lights: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Lights = {}
Lights.__index = Lights;


-------------------------------------------------------------------------------
--  Lights:new : Creates a new Lights
-------------------------------------------------------------------------------
function Lights:new()
	local obj = {}
	
	obj._dirLights = Array:new()
	obj._pointLights = Array:new()
	
	-- Init class variables
	self:_SetupShaders();

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Lights:_SetupShaders : Sets up shaders
-------------------------------------------------------------------------------
function Lights:_SetupShaders()
	-- Skip this if we are initialized
	if self._lightingShader then
		return;
	end
	
	if love.graphics.isSupported( "shader" ) then
		local shaderCode = love.filesystem.read( "data/gfx/shaders/lighting.frag" );
		local ok, shader = pcall( love.graphics.newShader, shaderCode );
		
		if ok then
			self._lightingShader = shader;
		else
			error( shader );
		end		
	end
end
	
	
-------------------------------------------------------------------------------
--  Lights:CreatePointLight : Creates a point light source
-------------------------------------------------------------------------------
function Lights:CreatePointLight(...)
	local light = LightSource:new( "point", ... );
	self._pointLights:Add( light );
	
	return light;
end


-------------------------------------------------------------------------------
--  Lights:CreateDirectionalLight : Creates a directional light source
-------------------------------------------------------------------------------
function Lights:CreateDirectionalLight( ... )
	local light = LightSource:new( "directional", ... );
	self._dirLights:Add( light );
	
	return light;
end


-- HACK! -- should be solved by properly managing light resources
-- Rather than deleting them
local offDirLight = LightSource:new( "directional", {0,0,0,0} );
local offPointLight = LightSource:new( "point", {0,0,0,0} );
-------------------------------------------------------------------------------
--  Lights:Send : Sends the light sources to the shader
-------------------------------------------------------------------------------
function Lights:SendLights( shader, refWidth, refHeight )
	local MAX_DIR_LIGHTS = 3;
	local MAX_POINT_LIGHTS = 3;
	
	-- Re-order arguments
	if type(shader) == "number" then
		refHeight = refWidth;
		refWidth = shader;
		shader = nil;
	end
	
	-- Set default values
	local shader	= shader	or self._lightingShader;
	local refWidth	= refWidth	or 1;
	local refHeight	= refHeight	or 1;
	
	-- 
	if not shader then
		return false, "No lighting shader has been loaded.";
	end
	
	local numDirLights = 0;
	for dirLight in self._dirLights:Items() do
		if dirLight and dirLight:IsOn() then
			dirLight:Send( shader, numDirLights ); 
			
			numDirLights = numDirLights+1;
			if numDirLights>= MAX_DIR_LIGHTS then
				break;
			end
		end
	end
	
	local numPointLights = 0;
	for pointLight in self._pointLights:Items() do
		if pointLight and pointLight:IsOn() then 
			pointLight:Send( shader, numPointLights, refWidth, refHeight );
			
			numPointLights = numPointLights+1;			
			if numPointLights>= MAX_POINT_LIGHTS then
				break;
			end
		end
	end

	-- Explicitly turn off the lights that have not been set
	-- during this call...
	for i = numDirLights, MAX_DIR_LIGHTS-1 do
		offDirLight:Send( shader, i );
	end
	
	for i = numPointLights, MAX_POINT_LIGHTS-1 do
		offPointLight:Send( shader, i, 1, 1 );
	end
end


-------------------------------------------------------------------------------
--  Lights:Use : Sends the light sources to the shader
-------------------------------------------------------------------------------
function Lights:Use( normalMap, refWidth, refHeight )
	
	if self._lightingShader then
		if normalMap then
			local refWidth	= refWidth or normalMap:getWidth();
			local refHeight	= refHeight or normalMap:getHeight();
	
			love.graphics.setShader( self._lightingShader );
			self._lightingShader:send( "normalMap", normalMap );
			self:SendLights( refWidth, refHeight );
		else
			love.graphics.setShader( nil );
		end
	end
	
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Lights