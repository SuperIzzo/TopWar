--===========================================================================--
--  Dependencies
--===========================================================================--
local DyzkModel 			= require 'src.model.DyzkModel'
local Sparks 				= require 'src.object.Sparks'
local DyzkImageAnalysis		= require 'src.model.DyzkImageAnalysis'




--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Constants
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local DEFAULT_DYZK_SCALE = 1
local DEBUG_GRAPHICS	 = false


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
		obj._handleCol = {imageData:getPixel( 
									imageData:getWidth()/2,
									imageData:getHeight()/2)};
	else
		model:SetRadius( 10 );
	end	
	---------------------------
	
	model:AddCollisionListener( self.OnDyzkCollision, obj );
	
	obj.model 			= model;
	obj.dyzkAnalysis 	= analysis;
	
	obj._blurCanvas		= love.graphics.newCanvas( obj.image:getWidth(), obj.image:getHeight() );
	obj._transfCanvas	= love.graphics.newCanvas( obj.image:getWidth(), obj.image:getHeight() );
	obj._dyzkNormal		= { x=0, y=0, z=1};
	
	obj._sparks = nil;
	
	return setmetatable(obj, self);
end


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class SoundPointData a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local SoundPointData = {}
SoundPointData.__index = SoundPointData;


-------------------------------------------------------------------------------
--  SoundPointData:new  Creates a new SoundPointData
-------------------------------------------------------------------------------
function SoundPointData:new( soundData )
	local obj = {}
	obj.soundData		= soundData;
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  SoundPointData:GetDimension : Returns the dimension of the data
-------------------------------------------------------------------------------
function SoundPointData:GetDimension() return 1; end


-------------------------------------------------------------------------------
--  SoundPointData:GetLimits : Returns the min and max of the array
-------------------------------------------------------------------------------
function SoundPointData:GetLimits()
	return 1, self.soundData:getSampleCount();
end


-------------------------------------------------------------------------------
--  SoundPointData:GetPoint : Returns point with the given index
-------------------------------------------------------------------------------
function SoundPointData:GetPoint( idx )
	return self.soundData:getSample(idx-1);
end


-------------------------------------------------------------------------------
--  Dyzk:_GenerateClings : Generates different cling sounds
-------------------------------------------------------------------------------
function Dyzk:_GenerateClings()
	local soundData = love.sound.newSoundData("data/sfx/metallic-cling1.ogg");
	return { love.audio.newSource( soundData ) };
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
	self._sfxClings = self:_GenerateClings();
	
	if love.graphics.isSupported( "shader" ) then
		local shaderCode = love.filesystem.read( "data/gfx/shaders/spin-blur.frag" );
		local ok, shader = pcall( love.graphics.newShader, shaderCode );
		
		if ok then
			self._spinBlurShader = shader;
		end
	end
	
end


-------------------------------------------------------------------------------
--  Dyzk:SetupLights : Updates the Dyzk
-------------------------------------------------------------------------------
function Dyzk:SetupLights( lights, refW, refH )
	self._sparkLight = lights:CreatePointLight(
		{255,255,128}, 5, 0, 
		{0.5, 0.5, 0.1},
		0,10,100 
	);
	self._sparkLight:SetOn( false );
	self._sparkLight._refW = refW;
	self._sparkLight._refH = refH;
end


-------------------------------------------------------------------------------
--  Dyzk:Update : Updates the Dyzk
-------------------------------------------------------------------------------
function Dyzk:Update( dt )

	-- First off cache the control vector for later (or the model may reset it)
	if DEBUG_GRAPHICS then
		self._controlVecX, self._controlVecY = self.model:GetControlVector()
	end
	
	-- Update our physical body...
	self.model:Update( dt );
	
	-- Update the sparks animation
	if self._sparks then
		self._sparks:Update( dt );
	end
	
	-- Update our orientation based on the position and location of the model
	-- Grounded dyzx acquire the orientation of the ground, when in the air
	-- they we turn up (to counteract to gravity)
	local targetNormal;
	if self.model:GetElevation() <= 0 then		
		targetNormal = self.model._arenaNormal;
	else
		targetNormal = { x=0, y=0, z=1 };
	end
	
	-- We interpolate slowly towards the desired orientation to avoid
	-- sudden changes (which look silly)
	local rate = math.min(1, 10*dt);
	local invRate = (1-rate);
	self._dyzkNormal.x = invRate*self._dyzkNormal.x + rate*targetNormal.x;
	self._dyzkNormal.y = invRate*self._dyzkNormal.y + rate*targetNormal.y;
	self._dyzkNormal.z = invRate*self._dyzkNormal.z + rate*targetNormal.z;
end


-------------------------------------------------------------------------------
--  Dyzk:UpdateCanvases : Updates the canvases
-------------------------------------------------------------------------------
function Dyzk:UpdateCanvases()	

	local g = love.graphics
	local model = self.model;
	
	g.push();
	g.origin();
	
	self._updateBlurCanv = self._updateBlurCanv or 0;
	if self._updateBlurCanv>0 then
		self._updateBlurCanv = self._updateBlurCanv-1;
	else
		self._updateBlurCanv = 400;
		
		self._blurCanvas:clear(255,255,255,0);
		love.graphics.setCanvas( self._blurCanvas );
		
		-- Set spin blur
		if self._spinBlurShader then
			g.setShader( self._spinBlurShader );
			self._spinBlurShader:send("angle", self.model:GetRadialVelocity()/60 );
		end
		
		-- Draw the image
		g.draw( self.image, 
				self._blurCanvas:getWidth()/2,
				self._blurCanvas:getHeight()/2,
				0, 1, 1,			
				self.image:getWidth()/2, self.image:getHeight()/2
			  );
			  
		-- Unset spin blur
		if self._spinBlurShader then
			love.graphics.setShader( nil );
		end
	end
	
	self._transfCanvas:clear();
	love.graphics.setCanvas( self._transfCanvas );
	
	g.draw( self._blurCanvas, 
			self._transfCanvas:getWidth()/2, 
			self._transfCanvas:getHeight()/2,
			model:GetAngle(), 
			1,1,			
			self._blurCanvas:getWidth()/2, 
			self._blurCanvas:getHeight()/2
		  );
		  
	love.graphics.setCanvas();
	
	g.pop();
end


-------------------------------------------------------------------------------
--  Dyzk:Draw : Updates the Dyzk
-------------------------------------------------------------------------------
function Dyzk:Draw()
	local g = love.graphics
	local model = self.model;
	
	self:UpdateCanvases();
	
	local zScale = DEFAULT_DYZK_SCALE*model:GetPerspScale();
	
	love.graphics.draw(	self._transfCanvas, 
						model._position.x + self._dyzkNormal.x*100, 
						model._position.y + self._dyzkNormal.y*100,
						math.atan2(self._dyzkNormal.x,-self._dyzkNormal.y),
						zScale, self._dyzkNormal.z * zScale,
						self._transfCanvas:getWidth()/2,
						self._transfCanvas:getHeight()/2 );
	
	-- Draw handle
	local handleSize = model:GetRadius()*zScale*0.75;
	love.graphics.setLineWidth(20);
	love.graphics.setColor( unpack(self._handleCol) );
	love.graphics.line( 
						model._position.x + self._dyzkNormal.x*100, 
						model._position.y + self._dyzkNormal.y*100,
						model._position.x + self._dyzkNormal.x*(100+handleSize), 
						model._position.y + self._dyzkNormal.y*(100+handleSize)
					   );
	love.graphics.setColor( 255,255,255,255 );
	love.graphics.setLineWidth(1);
	
	-- Collision sparks
	if self._sparks then
		self._sparks:Draw();
		
		if self._sparks:IsAnimOver() then
			self._sparks = nil;
			
			if self._sparkLight then
				self._sparkLight:SetOn( false );
			end
		end
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
		g.circle( "line", x, y, model:GetRadius()*zScale, 20 );
		
		-- Velocity vector
		g.line( x, y, x + vx, y + vy );
		
		-- Control vector
		if cx then
			love.graphics.setColor( 0, 255, 0, 200 );
			g.line( x, y, x+cx*speed, y+cy*speed );
		end
		
		-- Elevation circle (indicates how much we are above the ground)
		local elevation = model:GetElevation();
		if elevation>0 then
			local	x,y, z = model:GetPosition();
			local	rad	= model:GetRadius();
					rad	= rad + elevation;
					rad = rad * zScale;
			g.circle( "line", x, y, rad, 20 );
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
				
		if not self._sparkLight:IsOn() then
			self._sparkLight:SetPosition( colX, colY, 0.1 );
			self._sparkLight:SetOn( true );
		end
		
		if (not self._sfxClings.current) or self._sfxClings.current:isStopped() then
			local clingIdx = math.random( #self._sfxClings ); 
			self._sfxClings.current = self._sfxClings[clingIdx];
			love.audio.play( self._sfxClings.current );
		end
	end
	
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Dyzk;