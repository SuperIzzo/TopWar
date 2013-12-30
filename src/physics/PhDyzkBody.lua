--===========================================================================--
--  Dependencies
--===========================================================================--
local Vector		= require 'src.math.Vector'

local DyzxCollisionReport	= require 'src.physics.DyzxCollisionReport'

local assert 		= _G.assert
local sqrt			= _G.math.sqrt





--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--  Constants
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--

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
	obj._maxRadius 	= 0;
	obj._balance	= 0;
	obj._speed		= 400;
	
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
	
	-- Control vector
	obj._controlVecX = 0;
	obj._controlVecY = 0;
	
	-- Extra information
	obj.metaData = {}
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  PhDyzkBody:Update : Updates the PhDyzkBody
-------------------------------------------------------------------------------
function PhDyzkBody:Update( dt )	
	-- Cap the control vector to a magnitude of 1
	local controlVec = Vector:new( self._controlVecX, self._controlVecY );
	local controlVecMagnitude = controlVec:Length()
	
	if controlVecMagnitude > 1 then
		controlVec.x = controlVec.x/controlVecMagnitude;
		controlVec.y = controlVec.y/controlVecMagnitude;
	end;
	
	-- Update velocity based on acceleration and velocity decay 
	local velWeight = 1 - self._friction*dt;	
	self.vx = self.vx*velWeight + self.ax*dt;
	self.vy = self.vy*velWeight + self.ay*dt;
	
	-- Update velocity based on eternal control vector
	self.vx = self.vx + controlVec.x*self._speed*dt;
	self.vy = self.vy + controlVec.y*self._speed*dt;
	
	-- Update position based on velocity
	self.x = self.x + self.vx*dt;
	self.y = self.y + self.vy*dt;
	
	-- Update angular velocity and angle
	self.angVel = self.angVel - dt*0.1;
	self.ang = self.ang + self.angVel*dt;
	
	-- Reset the control vector
	self._controlVecX = 0;
	self._controlVecY = 0;
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
--  PhDyzkBody:SetControlVector : Sets the control vector (forced velocity)
-------------------------------------------------------------------------------
function PhDyzkBody:SetControlVector( x, y )
	self._controlVecX = x;
	self._controlVecY = y;
end


-------------------------------------------------------------------------------
--  PhDyzkBody:GetControlVector : Returns the control vector
-------------------------------------------------------------------------------
function PhDyzkBody:GetControlVector()
	return self._controlVecX,	self._controlVecY;
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
--  PhDyzkBody:GetMaxRadius : Returns the radius of the PhDyzkBody
-------------------------------------------------------------------------------
function PhDyzkBody:GetMaxRadius()
	return self._maxRadius;
end


-------------------------------------------------------------------------------
--  PhDyzkBody:GetMaxRadius : Returns the radius of the PhDyzkBody
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
function PhDyzkBody:SetMaxRadius( rad )
	assert( rad >= 0 )
	
	self._maxRadius = rad;
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

	-- Ignore if the collision is being handled by the other
	if not primary then return end;
	
	local x1, y1 = self:GetPosition();
	local x2, y2 = other:GetPosition();
	local rad1, rad2 = self:GetMaxRadius(), other:GetMaxRadius();
	
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
				 
	-- The RPM damage depends on the collision force, the jagedness of the two dyzx and
	-- angular velocity of the other top... note that if the two dyzx have opposite spins	
	-- they will regenerate instead of damaging each other
	local rpmDmg1 = force1 
						* other.angVel * (self._jaggedness*0.2 + other._jaggedness*0.8)
	local rpmDmg2 = force2 
						* self.angVel * (self._jaggedness*0.8 + other._jaggedness*0.2)
	
	-- A couple of fake adjustments
	rpmDmg1 = rpmDmg1/20;
	rpmDmg2 = rpmDmg2/20;
	
	self.angVel = self.angVel - rpmDmg1;
	other.angVel = other.angVel - rpmDmg2;
	
	-- Apply the forces as two impulses in direction opposite to the 
	-- collision normal (to the dyzk centers)
	self:SetVelocity(	-collisionNormal.x*pushBack1,
						-collisionNormal.y*pushBack1 );
	other:SetVelocity(	collisionNormal.x*pushBack2,
						collisionNormal.y*pushBack2 );

	-- All that is left now is to report the collisions to the collision listeners,
	-- two reports are generated one for the listeners of each of the two dyzx
	local collisionReport1 = 
		DyzxCollisionReport:new(
				self, other, true,
				xCol, yCol, 
				collisionNormal.x, collisionNormal.y,
				rpmDmg1 * RPS_TO_RPM_SCALE, 
				rpmDmg2 * RPS_TO_RPM_SCALE,
				pushBack1, pushBack2 );
				
	local collisionReport2 = 
		DyzxCollisionReport:new(
				other, self, false,
				xCol, yCol, 
				-collisionNormal.x, -collisionNormal.y,
				rpmDmg2 * RPS_TO_RPM_SCALE,
				rpmDmg1 * RPS_TO_RPM_SCALE, 				
				pushBack2, pushBack1 );
	
	for i=1,#self._collisionListener do
		local listener = self._collisionListener[i];
		listener.func( listener.arg, collisionReport1 );
	end
	
	for i=1,#other._collisionListener do
		local listener = other._collisionListener[i];
		listener.func( listener.arg, collisionReport2 );
	end
end


-------------------------------------------------------------------------------
--  PhDyzkBody:CopyFromDyzkData : Sets the properties of this dyzk from another
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  dyzkData can be any object which conforms the dyzk data interface. This
--  makes the function quite versetile as it can copy from another PhDyzkBody,
--  Dyzk or DyzkImageAnalysis object.
-------------------------------------------------------------------------------
function PhDyzkBody:CopyFromDyzkData( dyzkData )
	self:SetMaxRadius( 		dyzkData:GetMaxRadius() 	);
	self:SetJaggedness( 	dyzkData:GetJaggedness() 	);
	self:SetWeight( 		dyzkData:GetWeight() 		);
	self:SetBalance( 		dyzkData:GetBalance()		);
end


--===========================================================================--
--  Initialization
--===========================================================================--
return PhDyzkBody