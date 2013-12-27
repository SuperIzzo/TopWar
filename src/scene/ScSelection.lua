--===========================================================================--
--  Dependencies
--===========================================================================--
local Dyzk				= require 'src.object.Dyzk'
local ScBattle			= require 'src.scene.ScBattle'
local SceneManager		= require 'src.scene.SceneManager'
local MathUtils 		= require 'src.math.MathUtils'
local Message			= require 'src.network.Message'
local Client			= require 'src.network.Client'

local round 			= MathUtils.Round


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class ScSelection : Selection scene 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local ScSelection = {}
ScSelection.__index = ScSelection


function ScSelection:new()

	local obj = {}
	
	local dyzkList = {}
	
	table.insert( dyzkList, "DyzkAA001" );
	table.insert( dyzkList, "DyzkAA002" );
	table.insert( dyzkList, "DyzkAA003" );
	table.insert( dyzkList, "DyzkAA004" );
	
	local dyzx = {}
	obj._dyzx = dyzx
	for i, name in ipairs( dyzkList ) do
		dyzx[i] = Dyzk:new( "data/dyzx/"..name..".png" );
	end
	
	obj._selection = 1;
	
	return setmetatable( obj, self );
end



function ScSelection:Init()
end


local img = love.graphics.newImage("data/dyzx/DyzkAA001.png");
local ang = 0;

local function drawBox( x,y, w,h, mode )
	local g = love.graphics;
	local cornerCut = 32
	mode = mode or "line"
	
	g.polygon( mode, 
		x+cornerCut, y, 
		x+w, y, 
		x+w, y+h-cornerCut,
		x+w-cornerCut, y+h,
		x, y+h,
		x, y+cornerCut,
		x+cornerCut, y)
end

local function drawGridBox( x,y, w,h )
	local g = love.graphics;
	
	g.setColor( 0, 0, 180 );
	drawBox( x, y, w, h, "fill" );
	
	g.setColor( 0, 100, 180 );
	for i=0, 300/8 do
		g.line(260, 100+i*8, 260+280, 100+i*8);
	end
	for i=0, 280/8 do
		g.line(260+i*8, 100, 260+i*8, 400);
	end
	
	g.setColor( 0, 160, 200 );
	drawBox( x,y, w,h, "line" )
end


function ScSelection:Draw()
	local g = love.graphics;
	
	g.setBackgroundColor( 0, 15, 30 );
	g.clear();
	
	g.setColor( 0, 160, 200 );
	drawBox( 150, 20, 500, 60 );
	
	drawBox( 20, 100, 220, 300 );
	drawBox( 560, 100, 220, 300 );
	
	
	drawGridBox( 260, 100, 280, 300 );
	
	g.setColor( 255, 255, 255 );
	
	local xCenter = 260 + (280-256)/2+128;
	local yCenter = 100 + (300-256)/2 +128
	
	local dyzk = self._dyzx[ self._selection ];
	ang = ang + 0.004;
	g.draw( dyzk.image , xCenter, yCenter, ang,1,1,128, 128 );
	
	g.setColor( 0, 160, 200 );
	
	g.circle( "line",
		xCenter,
		yCenter,
		130 );
		
	g.line( xCenter+64, yCenter-64, xCenter+128, yCenter-128 );
	g.line( xCenter+128, yCenter-128, xCenter+180, yCenter-128 );	
	g.circle( "line", xCenter+185, yCenter-128, 5 );
	
	g.line( xCenter+96, yCenter, xCenter+180, yCenter );
	g.circle( "line", xCenter+185, yCenter, 5 );
		
		
	-- Big selection wheel
	g.circle( "line", 400, 1230, 800, 100 )
	g.line( 400, 446, 400, yCenter+100 );
	
	for i= -2, 2 do
		local ang = math.pi/2 -i*0.28
		
		local xx = 400  + math.cos(ang)*720;
		local yy = 1230 - math.sin(ang)*720;
		
		g.setColor( 0, 160, 200 );
		g.circle( "line", xx, yy, 64 );
		
		local id = self._selection + i;
		if id<1 then
			id = id + #self._dyzx;
		end
		if id>#self._dyzx then
			id = id - #self._dyzx;
		end
		local dyzk = self._dyzx[id];
		
		g.setColor( 255, 255, 255 );
		g.draw( dyzk.image , xx, yy, 0,0.48,0.48, 128, 128 );
	end
	
	
	-- Stats
	local phDyzk = dyzk:GetPhysicsBody()
	g.print("radius: " .. round(phDyzk:GetRadius()), 60, 130 );
	g.print("weight: " .. round(phDyzk:GetWeight(), 1) .. "g", 60, 150 );
	g.print("balance: " .. round(phDyzk:GetBalance()*100) .. "%", 60, 170 );
	g.print("spike: " .. round(phDyzk:GetJaggedness()*100) .. "%", 60, 190 );
end

function ScSelection:Update( dt )
end

function ScSelection:Control( control )

	--print( "Control: ", control.id, control.value )

	if 	control.player == 1 and not control.value then

		if control.id == "Left" then
			self._selection = self._selection-1;
			if self._selection<1 then
				self._selection = self._selection + #self._dyzx
			end
		end
		
		if control.id == "Right" then
			self._selection = self._selection+1;
			if self._selection>#self._dyzx then
				self._selection = self._selection - #self._dyzx
			end
		end
		
		if control.id == "A" then
			local sceneMgr = SceneManager:GetInstance();
			local battleScene = ScBattle:new();
			local dyzk = self._dyzx[self._selection]
			
			local client = Client:GetInstance();
			local msg = {}
			local phDyzk = dyzk:GetPhysicsBody()
			
			msg.type = Message.Type.DYZK_DESC
			msg.dyzk = {}
			msg.dyzk.radius  = phDyzk:GetRadius();
			msg.dyzk.weight  = phDyzk:GetWeight();
			msg.dyzk.jag 	 = phDyzk:GetJaggedness();
			msg.dyzk.balance = phDyzk:GetBalance();
			
			client:Send( msg );
			
			battleScene:AddDyzk( dyzk )
			sceneMgr:SetScene( battleScene )
		end
	end
end


return ScSelection;