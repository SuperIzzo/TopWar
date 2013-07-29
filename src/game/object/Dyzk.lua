--===========================================================================--
--  Dependencies
--===========================================================================--
local PhDyzk 			= require 'src.game.physics.PhDyzkBody'
local Sparks 			= require 'src.game.object.Sparks'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Constants
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local DEFAULT_DYZK_SCALE = 0.5
local DEBUG_GRAPHICS	 = true


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--  Spin blush shader
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local spinBlurShader;
if love.graphics.isSupported( "pixeleffect" ) then
	spinBlurShader = love.graphics.newPixelEffect[[
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
	local phDyzk = PhDyzk:new();
	
	obj.image = nil;
	
	---------------------------
	if fname then
		local data = love.image.newImageData( fname );
		phDyzk:SetFromImageData( data, DEFAULT_DYZK_SCALE );
		obj.image = love.graphics.newImage( data );
	else
		phDyzk:SetRadius( 10 );
	end	
	---------------------------
	
	phDyzk:AddCollisionListener( self.OnDyzkCollision, obj );
	obj.phDyzk = phDyzk;
	
	obj._sparks = nil;
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Dyzk:Update : Updates the Dyzk
-------------------------------------------------------------------------------
function Dyzk:Update( dt )
	self.phDyzk:Update( dt );
	
	if self._sparks then
		self._sparks:Update( dt );
	end
end


-------------------------------------------------------------------------------
--  Dyzk:Draw : Updates the Dyzk
-------------------------------------------------------------------------------
function Dyzk:Draw()
	local g = love.graphics
	local phDyzk = self.phDyzk;
	
	if self.image then
		-- Set spin blur
		if spinBlurShader then
			g.setPixelEffect( spinBlurShader );
			spinBlurShader:send("angle", self.phDyzk:GetAngularVelocity()/60 );
		end
		
		-- Draw the image
		g.draw( self.image, phDyzk.x, phDyzk.y, phDyzk.ang,
				DEFAULT_DYZK_SCALE, DEFAULT_DYZK_SCALE,
				self.image:getWidth()/2, self.image:getHeight()/2
			  );
		
		-- Unset spin blur
		if spinBlurShader then
			love.graphics.setPixelEffect( nil );
		end
		
		-- Collision sparks
		if self._sparks then
			self._sparks:Draw();
			
			if self._sparks:IsAnimOver() then
				self._sparks = nil;
			end
		end
	else
		g.circle( "fill", phDyzk.x, phDyzk.y, phDyzk:GetRadius(), 20 );
	end
	
	-- Debug graphics
	if DEBUG_GRAPHICS then
		-- Collision circle
		g.circle( "line", phDyzk.x, phDyzk.y, phDyzk:GetRadius(), 20 );
		-- Velocity vector
		g.line( phDyzk.x, phDyzk.y, 
				phDyzk.x + phDyzk.vx, phDyzk.y + phDyzk.vy
			  );
	end
end


-------------------------------------------------------------------------------
--  Dyzk:GetPhysicsBody : Returns the physics body of the dyzk
-------------------------------------------------------------------------------
function Dyzk:GetPhysicsBody()
	return self.phDyzk;
end


-------------------------------------------------------------------------------
--  Dyzk:GetPhysicsBody : Returns the physics body of the dyzk
-------------------------------------------------------------------------------
function Dyzk:OnDyzkCollision( collisionPoint, collisionNormal )
	self._sparks = Sparks:new( 
			collisionPoint.x, collisionPoint.y,
			collisionNormal
		);
	self._sparks:SetAnimDuration( 0.08 );
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Dyzk;