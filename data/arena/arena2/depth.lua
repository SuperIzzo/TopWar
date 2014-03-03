local arena = {}

local numBumps = 8;
local bumpDistX = 0;
local bumpDistY = 0;
local bumpSize = 0.04;
local bumpElevation = 0.4;


function arena:SetSize( w, h )
	self.width  = w;
	self.height = h;

	if w>h then
		self.dist = h/2;
	else
		self.dist = w/2;
	end

	self.dist = self.dist*0.9;

	bumpDistX = w/4;
	bumpDistY = h/4;
	bumpSize = bumpSize*w;

	self.bumps = {};
	for i=0, numBumps-1 do
		local bx = math.cos( math.pi*2 * i/numBumps );
		local by = math.sin( math.pi*2 * i/numBumps );

		bx = w/2 + bx*bumpDistX;
		by = h/2 + by*bumpDistY;

		self.bumps[i+1] = { x = bx, y = by };
	end
end


function arena:Get( x, y )
	local w, h = self.width, self.height;

	local pDist = ((x-w/2)^2 + (y-h/2)^2)^0.5;
	local rate = pDist/self.dist;
	rate = rate^3;

	for i = 1, #self.bumps do
		local b = self.bumps[i];
		local bumpHeight = ((x-b.x)^2 + (y-b.y)^2)^0.5;
		local elev = (1 - (bumpHeight/bumpSize)^3);
		if elev< 0 then
			elev = 0;
		end
		elev = elev;
		--print( bx, by );

		rate = rate + elev*bumpElevation;
	end

	if rate>1 then
		rate = 1;
	end

	return rate;
end


return arena;
