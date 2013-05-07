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
	obj.topPhysics.angleVel 	= 340;
	
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
	
	local angleAcc = -2*dt;
	phTop.angleVel = phTop.angleVel + angleAcc;
	
	phTop.angleDelta = phTop.angleVel * dt;
	phTop.angle = phTop.angle + phTop.angleDelta;
end


local sqrt = math.sqrt;

--[[
	This algorithm tries to be as efficient as possible, because the getPixel
	routines seem to be quite expensive. First we compute the horizontal and
	vertical gradients and store the results in `grad'. 
	  ________________   The gradient computation uses the kernel shown left.
	  | A0 | B0 | C0 |   C2 is the read cursor where the new color is obtained.
	  | A1 | B1 | C1 |   B1 is the write cursor where the gradients are stored.
	  | A2 | B2 | C2 |   The loop operates on both gradients (vertical and 
	  ----------------   horizontal) simultaneously, but in order to do so has
	     Fig. Kernel     to store information about previously read colors.
						 The horizontal gradient is computed as (A1-C1)/2, the
					     vertical as (B0-B2)/2.
	Gausian blur is blur is later applied and the gradients are turned into 
	color components.
--]]
local function MakeNormalMap( imgData, outData )
	local width, height = imgData:getWidth(), imgData:getHeight();	
	
	-- We need to store 2 columns of the original image
	local columnA = {}
	local columnB = {}
	
	-- Get the first column in advance
	for y = 0, height-1 do
		columnA[y] = imgData:getPixel( 0, y );
		columnB[y] = columnA[y];
	end
	
	-- Store the gradients for later
	local grad = {};
	
	for x = 0, height-2 do		
		local C1 = imgData:getPixel( x, 0 );
		local C0 = C1;
		columnB[-1] = columnB[0];
		
		grad[x] = {};
		
		for y = 0, height-2 do
			local C2 = imgData:getPixel( x+1, y+1 );
			
			local hr = ( columnA[y] - C1 )/2;
			local vr = ( columnB[y-1] - columnB[y+1] )/2;
			
			-- It is a 3D vector showing the direction of the normal
			-- x and y are in the oposite direction of the gradients
			-- while zet is implicitly 2
			grad[x][y] = { hr, vr}
			
			-- Update colors
			columnA[y-1] = columnB[y-1];			
			columnB[y-1] = C0;
			C0 = C1;
			C1 = C2;						
		end
	end
	
	-- Aplly blur and compute and store as color
	for x1=1, width-3 do
		local x0 = x1-1;
		local x2 = x1+1;
		
		for y1=1, height-3 do
			local y0 = y1-1;
			local y2 = y1+1;
			
			local nx = --grad[x1][y1][1] * 18
			---[[
				grad[x0][y0][1]   + grad[x1][y0][1]*2 + grad[x2][y0][1]   +
				grad[x0][y1][1]*2 + grad[x1][y1][1]*4 + grad[x2][y1][1]*2 +
				grad[x0][y2][1]   + grad[x1][y2][1]*2 + grad[x2][y2][1];
			--]]
			
			local ny = --grad[x1][y1][2] * 18
			---[[
				grad[x0][y0][2]   + grad[x1][y0][2]*2 + grad[x2][y0][2] +
				grad[x0][y1][2]*2 + grad[x1][y1][2]*4 + grad[x2][y1][2]*2 +
				grad[x0][y2][2]   + grad[x1][y2][2]*2 + grad[x2][y2][2];
			--]]
							
			-- after summing up the two vectors z becomes 2
			-- nz^2 = (9 * 2*2)^2 = 36^2 = 1296
			-- the first *2 is because of the gausian distribution
			-- the second *2 because there is `nx' and `ny'
			local len = sqrt(nx^2 + ny^2 + 1296)
			
			-- Compute the gradient vector and store in
			outData:setPixel( x1, y1, 
				nx/len * 127+127,
				ny/len * 127+127,
				36/len*255,
				255);
		end
	end
	
end


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

local vx = 30;
local vy = 0;
local fst = 5;
function love.update(dt)
	top1:Update(dt);
	
	if fst > 0 then
		dt = 0;
		fst = fst-1;
	end
	
	local xd, yd = arenaNMap:getPixel( top1.topPhysics.x, top1.topPhysics.y );
	
	vx = vx - vx*(0.007*dt) + (xd/127 - 1)*dt*50;
	vy = vy - vy*(0.007*dt) + (yd/127 - 1)*dt*50;
	
	top1.topPhysics.x = top1.topPhysics.x + vx*dt*4;
	top1.topPhysics.y = top1.topPhysics.y + vy*dt*4;
	
end

function love.draw()
	love.graphics.translate( -top1.topPhysics.x +love.graphics.getWidth()/2, -top1.topPhysics.y +love.graphics.getHeight()/2 );
	love.graphics.setPixelEffect( nil );
	love.graphics.draw( arenaImg, 0, 0, 0, 1, 1 );
	top1:Draw();	
end


--Shape affects physical traits - speed, weight, attack
--Color and symbols affect special abilities