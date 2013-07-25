local Sparks = {}
Sparks.__index = Sparks


function Sparks:new( x, y, norm )
	local obj = {}
	
	obj.x = x;
	obj.y = y;
	obj.norm = norm;
	
	return setmetatable( obj, self );
end


function Sparks:Draw()
	local g = love.graphics;
	
	-- Draw friction lines
	for i= 1, 40 do
		local ang = math.random() * math.pi*2;
		
		local sparkX2 = math.cos( ang ) *4 + 2 -math.random()*4;
		local sparkY2 = math.sin( ang ) *4 + 2 -math.random()*4;
		
		local f = math.random();
		local sparkX1 = sparkX2 * f; 
		local sparkY1 = sparkY2 * f;
		
		local n_perpx = self.norm.y; 
		local n_perpy = -self.norm.x;
		
		local dot1 = sparkX1 * n_perpx + sparkY1 * n_perpy; 
		local dot2 = sparkX2 * n_perpx + sparkY2 * n_perpy;
		
		g.setBlendMode( "additive" );
		g.setColor( 255,
					255-math.random(150),
					80+ math.random(50),
					255 - math.random(50)
				   );
		
		g.line( self.x + sparkX1 + 10*n_perpx*dot1, 
				self.y + sparkY1 + 10*n_perpy*dot1,
				self.x + sparkX2 + 10*n_perpx*dot2  - math.random(),
				self.y + sparkY2 + 10*n_perpy*dot2  - math.random()
			  );
		g.setBlendMode( "alpha" );
	end
	
	g.setColor( 255, 255, 255, 255 );
end


return Sparks;