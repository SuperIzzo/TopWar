require 'src.strict'



local gameConf	 = nil;
local function GetConf()
	if not gameConf and love.conf then
		gameConf	 = {}
		gameConf.screen  = {}
		gameConf.modules = {}
	
		love.conf( gameConf );
	end
	
	return gameConf;
end



local conf = GetConf()
if conf and conf.test then
	local TestMain = require("test.TestMain");
	TestMain:Run();
end



local spinBlur = nil;
if love.graphics.isSupported( "pixeleffect" ) then
	spinBlur = love.graphics.newPixelEffect[[
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
			float fract = float(i)/float(NUM_ROTATIONS);
			float cs = cos( -angle*fract );
			float sn = sin( -angle*fract );
			vec2 newPos = vec2( relPos.x*cs - relPos.y*sn, relPos.x*sn + relPos.y*cs );
			newPos += center;
			
			vec4 tex = texture2D( texture, newPos );
			float rate = pow(i,1.2) * (tex.a +0.6);
			progression = progression + rate;
			finalColor += tex * rate;
		}
		
		return finalColor/progression;
	}
	]]
end




local TopPhysics 		= require 'src.game.Top'

local Top = {}
Top.__index = Top


function Top:new()
	local obj = {}	
	
	obj.topPhysics = TopPhysics:new();
	obj.x = 400;
	obj.y = 400;
	
	return setmetatable(obj, self);
end

function Top:Load( file )
	local topImgData = love.image.newImageData( file );
	self.topPhysics:SetFromImageData( topImgData );
	
	self.image = love.graphics.newImage( topImgData );
end


local angle = 0;
local angleSpeed = 0/180 * math.pi;
local angleDelta = 0;

function love.update(dt)
	angleSpeed = angleSpeed + 1*dt;
	angleDelta = angleSpeed*dt;
	angle = angle + angleDelta;
end

function Top:Draw()
	local scaleX = 0.3
	local scaleY = 0.3
	
	--angle = angle + angleSpeed;
	--angleSpeed = angleSpeed + 0.001;
	
	love.graphics.setCaption( "RPM: " .. angleSpeed*9.5493 )	
	
	if spinBlur then
		love.graphics.setPixelEffect( spinBlur );
		spinBlur:send("angle", angleDelta );
		--print( angleDelta );
	end
	
	
	love.graphics.draw( 
		self.image, 
		self.x, self.y,
		angle, 
		scaleX, scaleY,
		self.image:getWidth()/2,
		self.image:getHeight()/2 
	);
end


local top1, top2;
function love.load()
	top1 = Top:new();
	
	top1:Load( "test/img/spinner1.png" );
end

function love.draw()
	top1:Draw();
end


--Shape affects physical traits - speed, weight, attack
--Color and symbols affect special abilities