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




local TopPhysics 		= require 'src.game.Top'

local Top = {}
Top.__index = Top


function Top:new()
	local obj = {}	
	
	obj.topPhysics = TopPhysics:new();
	obj.topPhysics.x = 100;
	obj.topPhysics.y = 400;
	obj.topPhysics.angle 		= 0;
	obj.topPhysics.angleDelta 	= 0;
	obj.topPhysics.angleVel 	= 0;
	
	return setmetatable(obj, self);
end

function Top:Load( file )
	local topImgData = love.image.newImageData( file );
	self.topPhysics:SetFromImageData( topImgData );
	
	self.image = love.graphics.newImage( topImgData );
end


function Top:Draw()
	local scaleX = 0.3;
	local scaleY = 0.3;
	

	local phTop = self.topPhysics;
	
	love.graphics.setCaption( "RPM: " .. phTop.angleVel * 9.5493 )	
	
	if spinBlur then
		love.graphics.setPixelEffect( spinBlur );
		spinBlur:send("angle", phTop.angleDelta );
	end
		
	love.graphics.draw( 
		self.image, 
		phTop.x, phTop.y,
		phTop.angle, 
		scaleX, scaleY,
		self.image:getWidth()/2,
		self.image:getHeight()/2 
	);
end


function Top:Update(dt)
	local phTop = self.topPhysics;
	
	local angleAcc = 1*dt;
	phTop.angleVel = phTop.angleVel + angleAcc;
	
	phTop.angleDelta = phTop.angleVel * dt;
	phTop.angle = phTop.angle + phTop.angleDelta;
end


local sqrt = math.sqrt;
--[[
local function MakeNormalMap( imgData, outData )
	local w,h = imgData:getWidth(), imgData:getHeight();
	local hr = {}
	local vt = {}
	
	local prevXCol = imgData:getPixel( 0, 0 );
	
	local prevCol = {}
	
	for pxX = 0, w-1 do
		vt[pxX] = {}
		hr[pxX] = {}
		
		local prevYCol = imgData:getPixel( pxX, 0 );
		
		for pxY = 0, h-1 do
			local col = imgData:getPixel( pxX, pxY );			
			local prevXCol = prevCol[pxY] or col;			
			
			vt[pxX][pxY] = col - prevYCol
			hr[pxX][pxY] = col - prevXCol;
			
			prevCol[pxY] = col;
			prevYCol = col;
		end
	end
	
		
	for pxX = 0, w-2 do
		for pxY = 0, h-2 do			
			local dz = hr[pxX][pxY] + hr[pxX+1][pxY];
			
			local length = sqrt((dz/2)^2 +1);
			local nx = -dz/length;
			local nz = 1/length;
			
				  dz = vt[pxX][pxY] + vt[pxX][pxY+1];
			
				  length = sqrt((dz/2)^2 +1);
			local ny = -dz/length;
				  nz = nz + 1/length;
			
			
			outData:setPixel( pxX, pxY, 127 + nx*127, 127 + ny*127, nz*127, 255 );
		end
	end
	
end
--]]

---[[
local function MakeNormalMap( imgData, outData )
	local w,h = imgData:getWidth(), imgData:getHeight();
	

	local function saveGetPX( x, y )
		if x< 0 then 
			x = 0;
		elseif x>= w then
			x = w-1;
		end
		
		if y< 0 then 
			y = 0;
		elseif y>= h then
			y = h-1;
		end
		
		return imgData:getPixel( x, y );
	end
	
	local abs = math.abs
	local function kernel(x, y)
		local dz =imgData:getPixel( x, y );
		
		local nx, ny, nz = 0, 0, 0;
		for xx= -2, 2 do
			for yy= -2, 2 do
				if xx ~=0 or yy ~= 0 then
					local dzz = saveGetPX( x+xx, y+yy );
									
					nx = nx + xx*(dzz - dz);
					ny = ny + yy*(dzz - dz);
					nz = nz + sqrt(xx^2 + yy^2);
				end
			end			
		end
		
		local len = sqrt(nx^2 + ny^2 + nz^2);
		return nx/len*127+127, ny/len*127+127, nz/len*255;
	end
	
	for pxX = 0, w-1 do
		for pxY = 0, h-1 do
			local r, g, b = kernel(pxX, pxY);
			outData:setPixel( pxX, pxY, r, g, b, 255 );
		end
	end
end
--]]


local top1, top2;
local arenaImg = nil;
local arenaNMap = nil
function love.load()
	top1 = Top:new();
	
	top1:Load( "test/img/spinner1.png" );
	
	local arenaMap = love.image.newImageData( "test/img/arena_mask2.png" );
	arenaNMap = love.image.newImageData( arenaMap:getWidth(), arenaMap:getHeight() );
	MakeNormalMap( arenaMap, arenaNMap );
	arenaImg = love.graphics.newImage(arenaNMap);
end

local vx = 0;
local vy = 0;
local fst = 5;
function love.update(dt)
	top1:Update(dt);
	
	if fst > 0 then
		dt = 0;
		fst = fst-1;
	end
	
	local xd, yd = arenaNMap:getPixel( top1.topPhysics.x/4, top1.topPhysics.y/4 );
	
	vx = vx - vx*(0.0007*dt) + (xd/127 - 1)*dt*7;
	vy = vy - vy*(0.0007*dt) + (yd/127 - 1)*dt*7;
	
	top1.topPhysics.x = top1.topPhysics.x - vx*dt*4;
	top1.topPhysics.y = top1.topPhysics.y - vy*dt*4;
	
end

function love.draw()
	love.graphics.translate( -top1.topPhysics.x +love.graphics.getWidth()/2, -top1.topPhysics.y +love.graphics.getHeight()/2 );
	love.graphics.setPixelEffect( nil );
	love.graphics.draw( arenaImg, 0, 0, 0, 4, 4 );
	top1:Draw();	
end


--Shape affects physical traits - speed, weight, attack
--Color and symbols affect special abilities