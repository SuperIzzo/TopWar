require 'src.strict'

-- lunatest dependencies
declare 'random'
declare 'fail'
declare 'skip'
declare 'assert_true'
declare 'assert_false'
declare 'assert_nil'
declare 'assert_not_nil'
declare 'assert_equal'
declare 'assert_not_equal'
declare 'assert_gt'
declare 'assert_lt'
declare 'assert_gte'
declare 'assert_lte'
declare 'assert_len'
declare 'assert_not_len'
declare 'assert_match'
declare 'assert_not_match'
declare 'assert_boolean'
declare 'assert_not_boolean'
declare 'assert_number'
declare 'assert_not_number'
declare 'assert_string'
declare 'assert_not_string'
declare 'assert_table'
declare 'assert_not_table'
declare 'assert_function'
declare 'assert_not_function'
declare 'assert_thread'
declare 'assert_not_thread'
declare 'assert_userdata'
declare 'assert_not_userdata'
declare 'assert_metatable'
declare 'assert_not_metatable'
declare 'assert_error'
declare 'assert_random'

--local TestMain =		require "test.TestMain"


--TestMain:Run();

--Shape affects physical traits - speed, weight, attack
--Color and symbols affect special abilities

local Wr = 0.299
local Wb = 0.114
local Wg = 1 - Wr - Wb;

local Umax = 0.436
local Vmax = 0.615

local Uf = Umax/(1 - Wb)
local Vf = Vmax/(1 - Wr)


local function round( x )
	return math.floor(x + 0.5)
end

local function RGB2YUV( r, g, b, a )
	local y = Wr*r + Wg*g + Wb*b;
	local u = Uf*(b - y);
	local v = Vf*(r - y);
	
	return y, u, v, a;
end

local function YUV2RGB( y, u, v, a )
	local r = v/Vf;
	local b = u/Uf;
	local g = -b*Wb/Wg -r*Wr/Wg
	
	return y+r, y+g, y+b, a;
end

local function safeGetPixel( img, x, y )
	if( x >= 0 and x <= img:getWidth()-1 and y >= 0 and y <= img:getHeight()-1 ) then
		return img:getPixel( x, y );
	else
		return 0, 0, 0, 0;
	end
end

local function ComputeEdges( imgDat )
	local YUVData = {}
	local nImgData = love.image.newImageData( imgDat:getWidth(), imgDat:getHeight() );
	
	YUVData[1] = {};
	YUVData[2] = {};
	
	for x =2, imgDat:getWidth()-2 do
		YUVData[x+1] = {};
		for y =2, imgDat:getHeight()-2 do
			
			if x==2 or y==2 then
				YUVData[x-1][y-1] = { RGB2YUV( imgDat:getPixel(x-1, y-1) ) }
				YUVData[x-1][y] = { RGB2YUV( imgDat:getPixel(x-1, y) ) }
				YUVData[x-1][y+1] = { RGB2YUV( imgDat:getPixel(x-1, y+1) ) }
				YUVData[x][y-1] = { RGB2YUV( imgDat:getPixel(x, y-1) ) }
				YUVData[x][y] = { RGB2YUV( imgDat:getPixel(x, y) ) }
				YUVData[x][y+1] = { RGB2YUV( imgDat:getPixel(x, y+1) ) }
				YUVData[x+1][y-1] = { RGB2YUV( imgDat:getPixel(x+1, y-1) ) }
				YUVData[x+1][y] = { RGB2YUV( imgDat:getPixel(x+1, y) ) }
				YUVData[x+1][y+1] = { RGB2YUV( imgDat:getPixel(x+1, y+1) ) }
			else
				YUVData[x+1][y+1] = { RGB2YUV( imgDat:getPixel(x+1, y+1) ) }
			end
			
			local valH = (	math.abs(YUVData[x][y][1] - YUVData[x-1][y][1])
						  * math.abs(YUVData[x][y][1] - YUVData[x+1][y][1]))/255;
						  
			local valL = (	math.abs(YUVData[x][y][1] - YUVData[x][y-1][1])
						  * math.abs(YUVData[x][y][1] - YUVData[x][y+1][1]))/255;
						  
			local valD = (	math.abs(YUVData[x][y][1] - YUVData[x-1][y-1][1])
						  * math.abs(YUVData[x][y][1] - YUVData[x+1][y+1][1]))/255;
						  
			local valA = (	math.abs(YUVData[x][y][1] - YUVData[x-1][y+1][1])
						  * math.abs(YUVData[x][y][1] - YUVData[x+1][y-1][1]))/255;
						  
			local val = math.max( valH, valL, valD, valA );
					  
			nImgData:setPixel( x,y, val,val,val, 255 );
		end
	end
	
	return nImgData;
end

local imgDat = nil;
local img = nil;
local img2 = nil;
function love.draw()

	if not img then
		imgDat = love.image.newImageData( "test/img/pixmap.png" );	
		img = love.graphics.newImage( imgDat )
		img2 = love.graphics.newImage( ComputeEdges(imgDat) )
	end
	
	love.graphics.draw( img, 0, 0 );
	love.graphics.draw( img2, 0, 0 );
	
end