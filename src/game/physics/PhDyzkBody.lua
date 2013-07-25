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
--	Class PhDyzkBody : The physical data and logic of a spinning PhDyzkBody object
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local PhDyzkBody = {}
PhDyzkBody.__index = PhDyzkBody;


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--  Local donstants
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local EFFECTIVE_ALPHA_THRESHOLD = 125


-------------------------------------------------------------------------------
--  PhDyzkBody:new : Creates a new PhDyzkBody instance
-------------------------------------------------------------------------------
function PhDyzkBody:new()
	local obj = {}
	
	obj._weigth 	= 0;
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
--  PhDyzkBody:GetAngularVelocity : Returns the angular velocity
-------------------------------------------------------------------------------
function PhDyzkBody:GetAngularVelocity()
	return self.angVel;
end

-------------------------------------------------------------------------------
--  PhDyzkBody:GetWeight : Returns the weight of the PhDyzkBody
-------------------------------------------------------------------------------
function PhDyzkBody:GetWeight()
	return self._weigth;
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
	
	self._weigth = weigth;
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
function PhDyzkBody:OnDyzkCollision( other )
	local x1, y1 = self:GetPosition();
	local x2, y2 = other:GetPosition();
	local rad1, rad2 = self:GetRadius(), other:GetRadius();
	
	-- Distance is the distance between the centers
	local distance = rad1+rad2;
	
	-- Ratio is the radius to th
	local ratio = rad1/distance;
	
	-- The collision point
	local xCol, yCol = x1*ratio+x2*(1-ratio), y1*ratio+y2*(1-ratio);
	
	-- The collision normal
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
	
	-- 
	local dirNormDot1 = dir1:Dot( collisionNormal );
	local dirNormDot2 = -dir2:Dot( collisionNormal );
	
	-- Calculate an attack term based on parameters
	local attackForce = (self._jaggedness + other._jaggedness)*0.2 +1;
	attackForce = attackForce + 2 - self._balance - other._balance;
	
	-- calculate the respective force returns
	-- it is done such that directly facing the collision will result in least
	-- pushback, while side-ways and back causes max pushback
	
	local force1 = math.max(0,dirNormDot2)*( speed2*attackForce ); 
	local force2 = math.max(0,dirNormDot1)*( speed1*attackForce );
	print( attackForce );
	
	-- Apply the forces as two impulses in direction opposite to the
	-- collision normal (to the dyzk centers)
	self:SetVelocity(	-collisionNormal.x*force1,
						-collisionNormal.y*force1 );
	other:SetVelocity(	collisionNormal.x*force2,
						collisionNormal.y*force2 );

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
		jag = jag + log( maxRad - rad + 1);
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