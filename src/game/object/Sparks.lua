--===========================================================================--
--  Dependencies
--===========================================================================--
local cos				= math.cos
local sin				= math.sin
local pi 				= math.pi
local random			= math.random


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Constants
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local NUM_SPARKS = 40


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Sparks : A sparks animation special effect object
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Sparks = {}
Sparks.__index = Sparks


-------------------------------------------------------------------------------
--  Sparks:new : creates new sparks
-------------------------------------------------------------------------------
function Sparks:new( x, y, norm )
	local obj = {}
	
	obj.x = x;
	obj.y = y;
	obj.norm = norm;
	obj.counter = nil;
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  Sparks:Update : Updates the sparks animation counter
-------------------------------------------------------------------------------
function Sparks:Update( dt )
	if self.counter then
		self.counter = self.counter - dt;
	end
end


-------------------------------------------------------------------------------
--  Sparks:SetAnimDuration : Sets the animation duration
-------------------------------------------------------------------------------
function Sparks:SetAnimDuration( sec )
	self.counter = sec;
end


-------------------------------------------------------------------------------
--  Sparks:IsAnimOver : Returns whether the animation is over
-------------------------------------------------------------------------------
function Sparks:IsAnimOver()
	if self.counter then
		return self.counter <= 0;
	else
		return true;
	end
end


-------------------------------------------------------------------------------
--  Sparks:Draw : Draws sparks
-------------------------------------------------------------------------------
function Sparks:Draw()
	local g = love.graphics;
	
	local maxSparkLen = 6;
	local minSparkLen = 2;
	local sparkLenDif = maxSparkLen - minSparkLen
	
	g.setBlendMode( "additive" );
	
	-- Draw friction lines
	for i= 1, NUM_SPARKS do
		local angle = random() * pi*2;
		
		-- The spark end	
		local sparkX2 = (cos(angle)-random())*sparkLenDif + minSparkLen;
		local sparkY2 = (sin(angle)-random())*sparkLenDif + minSparkLen;
		
		-- The spark start
		local randomStart = random();
		local sparkX1 = sparkX2 * randomStart; 
		local sparkY1 = sparkY2 * randomStart;
		
		-- Normal perpendicular vector
		local normPerpX = self.norm.y; 
		local normPerpY = -self.norm.x;
		
		-- We need the spark end to normal perpendicular dot products
		-- to scale the sparks along the normal perp vector
		local dot1 = sparkX1 * normPerpX + sparkY1 * normPerpY; 
		local dot2 = sparkX2 * normPerpX + sparkY2 * normPerpY;
		
		
		-- Set random yellowish color
		g.setColor( 255,
					255 -random(150),
					80  +random(50),
					255 -random(50)
				   );
		
		-- Draw the spark
		g.line( self.x + sparkX1 + 10*normPerpX*dot1, 
				self.y + sparkY1 + 10*normPerpY*dot1,
				self.x + sparkX2 + 10*normPerpX*dot2  - random(),
				self.y + sparkY2 + 10*normPerpY*dot2  - random()
			  );
	end
	g.setBlendMode( "alpha" );
	g.setColor( 255, 255, 255, 255 );
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Sparks;