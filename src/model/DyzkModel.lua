--===========================================================================--
--  Dependencies
--===========================================================================--
local Vector		= require 'src.math.Vector'

local DyzxCollisionReport	= require 'src.model.DyzxCollisionReport'

local assert 		= _G.assert
local sqrt			= _G.math.sqrt





--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--  Constants
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class DyzkModel : The physical data and logic of a spinning DyzkModel object
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local DyzkModel = {}
DyzkModel.__index = DyzkModel;


-------------------------------------------------------------------------------
--  DyzkModel constants
-------------------------------------------------------------------------------
DyzkModel.RPS_TO_RPM_SCALE			= 9.5493
DyzkModel.MAX_NUM_ABILITIES		= 8



-------------------------------------------------------------------------------
--  DyzkModel:new : Creates a new DyzkModel instance
-------------------------------------------------------------------------------
function DyzkModel:new()
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
	
	-- Abilities
	obj._abilities = {};
	obj._globalCooldownTimer = 0;
	
	-- Extra information
	obj.metaData = {}
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  DyzkModel:Update : Updates the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:Update( dt )
	
	-- Update abilities		
	self:UpdateAbilities( dt );
	
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
	
	--print( self.x )
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
--  DyzkModel:AddCollisionListener : Updates the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:AddCollisionListener( func, arg )
	self._collisionListener[ #self._collisionListener+1 ] =
	{ func=func, arg=arg };
end


-------------------------------------------------------------------------------
--  DyzkModel:SetPosition : Sets the location of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:SetPosition( x, y )
	self.x = x;
	self.y = y;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetVelocity : Sets the velocity of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:SetVelocity( vx, vy )
	self.vx = vx;
	self.vy = vy;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetAcceleration : Sets the acceleration of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:SetAcceleration( ax, ay )
	self.ax = ax;
	self.ay = ay;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetPosition : Returns the location of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:GetPosition()
	return self.x, self.y;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetVelocity : Returns the velocity of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:GetVelocity()
	return self.vx, self.vy;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetControlVector : Sets the control vector (forced velocity)
-------------------------------------------------------------------------------
function DyzkModel:SetControlVector( x, y )
	self._controlVecX = x;
	self._controlVecY = y;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetControlVector : Returns the control vector
-------------------------------------------------------------------------------
function DyzkModel:GetControlVector()
	return self._controlVecX,	self._controlVecY;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetRPM : Returns the angular velocity in revolution per minutes
-------------------------------------------------------------------------------
function DyzkModel:GetRPM()
	return self:GetAngularVelocity()*self.RPS_TO_RPM_SCALE;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetAngularVelocity : Returns the angular velocity
-------------------------------------------------------------------------------
function DyzkModel:GetAngularVelocity()
	return self.angVel;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetWeight : Returns the weight of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:GetWeight()
	return self._weight;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetJaggedness : Returns the jaggedness of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:GetJaggedness()
	return self._jaggedness;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetMaxRadius : Returns the radius of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:GetMaxRadius()
	return self._maxRadius;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetMaxRadius : Returns the radius of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:GetBalance()
	return self._balance;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetWeight : Sets the weight of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:SetWeight( weigth )
	assert( weigth >= 0 )
	
	self._weight = weigth;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetJaggedness : Sets the jaggedness of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:SetJaggedness( jag )
	assert( jag >= 0 and jag <= 1 )
	
	self._jaggedness = jag;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetBalance : Sets the balance of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:SetMaxRadius( rad )
	assert( rad >= 0 )
	
	self._maxRadius = rad;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetBalance : Sets the balance of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:SetBalance( balance )
	assert( balance >= 0 and balance <= 1)
	
	self._balance = balance;
end


-------------------------------------------------------------------------------
--  DyzkModel:OnDyzkCollision : Handles dyzk-dyzk collision
-------------------------------------------------------------------------------
function DyzkModel:OnDyzkCollision( other, primary )

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
				rpmDmg1 * self.RPS_TO_RPM_SCALE, 
				rpmDmg2 * self.RPS_TO_RPM_SCALE,
				pushBack1, pushBack2 );
				
	local collisionReport2 = 
		DyzxCollisionReport:new(
				other, self, false,
				xCol, yCol, 
				-collisionNormal.x, -collisionNormal.y,
				rpmDmg2 * self.RPS_TO_RPM_SCALE,
				rpmDmg1 * self.RPS_TO_RPM_SCALE, 				
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
--  DyzkModel:CopyFromDyzkData : Sets the properties of this dyzk from another
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  dyzkData can be any object which conforms the dyzk data interface. This
--  makes the function quite versetile as it can copy from another DyzkModel,
--  Dyzk or DyzkImageAnalysis object.
-------------------------------------------------------------------------------
function DyzkModel:CopyFromDyzkData( dyzkData )
	self:SetMaxRadius( 		dyzkData:GetMaxRadius() 	);
	self:SetJaggedness( 	dyzkData:GetJaggedness() 	);
	self:SetWeight( 		dyzkData:GetWeight() 		);
	self:SetBalance( 		dyzkData:GetBalance()		);
end


-------------------------------------------------------------------------------
--  DyzkModel:SetAbility : Sets a dyzk ability
-------------------------------------------------------------------------------
function DyzkModel:SetAbility( id, ability )
	if ability and ability.OnDyzkCollision then
		self:AddCollisionListener( ability.OnDyzkCollision, ability );
	end
	
	self._abilities[id] = ability;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetAbility : Returns the ability with id
-------------------------------------------------------------------------------
function DyzkModel:GetAbility( id )
	return self._abilities[id];
end


-------------------------------------------------------------------------------
--  DyzkModel:ActivateAbility : Activates an ability (passing on/off signal)
-------------------------------------------------------------------------------
function DyzkModel:ActivateAbility( id, on )
	if self._abilities[id] then
		self._abilities[id]:Activate( on );
	end
end


-------------------------------------------------------------------------------
--  DyzkModel:UpdateAbilities : Sets a dyzk ability
-------------------------------------------------------------------------------
function DyzkModel:UpdateAbilities( dt )
	-- Update the global cooldown
	if self._globalCooldownTimer > 0 then
		self._globalCooldownTimer = self._globalCooldownTimer - dt;
	end
	if self._globalCooldownTimer < 0 then
		self._globalCooldownTimer = 0;
	end	
	
	-- Then update each individual ability
	for i = 1, self.MAX_NUM_ABILITIES do
		local ability = self._abilities[i];
		
		if ability then
			ability:Update( dt );
		end;
	end
end


-------------------------------------------------------------------------------
--  DyzkModel:GetGlobalCooldown : Returns the global cooldown time
-------------------------------------------------------------------------------
function DyzkModel:GetGlobalCooldown()
	return self._globalCooldownTimer;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetGlobalCooldown : Sets the global cooldown
-------------------------------------------------------------------------------
function DyzkModel:SetGlobalCooldown( cd )
	self._globalCooldownTimer = cd;
end


--===========================================================================--
--  Initialization
--===========================================================================--
return DyzkModel