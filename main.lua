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
	
	love.graphics.setCaption( "TopWar - RPM: " .. math.floor(phTop.angleVel * 9.5493) )	
	
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
	columnA[-1] = columnA[0]
	columnB[-1] = columnB[0]
	
	local diagonalLength = sqrt(2);
	
	for x = 0, height-2 do		
		local C1 = imgData:getPixel( x, 0 );
		local C0 = C1;
		columnB[-1] = columnB[0];
		
		for y = 0, height-2 do
			local C2 = imgData:getPixel( x+1, y+1 );
			
			-- Diagonals have less weight, when using gausian distribution
			local dg1 = ( columnA[y-1] - C2 ) * diagonalLength;
			local dg2 = ( columnA[y+1] - C0 ) * diagonalLength;
			
			local hr = (columnA[y] - C1  + dg1 + dg2)/2;
			local vr = (columnB[y-1] - columnB[y+1]  + dg1 - dg2)/2;
			
			-- Update colors
			columnA[y-1] = columnB[y-1];			
			columnB[y-1] = C0;
			C0 = C1;
			C1 = C2;

			-- There are a few magic numbers, used as optimisation 
			-- (we're in a big loop) which take advantage of z being easy to
			-- calculate staticaly based on the kernel shape.
			-- z = 1 from hr + 1 from vr + 1.414 from the two diagonals
			-- z = 3.4142
			-- z^2 = 11.657
			-- z * the full blue range = 3.4142 * 255 = 870.624
			local len = sqrt(hr^2 + vr^2 + 11.657 )
				
			-- hr and vr need to be divided by len and multiplied by 127
			-- to turn into color space
			local term = 127/len;
						
			outData:setPixel( x, y, 
				hr*term + 127,
				vr*term + 127,
				870.624/len,	
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
	
	local tx, ty = top1.topPhysics.x, top1.topPhysics.y;
	local ftx, fty = math.floor(tx), math.floor(ty);
	local dtx, dty = tx-ftx, ty-fty
	
	-- bilinear interpolation
	local xd00, yd00 = arenaNMap:getPixel( ftx, fty );
	local xd10, yd10 = arenaNMap:getPixel( ftx+1, fty );
	local xd01, yd01 = arenaNMap:getPixel( ftx, fty+1 );
	local xd11, yd11 = arenaNMap:getPixel( ftx+1, fty+1 );	
	
	local xd0 = xd00*(1-dtx) + xd10*dtx;	
	local yd0 = yd00*(1-dtx) + yd10*dtx;
	local xd1 = xd01*(1-dtx) + xd11*dtx;
	local yd1 = yd01*(1-dtx) + yd11*dtx;
	local xd = xd0*(1-dty) + xd1*dty;
	local yd = yd0*(1-dty) + yd1*dty;
	
	
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