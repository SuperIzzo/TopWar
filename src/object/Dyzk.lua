--===========================================================================--
--  Dependencies
--===========================================================================--
local DyzkModel 			= require 'src.model.DyzkModel'
local Sparks 				= require 'src.object.Sparks'
local DyzkImageAnalysis		= require 'src.graphics.DyzkImageAnalysis'




--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Constants
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local DEFAULT_DYZK_SCALE = 1
local DEBUG_GRAPHICS	 = true


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Dyzk : A Dyzk game object
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Dyzk = {}
Dyzk.__index = Dyzk;


-------------------------------------------------------------------------------
--  Dyzk:new : Creates a new Dyzk game object
-------------------------------------------------------------------------------
function Dyzk:new( fname )
	local obj = {}
	
	-- Initialise the class
	Dyzk:_InitOneTime();
	
	
	local model = DyzkModel:new();
	
	obj.image = nil;
	local analysis = nil;
	
	---------------------------
	if fname then
		local imageData = love.image.newImageData( fname );
		
		analysis = DyzkImageAnalysis:new();
		analysis:AnalyzeImage( imageData, DEFAULT_DYZK_SCALE );		
		model:CopyFromDyzkData( analysis );
		
		obj.image = love.graphics.newImage( imageData );
	else
		model:SetMaxRadius( 10 );
	end	
	---------------------------
	
	model:AddCollisionListener( self.OnDyzkCollision, obj );
	
	obj.model 			= model;
	obj.dyzkAnalysis 	= analysis;
	
	obj._sparks = nil;
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Dyzk:_InitOneTime : Loads common resoources
-------------------------------------------------------------------------------
local MathUtils = require "src.math.MathUtils"
local clamp		= MathUtils.Clamp;
local function changePitch( inSoundData, outSoundData, scale )
	for i = 1, inSoundData:getSampleCount() do
		local sample = inSoundData:getSample(i);
		local newSample = clamp( sample * scale * math.random(), -1, 1 );
		outSoundData:setSample( i, newSample );
	end
end


-------------------------------------------------------------------------------
--  Dyzk:_InitOneTime : Loads common resoources
-------------------------------------------------------------------------------
function Dyzk:_InitOneTime()
	if self._classInitialised then
		return
	end
	
	self._classInitialised = true;

	-- Load the cling sound effect
	self._sfxClings = {};
	self._sfxClings[1] = love.audio.newSource( "data/sfx/metallic-cling1.ogg" );
	
	if love.graphics.isSupported( "shader" ) then
		local shaderCode = love.filesystem.read( "data/gfx/shaders/spin-blur.frag" );
		local ok, shader = pcall( love.graphics.newShader, shaderCode );
		
		if ok then
			self._spinBlurShader = shader;
		end
	end
	
end


-------------------------------------------------------------------------------
--  Dyzk:Update : Updates the Dyzk
-------------------------------------------------------------------------------
function Dyzk:Update( dt )
	if DEBUG_GRAPHICS then
		-- cache this for later
		self._controlVecX, self._controlVecY = self.model:GetControlVector()
	end
	
	self.model:Update( dt );
	
	if self._sparks then
		self._sparks:Update( dt );
	end
end


-------------------------------------------------------------------------------
--  Dyzk:Draw : Updates the Dyzk
-------------------------------------------------------------------------------
function Dyzk:Draw()
	local g = love.graphics
	local model = self.model;
	
	if self.image then
		-- Set spin blur
		if self._spinBlurShader then
			g.setShader( self._spinBlurShader );
			self._spinBlurShader:send("angle", self.model:GetAngularVelocity()/60 );
		end
		
		-- Draw the image
		g.draw( self.image, model.x, model.y, model.ang,
				DEFAULT_DYZK_SCALE, DEFAULT_DYZK_SCALE,
				self.image:getWidth()/2, self.image:getHeight()/2
			  );
		
		-- Unset spin blur
		if self._spinBlurShader then
			love.graphics.setShader( nil );
		end
		
		-- Collision sparks
		if self._sparks then
			self._sparks:Draw();
			
			if self._sparks:IsAnimOver() then
				self._sparks = nil;
			end
		end
	else
		g.circle( "fill", model.x, model.y, model:GetMaxRadius(), 20 );
	end
	
	-- Debug graphics
	if DEBUG_GRAPHICS then
		local restoreColor = {love.graphics.getColor( 255, 0, 0 )};
		
		
		local x,y 		= model:GetPosition();
		local vx, vy 	= model:GetVelocity();
		local cx, cy	= self._controlVecX, self._controlVecY;
		local speed 	= model:GetSpeed();		
		
		love.graphics.setColor( 0, 130, 255, 200 );
		
		-- Collision circle
		g.circle( "line", x, y, model:GetMaxRadius(), 20 );
		
		-- Velocity vector
		g.line( x, y, x + vx, y + vy );
		
		-- Control vector
		if cx then
			love.graphics.setColor( 0, 255, 0, 200 );
			g.line( x, y, x+cx*speed, y+cy*speed );
		end
		
		-- Restore the color as it was
		love.graphics.setColor( restoreColor );
	end
end


-------------------------------------------------------------------------------
--  Dyzk:GetModel : Returns the physics body of the dyzk
-------------------------------------------------------------------------------
function Dyzk:GetModel()
	return self.model;
end


-------------------------------------------------------------------------------
--  Dyzk:OnDyzkCollision : React on dyzk collision
-------------------------------------------------------------------------------
function Dyzk:OnDyzkCollision( report )
	
	-- Draw some friction sparks
	if report:IsPrimary() then
		local colX, colY 	= report:GetCollisionPoint();
		local colNx, colNy	= report:GetCollisionNormal();
		self._sparks = Sparks:new( 
			colX, colY,
			colNx, colNy
		);
		self._sparks:SetAnimDuration( 0.1 );
		
		local clingIdx = math.random( #self._sfxClings ); 
		love.audio.play( self._sfxClings[clingIdx] );
	end
	
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Dyzk;