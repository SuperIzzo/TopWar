--===========================================================================--
--  Dependencies
--===========================================================================--
local PolarVector	= require 'src.math.PolarVector'
local Vector		= require 'src.math.Vector'
local MathUtils		= require 'src.math.MathUtils'

local assert 		= _G.assert
local sqrt			= _G.math.sqrt
local log			= _G.math.log
local max			= _G.math.max
local floor			= _G.math.floor
local asin			= _G.math.asin
local pi			= _G.math.pi
local clamp			= MathUtils.Clamp



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--  Constants
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local EFFECTIVE_ALPHA_THRESHOLD = 125
local RPS_TO_RPM_SCALE			= 9.5493



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class PhDyzkBody : The physical data and logic of a spinning PhDyzkBody object
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local PhDyzkBody = {}
PhDyzkBody.__index = PhDyzkBody;


-------------------------------------------------------------------------------
--  PhDyzkBody:new : Creates a new PhDyzkBody instance
-------------------------------------------------------------------------------
function PhDyzkBody:new()
	local obj = {}
	
	obj._weight 	= 0;
	obj._jaggedness = 0;
	obj._radius 	= 0;
	obj._balance	= 0;
	
	obj.x = 0;
	obj.y = 0;
	obj.vx = 0;
	obj.vy = 0;
	obj.ax = 0;
	obj.ay = 0;
	
	obj.ang = 0;
	obj.angVel = 0;
	
	obj._friction	= 0.01;
	obj._collisionListener = {};
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  PhDyzkBody:Update : Updates the PhDyzkBody
-------------------------------------------------------------------------------
function PhDyzkBody:Update( dt )
	local velWeight = 1 - self._friction*dt;
	self.vx = self.vx*velWeight + self.ax*dt;
	self.vy = self.vy*velWeight + self.ay*dt;
	
	self.x = self.x + self.vx*dt;
	self.y = self.y + self.vy*dt;
	
	self.angVel = self.angVel - dt*0.1;
	self.ang = self.ang + self.angVel*dt;
end


-------------------------------------------------------------------------------
--  PhDyzkBody:AddCollisionListener : Updates the PhDyzkBody
-------------------------------------------------------------------------------
function PhDyzkBody:AddCollisionListener( func, arg )
	self._collisionListener[ #self._collisionListener+1 ] =
	{ func=func, arg=arg };
end


-------------------------------------------------------------------------------
--  PhDyzkBody:SetPosition : Sets the location of the PhDyzkBody
-------------------------------------------------------------------------------
function PhDyzkBody:SetPosition( x, y )
	self.x = x;
	self.y = y;
end


-------------------------------------------------------------------------------
--  PhDyzkBody:SetVelocity : Sets the velocity of the PhDyzkBody
-------------------------------------------------------------------------------
function PhDyzkBody:SetVelocity( vx, vy )
	self.vx = vx;
	self.vy = vy;
end


-------------------------------------------------------------------------------
--  PhDyzkBody:SetAcceleration : Sets the acceleration of the PhDyzkBody
-------------------------------------------------------------------------------
function PhDyzkBody:SetAcceleration( ax, ay )
	self.ax = ax;
	self.ay = ay;
end


-------------------------------------------------------------------------------
--  PhDyzkBody:GetPosition : Returns the location of the PhDyzkBody
-------------------------------------------------------------------------------
function PhDyzkBody:GetPosition()
	return self.x, self.y;
end


-------------------------------------------------------------------------------
--  PhDyzkBody:GetVelocity : Returns the velocity of the PhDyzkBody
-------------------------------------------------------------------------------
function PhDyzkBody:GetVelocity()
	return self.vx, self.vy;
end


-------------------------------------------------------------------------------
--  PhDyzkBody:GetRPM : Returns the angular velocity in revolution per minutes
-------------------------------------------------------------------------------
function PhDyzkBody:GetRPM()
	return self:GetAngularVelocity()*RPS_TO_RPM_SCALE;
end


-------------------------------------------------------------------------------
--  PhDyzkBody:GetAngularVelocity : Returns the angular velocity
-------------------------------------------------------------------------------
function PhDyzkBody:GetAngularVelocity()
	return self.angVel;
end


-------------------------------------------------------------------------------
--  PhDyzkBody:GetWeight : Returns the weight of the PhDyzkBody
-------------------------------------------------------------------------------
function PhDyzkBody:GetWeight()
	return self._weight;
end


-------------------------------------------------------------------------------
--  PhDyzkBody:GetJaggedness : Returns the jaggedness of the PhDyzkBody
-------------------------------------------------------------------------------
function PhDyzkBody:GetJaggedness()
	return self._jaggedness;
end


-------------------------------------------------------------------------------
--  PhDyzkBody:GetRadius : Returns the radius of the PhDyzkBody
-------------------------------------------------------------------------------
function PhDyzkBody:GetRadius()
	return self._radius;
end


-------------------------------------------------------------------------------
--  PhDyzkBody:GetRadius : Returns the radius of the PhDyzkBody
-------------------------------------------------------------------------------
function PhDyzkBody:GetBalance()
	return self._balance;
end


-------------------------------------------------------------------------------
--  PhDyzkBody:SetWeight : Sets the weight of the PhDyzkBody
-------------------------------------------------------------------------------
function PhDyzkBody:SetWeight( weigth )
	assert( weigth >= 0 )
	
	self._weight = weigth;
end


-------------------------------------------------------------------------------
--  PhDyzkBody:SetJaggedness : Sets the jaggedness of the PhDyzkBody
-------------------------------------------------------------------------------
function PhDyzkBody:SetJaggedness( jag )
	assert( jag >= 0 and jag <= 1 )
	
	self._jaggedness = jag;
end


-------------------------------------------------------------------------------
--  PhDyzkBody:SetBalance : Sets the balance of the PhDyzkBody
-------------------------------------------------------------------------------
function PhDyzkBody:SetRadius( rad )
	assert( rad >= 0 )
	
	self._radius = rad;
end


-------------------------------------------------------------------------------
--  PhDyzkBody:SetBalance : Sets the balance of the PhDyzkBody
-------------------------------------------------------------------------------
function PhDyzkBody:SetBalance( balance )
	assert( balance >= 0 and balance <= 1)
	
	self._balance = balance;
end


-------------------------------------------------------------------------------
--  PhDyzkBody:OnDyzkCollision : Handles dyzk-dyzk collision
-------------------------------------------------------------------------------
function PhDyzkBody:OnDyzkCollision( other, primary )

	-- Ignore if the collision is being handle by other
	if not primary then return end;
	
	local x1, y1 = self:GetPosition();
	local x2, y2 = other:GetPosition();
	local rad1, rad2 = self:GetRadius(), other:GetRadius();
	
	-- Distance is the distance between the centers
	local distance = math.sqrt((x1-x2)^2 + (y1-y2)^2);
	local radDistance = rad1+rad2;
	
	-- Ratio is the ratio between the two radiuses
	local ratio = rad1/radDistance;
	
	-- The collision point
	local xCol, yCol = x1*ratio+x2*(1-ratio), y1*ratio+y2*(1-ratio);
	
	-- The collision normal is a normalized vector in the direction of
	-- the collision (i.e. the two centers)
	local collisionNormal = Vector:new(
				(x2-x1)/distance, 
				(y2-y1)/distance );
	
	-- Work out velocity, speed and direction
	local vel1 = Vector:new( self:GetVelocity() );
	local vel2 = Vector:new( other:GetVelocity() );
	
	local speed1 = vel1:Length();
	local speed2 = vel2:Length();
	local dir1 = vel1/speed1;
	local dir2 = vel2/speed2;
	
	-- Motion direction to collision normal dot product
	-- tell us which direction the dyzk is hit from in respect
	-- to the direction it is moving in:
	-- frontal collision(1), sides(0), back(-1)
	local dirNormDot1 = dir1:Dot( collisionNormal );
	local dirNormDot2 = -dir2:Dot( collisionNormal );
	
	-- facingTerm is how much do the two dyzx face each other
	-- safe arc is a modifier which increases or decreases the
	-- pushback negation area (higher is safer)
	local safeArc = 0.6
	local facingTerm = dirNormDot1*dirNormDot2 * safeArc;
	
	-- Force is calculated such that, if a dyzk is striken from the
	-- side it takes the most damage, if the two dyzx face each other
	-- directly they will stop and take almost no damage
	local force1 = math.max(0,dirNormDot2-facingTerm)
	local force2 = math.max(0,dirNormDot1-facingTerm)
	
	-- Term to move out of intersection
	local intersectionForce = ((radDistance+5)/distance)^4*10;
	
	local pushBack1 = 
				(
					force1 * 
					speed2 * 
					(1 + (self._jaggedness*0.3 + other._jaggedness*0.7)*0.2)
					+ (1 - self._balance*0.3 + other._balance*0.7) * 2
				) * other._weight / self._weight
				+ intersectionForce;
	local pushBack2 =
				(
					force2 *
					speed1 * 
					(1 + (self._jaggedness*0.7 + other._jaggedness*0.3)*0.2)
					+ (1 - self._balance*0.7 + other._balance*0.3) * 2
				) * self._weight / other._weight
				+ intersectionForce;
				 
	local rpmDmg1 = force1 
						* other.angVel * (self._jaggedness*0.2 + other._jaggedness*0.8)
	local rpmDmg2 = force2 
						* self.angVel * (self._jaggedness*0.8 + other._jaggedness*0.2)
	
	self.angVel = self.angVel - rpmDmg1/20 -0.2;
	other.angVel = other.angVel - rpmDmg2/20 -0.2;
	
	-- Apply the forces as two impulses in direction opposite to the 
	-- collision normal (to the dyzk centers)
	self:SetVelocity(	-collisionNormal.x*pushBack1,
						-collisionNormal.y*pushBack1 );
	other:SetVelocity(	collisionNormal.x*pushBack2,
						collisionNormal.y*pushBack2 );

	for i=1,#self._collisionListener do
		local listener = self._collisionListener[i];
		listener.func( 
				listener.arg, 
				{ x=xCol, y=yCol },
				{ x=collisionNormal.x, y=collisionNormal.y}
		);
	end
end


-------------------------------------------------------------------------------
-- PhDyzkBody:SetFromImageData : Sets the properties of a PhDyzkBody from an image
-------------------------------------------------------------------------------
function PhDyzkBody:SetFromImageData( imgData, scale )
	local scale 	= scale or 1;
	local imgSize	= Vector:new( imgData:getWidth()*scale, imgData:getHeight()*scale );	
	local halfSize	= imgSize/2;
	local radSpan	= halfSize:Length();
	
	-- Limit the angle loop to 1 pixel from a specific circle of precision 
	-- angSpan is an integer number that maps angles to a new range based on
	-- the radius of precision, as interger 0..360 may leave a lot of holes
	local radiusOfPrecision = max( halfSize.x, halfSize.y );
	local angSpan = pi*2 / asin( 1/radiusOfPrecision );
	
	local maxRad = 0;
	local allRads = {};
	local numPixels = 0;
	local centerOfMass = Vector:new(0,0);
	local balanceY = 0;
	
	for pxX = 0, imgSize.x-1 do
		for pxY = 0, imgSize.y-1 do			
			local _, _, _, a = imgData:getPixel( pxX/scale, pxY/scale );			
			
			if a > EFFECTIVE_ALPHA_THRESHOLD then				
				-- Count the number of non-transparent pixels
				numPixels = numPixels + 1;
				
				-- Accumulate coordinates
				centerOfMass.x = centerOfMass.x + pxX;
				centerOfMass.y = centerOfMass.y + pxY;
			
				-- Turn into polar coordinates, so that we can collect radiuses
				local polCoord = PolarVector:new();
				polCoord:FromCartesian( pxX - halfSize.x, pxY - halfSize.y );
			
				-- Compare the max radius
				if polCoord.r > maxRad then
					maxRad = polCoord.r;
				end
				
				-- Collect all radiuses
				local angIdx = floor( polCoord.a/(pi*2) * angSpan );
				if (not allRads[angIdx]) or (polCoord.r > allRads[angIdx]) then
					allRads[angIdx] = polCoord.r;
				end
			end
		end
	end

	-- Sum up jaggedness from all angles
	-- Logarithms ensure that jagedness is only effetive at the contour
	local jag = 0;
	for ang =0, angSpan do
		local rad = allRads[ang] or 0;
		
		-- tolerate a difference of up to 2 pixels
		local difference = maxRad - rad;
		difference = difference-2;
		if difference<0 then difference = 0 end;
		
		jag = jag + log( difference + 1);
	end
	
	-- Normalize
	jag = jag / (angSpan * log(128))
	jag = clamp( jag, 0, 1 );	
	
	-- Calculate center of mass
	centerOfMass = centerOfMass/numPixels;
	
	-- Calculate balance as 1 - the normalized offset of the center of the mass
	local balance = 1 - (centerOfMass - halfSize):Length()/maxRad;
	balance = clamp( balance, 0, 1 );
	
	-- Normalize ( base unit will be grams, each 1px = 1mg )
	local weight = numPixels/1000; 	
	
	self:SetRadius( maxRad );
	self:SetJaggedness( jag );
	self:SetWeight( weight );
	self:SetBalance( balance );
end


--===========================================================================--
--  Initialization
--===========================================================================--
return PhDyzkBody