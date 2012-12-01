Top = 
{
	new = function(self, ph )
		local obj = {};
		
		obj._phys = ph;
		obj.color = {255, 255, 255, 255 };
		
		return setmetatable(obj, self); 
	end;
	
	Draw = function(self, g)
		if self._img then
			local rad = self._img:getWidth()/2;
			
			local rot = math.abs(self._phys.body:getAngularVelocity()*8);
			
			g.setColor(255,255,255, math.min(255, 100 + 155/rot));
			for i = 0, rot do
				g.draw( self._img, 
					self._phys.body:getX(),
					self._phys.body:getY(),
					self._phys.body:getAngle()*100 + i/(rot+math.random()) + math.random()*0.01,
					self._phys.shape:getRadius()/rad,
					self._phys.shape:getRadius()/rad,
					rad, rad);
			end
				
		else
			g.setColor( unpack(self.color) );
			g.circle("fill", 
				self._phys.body:getX(), 
				self._phys.body:getY(), 
				self._phys.shape:getRadius() );
			
			g.setColor( 180, 180, 180 );
			g.circle("fill", 
				self._phys.body:getX(), 
				self._phys.body:getY(), 
				20 );
		end;
	end;
	
	SetImage = function(self, img)
		self._img = img;
	end;
}

Top.__index = Top;



Vector =
{
	new = function(self, x, y)
		local obj = {};
		
		obj.x = x;
		obj.y = y;
		
		return setmetatable(obj, self);
	end;
	
	Dot = function(self, other)
		return self.x*other.x + self.y*other.y;
	end;
	
	Length = function(self)
		return math.sqrt( self.x*self.x + self.y*self.y ); 
	end;
	
	Unit = function(self)
		local len = self:Length();
		if len ~= 0 then
			return Vector:new( self.x/len, self.y/len );
		else
			return Vector:new( 0, 0 );
		end
	end;
	
	Normalize = function(self)
		local len = self:Length();
		if len ~= 0 then
			self.x = self.x/len;
			self.y = self.y/len;
		end;
	end;
	
	__sub = function(self, other)
		return Vector:new( self.x-other.x, self.y-other.y);
	end;
	
	__add = function(self, other)
		return Vector:new( self.x+other.x, self.y+other.y);
	end;
	
	__mul = function(self, scal)
		return Vector:new( self.x*scal, self.y*scal);
	end;
	
	__div = function(self, scal)
		return Vector:new( self.x/scal, self.y/scal);
	end;
	
	__unm = function(self)
		return Vector:new( -self.x, -self.y );
	end;
	
	__tostring = function(self)
		return "[".. self.x .. ", " .. self.y .."]";
	end;
}

Vector.__index = Vector;


local function sign( a )
	if a > 0 then
		return 1;
	elseif a < 0 then
		return -1;
	else
		return 0;
	end;
end


math.randomseed( os.time() )


local function beginContact(a,b, col)
	
end

local function endContact(a,b, col)
	
end

local function preSolve(a,b, col)
	if a:getUserData() == "top" and b:getUserData() == "top" then
		local colPos = Vector:new( col:getPositions() );
		
		local aPos = Vector:new( a:getBody():getX(), a:getBody():getY() );
		local bPos = Vector:new( b:getBody():getX(), b:getBody():getY() );
		
		local norm = colPos - aPos;
		norm:Normalize();
		
		local aDir = Vector:new( a:getBody():getLinearVelocity() );
		local bDir = Vector:new( b:getBody():getLinearVelocity() );
		local aSpeed = aDir:Length();
		local bSpeed = bDir:Length();
		
		aDir = aDir / aSpeed;
		bDir = bDir / bSpeed;
		
		local aDot = aDir:Dot( norm );
		local bDot = bDir:Dot( -norm );
		
		
		local curve = math.random();
		curve = curve*curve;
		curve = curve*curve;
		
		local aAttack = 200;
		local bAttack = 200;
		
		local aLinForce = (math.abs(bDot)) * 
			(bSpeed + bAttack*0.55 + aAttack*0.45) * curve;
			
		local bLinForce = (math.abs(aDot)) *
			(aSpeed + aAttack*0.55 + bAttack*0.45) * curve;
		
		a:getBody():applyLinearImpulse(  -norm.x * aLinForce, -norm.y * aLinForce );
		b:getBody():applyLinearImpulse(   norm.x * bLinForce,  norm.y * bLinForce );
		
		
		local aAngForce = (math.max(0, -aDot))*(bSpeed + bAttack);
		local bAngForce = (math.max(0, -bDot))*(aSpeed + aAttack);
		
		a:getBody():applyAngularImpulse( -aAngForce*1 );
		b:getBody():applyAngularImpulse( -bAngForce*1 );
		
		
		
		--print( "forces: ", aForce, bForce );
		
		
		drawFric = true;
		drawFricPosX, drawFricPosY = col:getPositions();
		drawFricNorX, drawFricNorY = norm.x, norm.y;
		
		forceA = forceA + aLinForce;
		forceB = forceB + bLinForce;
	end
end

drawFric = 0;
drawFricPosX = 0;
drawFricPosY = 0;
drawFricNorX = 0;
drawFricNorY = 0;

forceA = 0
forceB = 0

local function postSolve(a,b, col)	
	
	if false and a:getUserData() == "top" and b:getUserData() == "top" then
		local norm = Vector:new( col:getNormal() );
		norm:Normalize();
	
		local forceback = math.random();
		forceback = forceback * forceback;
		forceback = forceback * forceback;
	
		--print( forceback );
	
		local aDir = Vector:new( a:getBody():getLinearVelocity() );
		local bDir = Vector:new( b:getBody():getLinearVelocity() );
		local aSpeed = aDir:Length();
		local bSpeed = bDir:Length();
		
		aDir = aDir / aSpeed;
		bDir = bDir / bSpeed;
		
		
		local an_dot = -aDir:Dot( norm ); 
		local bn_dot =  bDir:Dot( norm );
		
		local aattack = 600;
		local battack = 600;
		
		local aforce = ( math.max(0, -bn_dot - bn_dot * an_dot) * (bSpeed/1000 + battack*0.55 + aattack*0.45)) * forceback;
		local bforce = ( math.max(0, -an_dot - bn_dot * an_dot) * (aSpeed/1000 + aattack*0.55 + battack*0.45)) * forceback;
		
	
		print("");
		--print( "speeds: ", a_speed, b_speed );
		print( "dir A: ", aDir );
		print( "dir B: ", bDir );
		print( "norm:  ", norm );
		print( "atk:  ", math.max(0, bn_dot - bn_dot * an_dot), math.max(0, an_dot - bn_dot * an_dot) );
		print( "dots: ", an_dot, bn_dot );
		--print( "forces: ", math.floor(aforce*100), math.floor(bforce*100) );
	
		a:getBody():applyLinearImpulse(  -norm.x * aforce, -norm.y * aforce );
		b:getBody():applyLinearImpulse(   norm.x * bforce,  norm.y * bforce );
		
		
		a:getBody():applyAngularImpulse( -aforce );
		b:getBody():applyAngularImpulse( -bforce );
		
		drawFric = true;
		drawFricPosX, drawFricPosY = col:getPositions();
		drawFricNorX, drawFricNorY = norm.x, norm.y;
		
		forceA = forceA + aforce;
		forceB = forceB + bforce;
	end;
end



local game = {};

function love.load()
	love.physics.setMeter( 64 );
	game.world = love.physics.newWorld(0,0,true);
	
	game.world:setCallbacks(beginContact, endContact, preSolve, postSolve);
	
	
	
	local top1Body = love.physics.newBody( 
							game.world,
							100,
							100,
							"dynamic"
						);
	local top1Shape  = love.physics.newCircleShape( 50 );
	
	local top1Fix = love.physics.newFixture( top1Body, top1Shape, 1 );
	
	local top1Ph = 
	{
		body	= top1Body;
		shape	= top1Shape;
		fixture = top1Fix; 
	}
	
	game.top1 = Top:new( top1Ph );
	game.top1.color = { 255, 0, 0, 255};
	
	
	local top2Body = love.physics.newBody( 
							game.world,
							500,
							300,
							"dynamic"
						);
	local top2Shape  = love.physics.newCircleShape( 50 );
	
	local top2Fix = love.physics.newFixture( top2Body, top2Shape, 1 );
	
	local top2Ph = 
	{
		body	= top2Body;
		shape	= top2Shape;
		fixture = top2Fix; 
	}
	
	game.top2 = Top:new( top2Ph );
	game.top2.color = { 0, 0, 255, 255 };
	
	
	
	game.top1._phys.body:setAngularVelocity( math.pi * 100 );
	game.top2._phys.body:setAngularVelocity( math.pi * 100 );
	
	game.top1._phys.body:setAngularDamping( 0.01 );
	game.top2._phys.body:setAngularDamping( 0.01 );
	
	game.top1._phys.body:setLinearDamping( 0.04 );
	game.top2._phys.body:setLinearDamping( 0.04 );
	
	
	game.top1._phys.fixture:setUserData("top");
	game.top2._phys.fixture:setUserData("top");
	
	
	spinImg = love.graphics.newImage("data/spinner1.png");
	game.top1:SetImage( spinImg );
	
	spinImg = love.graphics.newImage("data/spinner2.png");
	game.top2:SetImage( spinImg );
	
	matDepth = love.graphics.newImage("data/DefaultStadiumMask.png");
	mat = love.graphics.newImage("data/DefaultStadium.png");
	
	--love.graphics.toggleFullscreen();
end;



function love.update( dt )
	local centerX = 1024 / 2;
	local centerY = 1024 / 2;
	
	local top1X = game.top1._phys.body:getX();
	local top1Y = game.top1._phys.body:getY();
	
	game.top1._phys.body:applyLinearImpulse( 
		(centerX - top1X)/centerX*4, 
		(centerY - top1Y)/centerY*4
	);
	
	
	local top2X = game.top2._phys.body:getX();
	local top2Y = game.top2._phys.body:getY();
	
	game.top2._phys.body:applyLinearImpulse( 
		(centerX - top2X)/centerX*4, 
		(centerY - top2Y)/centerY*4
	);
	
	
	local aspeed = 400;
	local bspeed = 400;
	
	local aDir = Vector:new(0,0);
	local bDir = Vector:new(0,0);
	
	if love.keyboard.isDown("up") then
		aDir.y = -1;
	end
	
	if love.keyboard.isDown("down") then
		aDir.y = 1;
	end
	
	if love.keyboard.isDown("left") then
		aDir.x = -1;
	end
	
	if love.keyboard.isDown("right") then
		aDir.x = 1;
	end
	
	if love.keyboard.isDown("rshift") then
		aspeed = aspeed * 10;
	end
	
	aDir:Normalize();
	game.top1._phys.body:applyForce( aDir.x*aspeed, aDir.y*aspeed);
	
	
	if love.joystick.getNumJoysticks() > 0 then
		bDir.x = love.joystick.getAxis( 1, 1 );
		bDir.y = love.joystick.getAxis( 1, 2 );
		print(bDir);
	end
	
	if love.keyboard.isDown("w") then
		bDir.y = -1;
	end
	
	if love.keyboard.isDown("s") then
		bDir.y = 1;
	end
	
	if love.keyboard.isDown("a") then
		bDir.x = -1;
	end
	
	if love.keyboard.isDown("d") then
		bDir.x = 1;
	end
	
	local bBoost = 0;
	if love.joystick.isDown( 1, 1 ) then
		bBoost = 1;
		print("Boost");
		bspeed = bspeed*10;
	end;
	
	
	bDir:Normalize();
	game.top2._phys.body:applyForce( bDir.x*bspeed, bDir.y*bspeed);
	 
	 
	game.world:update( dt );
end;



local prevCamX = 0;
local prevCamY = 0;
local prevCamScX = 0;
local prevCamScY = 0;

function drawCamera( g )
	local top1Pos = Vector:new( game.top1._phys.body:getX(), game.top1._phys.body:getY() );
	local top2Pos = Vector:new( game.top2._phys.body:getX(), game.top2._phys.body:getY() )
	local top1Rad = game.top1._phys.shape:getRadius();
	local top2Rad = game.top2._phys.shape:getRadius();
	local maxrad = math.max( top1Rad, top2Rad );
	
	local minCorn = Vector:new( math.min(top1Pos.x, top2Pos.x), 
								math.min(top1Pos.y, top2Pos.y) );
	local maxCorn = Vector:new( math.max(top1Pos.x, top2Pos.x), 
								math.max(top1Pos.y, top2Pos.y) );
	local camPos = minCorn + (maxCorn - minCorn)/2;
	local margin = 300;
	local camSize = maxCorn - minCorn + Vector:new(margin + maxrad*2,margin + maxrad*2);
	camSize.x = math.max( 400, camSize.x );
	
	local scalef = math.min(800/camSize.x, 600/camSize.y);
	
	local f = math.min(1, 0.7/scalef + 0.1); --camSize.y/800 +0.3);
	g.scale( 1, f );
	g.scale( scalef, scalef );
	g.translate( -camPos.x +camSize.x/2 , -camPos.y +camSize.y/f/2 );
	--g.rotate( math.pi/4 );
	
	
	--g.translate( -camPos.x +(maxCorn.x-minCorn.x)/2 , -camPos.y +(maxCorn.y-minCorn.y)/2 );
	
end

function love.draw()
	local g = love.graphics;
	
	drawCamera( g );
	--g.translate(-112, -212);
	--g.scale( 2.5, 0.75 );
	--print( "Cam pos: ", camPos );
	--print( "Cam size: ", camSize );
	
	
	g.setColor(255,255,255, 255);
	g.draw( mat, 0,0) -- , 0, 800/1024, 600/1024 );
	
	--rpm = av/(pi/30)
	g.setColor( 255, 255, 255 );
	g.print( "RPM: "
			 .. math.floor(game.top1._phys.body:getAngularVelocity()/math.pi*30  * 100)
			 .. ", "
			 .. math.floor(game.top2._phys.body:getAngularVelocity()/math.pi*30  * 100)
			 .. "\nDMG: "
			 .. forceA
			 .. ", "
			 .. forceB
			 , 100, 100 ); 
	
	game.top1:Draw( g );
	game.top2:Draw( g );
	
	
	-- Draw friction lines
	if drawFric  then
	
		for i= 1, 40 do
		
			local ang = math.random() * math.pi*2;
			
			local sparkX2 = math.cos( ang ) *4 + 2 -math.random()*4;
			local sparkY2 = math.sin( ang ) *4 + 2 -math.random()*4;
			
			local f = math.random();
			local sparkX1 = sparkX2 * f; 
			local sparkY1 = sparkY2 * f;
			
			local n_perpx = drawFricNorY; 
			local n_perpy = -drawFricNorX;
			
			local dot1 = sparkX1 * n_perpx + sparkY1 * n_perpy; 
			local dot2 = sparkX2 * n_perpx + sparkY2 * n_perpy;
			
			g.setBlendMode( "additive" );
			g.setColor( 255,
						255-math.random(150),
						80+ math.random(50),
						255 - math.random(50)
					   );
			
			g.line( drawFricPosX + sparkX1 + 10*n_perpx*dot1, 
					drawFricPosY + sparkY1 + 10*n_perpy*dot1,
					drawFricPosX + sparkX2 + 10*n_perpx*dot2  - math.random(),
					drawFricPosY + sparkY2 + 10*n_perpy*dot2  - math.random()
				  );
			g.setBlendMode( "alpha" );
		end
		drawFric = false;
		
		--[[
			drawFricPosX = 0;
		drawFricPosY = 0;
		drawFricNorX = 0;
		drawFricNorY = 0;
		--]]
	end
	
	--[[
	local xx, yy = game.top1._phys.body:getLinearVelocity();
	local tx = game.top1._phys.body:getX(); 
	local ty = game.top1._phys.body:getY(); 
	
	g.setColor(0,255,0);
	g.line( tx, ty, tx + xx, ty + yy );
	
	xx, yy = game.top2._phys.body:getLinearVelocity();
	tx = game.top2._phys.body:getX(); 
	ty = game.top2._phys.body:getY(); 
	
	g.setColor(0,255,0);
	g.line( tx, ty, tx + xx, ty + yy );
	--]]
end;