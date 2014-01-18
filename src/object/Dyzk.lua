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
local DEBUG_GRAPHICS	 = false


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--  Spin blush shader
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local spinBlurShader;
if love.graphics.isSupported( "shader" ) then
	spinBlurShader = love.graphics.newShader[[
	uniform float angle;
	#define NUM_ROTATIONS 30
	
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
	{
		//float angle = 1.8;
		
		vec2 center = vec2( 0.5, 0.5 );
		vec2 relPos = texture_coords - center;
		vec4 finalColor = vec4( 0.0, 0.0, 0.0, 0.0 );
		
		float progression = 0;
		
		for( int i=0; i<NUM_ROTATIONS; i++ )
		{
			float angleFract = -angle*float(i)/float(NUM_ROTATIONS);
			float cs = cos( angleFract );
			float sn = sin( angleFract );
			vec2 newPos = vec2( relPos.x*cs - relPos.y*sn, relPos.x*sn + relPos.y*cs );
			newPos += center;
			
			vec4 tex = texture2D( texture, newPos );
			float rate = pow(float(i),1.2) * (tex.a +0.4);
			progression = progression + rate;
			finalColor += tex * rate;
		}
		
		return finalColor/progression;
	}
	]]
end



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
	local model = DyzkModel:new();
	
	obj.image = nil;
	local analysis = nil;
	
	---------------------------
	if fname then
		local imageData = love.image.newImageData( fname );
		
		analysis = DyzkImageAnalysis:new();
		analysis:AnalyzeImage( imageData, DEFAULT_DYZK_SCALE );		
		model:CopyFromDyzkData( analysis );
		model:SetDyzkID( fname );
		
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
--  Dyzk:Update : Updates the Dyzk
-------------------------------------------------------------------------------
function Dyzk:Update( dt )
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
		if spinBlurShader then
			g.setShader( spinBlurShader );
			spinBlurShader:send("angle", self.model:GetAngularVelocity()/60 );
		end
		
		-- Draw the image
		g.draw( self.image, model.x, model.y, model.ang,
				DEFAULT_DYZK_SCALE, DEFAULT_DYZK_SCALE,
				self.image:getWidth()/2, self.image:getHeight()/2
			  );
		
		-- Unset spin blur
		if spinBlurShader then
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
		-- Collision circle
		g.circle( "line", model.x, model.y, model:GetMaxRadius(), 20 );
		-- Velocity vector
		g.line( model.x, model.y, 
				model.x + model.vx, model.y + model.vy
			  );
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
		self._sparks:SetAnimDuration( 0.08 );
	end
	
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Dyzk;