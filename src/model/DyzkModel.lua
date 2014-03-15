--===========================================================================--
--  Dependencies
--===========================================================================--
local Vector				= require 'src.math.Vector'
local MathUtils				= require 'src.math.MathUtils'
local Announcer				= require 'src.util.Announcer'
local Timer					= require 'src.util.Timer'
local DyzkData				= require 'src.model.DyzkData'
local DyzxCollisionReport	= require 'src.model.DyzxCollisionReport'

local assert 				= assert
local sqrt					= math.sqrt
local sign					= MathUtils.Sign
local clamp					= MathUtils.Clamp




--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--  Constants
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local CollisionConfigurationConstants = 
{
	-- The pushback negation arc as the name suggests negates the pushback 
	-- that occurs between the two dyzx when they are "facing" each other.
	-- How much they face each other is they movement direction in respect
	-- to the collision point. The higher this number is the biger the facing
	-- arc on each dyzk becomes, in effect resulting in more frequent events
	-- where the dyzx stop at each other and battle in close range.
	-- Note: Use with care as it violates some conventional physics laws.
	PUSHBACK_NEGATION_ARC = 0.4;
	
	-- The pushback impulse is partially determined by the jaggedness of the
	-- two dyzx. The pushback ratio determines what parts are taken from the
	-- attacking dyzk and what parts from defending one. In essense high jag
	-- rating means not only that the dyzk will push harder but to some degree
	-- be pushed harder too.
	PUSHBACK_JAG_RATIO = 0.7;
	
	-- The jaggedness effect determines to what degree does the jagedness
	-- participate in the pushback formula, the higher this constant is the 
	-- more pushback force will be generated from the jagedness rating.
	PUSHBACK_JAG_EFFECT = 0.2;
	
	-- Dyzk disbalance functions in a similar fashion to the jaggedness. The
	-- resulting pushback is determined from based on both ballances of the
	-- colliding dyzx. Pushback balance ratio indicates in what proportion will
	-- the balances be taken. 1 means that the balance of the attacking dyzk 
	-- will be used only; 0.5 means half of the attacking plus half of the 
	-- defending; 0 - entirely the defending.
	PUSHBACK_BALANCE_RATIO = 0.65;
	
	-- Disbalanced dyzks shift from short to long radius, but they they also
	-- shift their center of mass which has far greater impact on the pushback
	-- than the periferal jaggedness of the dyzk, especially if the dyzk is
	-- heavy.
	PUSHBACK_BALANCE_EFFECT_MIN = 2;
	PUSHBACK_BALANCE_EFFECT_MAX = 16;
	
	-- The heavier a dyzk is the more it pushes lighter dyzx back, 
	-- the weight ratio amplifier increases the effect of weight on pushback
	PUSHBACK_WEIGHT_RATIO_AMP = 5;
	
	PUSHBACK_MULTIPLIER = 3;
}
local colConfig = CollisionConfigurationConstants -- Shorthand name


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class DyzkModel : The physical data and logic of a spinning DyzkModel object
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local DyzkModel = {}
DyzkModel.__index = setmetatable(DyzkModel, DyzkData);


-------------------------------------------------------------------------------
--  DyzkModel constants
-------------------------------------------------------------------------------
DyzkModel.RPS_TO_RPM_SCALE			= 9.5493
DyzkModel.MAX_NUM_ABILITIES			= 8
DyzkModel.GRAVITY_VECTOR			= Vector:new( 0, 0, -18000 );



-------------------------------------------------------------------------------
--  DyzkModel:new : Creates a new DyzkModel instance
-------------------------------------------------------------------------------
function DyzkModel:new()
	local obj = {}
	
	-- Physical quantities
	obj._position	= Vector:new();
	obj._velocity	= Vector:new();
	obj._accel		= Vector:new();
	obj._normal		= Vector:new(0,0,1);
	obj._friction	= 0.1;
	obj._angle	 	= 0;
	obj._rotation	= 0;
	
	-- Control values
	obj._control	= Vector:new();
	obj._spin		= 0; -- accumulated spin 	
	
	-- Arena related
	obj._arenaOut		= false;
	obj._arenaDepth		= 0;
	obj._arenaNormal	= Vector:new()
	
	-- Listeners
	obj._collisionAnnouncer = Announcer:new()
	
	-- Abilities
	obj._abilities = {};
	obj._globalCooldownTimer = Timer:new();
	obj._globalCooldownPeriod = 0;
	
	-- Damage
	obj._attackTimer = Timer:new();
	obj._attackTimeGap = 0.2;	-- 0.1 seconds of invulnerability
	
	-- Extra information
	obj.metaData = {}
	
	return setmetatable(obj, self);
end



-------------------------------------------------------------------------------
--  DyzkModel:AddCollisionListener : Adds a collision listener to the dyzk
-------------------------------------------------------------------------------
function DyzkModel:AddCollisionListener( func, obj )
	self._collisionAnnouncer:AddListener( obj, func );
end


-------------------------------------------------------------------------------
--  DyzkModel:SetPosition : Sets the location of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:SetPosition( x, y, z )
	self._position.x = x;
	self._position.y = y;
	self._position.z = z or self._position.z;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetPosition : Returns the location of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:GetPosition()
	return	self._position.x, 
			self._position.y,
			self._position.z;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetVelocity : Sets the velocity of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:SetVelocity( vx, vy, vz )
	self._velocity.x = vx;
	self._velocity.y = vy;
	self._velocity.z = vz or self._velocity.z;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetVelocity : Returns the velocity of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:GetVelocity()
	return	self._velocity.x,
			self._velocity.y,
			self._velocity.z;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetAcceleration : Sets the acceleration of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:SetAcceleration( ax, ay, az )
	self._accel.x = ax;
	self._accel.y = ay;
	self._accel.z = az or self._accel.z;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetRadialVelocity : Returns the angular velocity
-------------------------------------------------------------------------------
function DyzkModel:GetRadialVelocity()
	return self._rotation;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetAngle : Returns the angle
-------------------------------------------------------------------------------
function DyzkModel:GetAngle()
	return self._angle;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetControlVector : Sets the control vector
-------------------------------------------------------------------------------
function DyzkModel:SetControlVector( x, y )
	-- Cap the control vector to a magnitude of 1
	self._control	= Vector.Unit{ x, y };	
end


-------------------------------------------------------------------------------
--  DyzkModel:GetControlVector : Returns the control vector
-------------------------------------------------------------------------------
function DyzkModel:GetControlVector()
	return self._control.x,	self._control.y;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetRPM : Returns the angular velocity in revolution per minutes
-------------------------------------------------------------------------------
function DyzkModel:GetRPM()
	return self:GetRadialVelocity()*self.RPS_TO_RPM_SCALE;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetGlobalCooldown : Returns the global ability cooldown time left
-------------------------------------------------------------------------------
function DyzkModel:GetGlobalCooldown()
	return self._globalCooldownTimer:GetTimeLeft();
end


-------------------------------------------------------------------------------
--  DyzkModel:GetGlobalCooldownPeriod : Returns the global cooldown time period
-------------------------------------------------------------------------------
function DyzkModel:GetGlobalCooldownPeriod()
	return self._globalCooldownPeriod;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetGlobalCooldown : Sets the global cooldown
-------------------------------------------------------------------------------
function DyzkModel:SetGlobalCooldown( cd )
	assert( cd >= 0 );
	
	self._globalCooldownTimer:Reset( cd );
	self._globalCooldownPeriod	= cd;
end


-------------------------------------------------------------------------------
--  DyzkModel:Spin : Spins the top 
-------------------------------------------------------------------------------
function DyzkModel:Spin( spin )
	self._spin		= self._spin + spin;	
	self._rotation	= self._rotation + spin*self:GetMaxRadialVelocity();
end


-------------------------------------------------------------------------------
--  DyzkModel:GetSpin : Returns the accumulated spin of the dyzk
-------------------------------------------------------------------------------
function DyzkModel:GetSpin()
	return self._spin;
end


-------------------------------------------------------------------------------
--  DyzkModel:IsSpinning : Returns true if the dyzk is still spinning
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--    The disk will be spun in a certain direction. When the curren rotation 
--  direction changes from its initial (i.e. the dyzk starts going backwards)
--	we will consider it to be "dead" and not spinning anymore.
-------------------------------------------------------------------------------
function DyzkModel:IsSpinning()
	return 	sign(self._spin) == sign(self._rotation) and 
			sign(self._spin) ~= 0;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetSurface : Updates the DyzkModel (called by the arena)
-------------------------------------------------------------------------------
function DyzkModel:SetArenaNormal( normX, normY, normZ )
	self._arenaNormal.x = normX;
	self._arenaNormal.y = normY;
	self._arenaNormal.z = normZ;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetSurface : Updates the DyzkModel (called by the arena)
-------------------------------------------------------------------------------
function DyzkModel:SetArenaDepth( depth )
	self._arenaDepth = depth;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetElevation : Returns the elevation of the Dyzk above the ground
-------------------------------------------------------------------------------
function DyzkModel:GetElevation()
	-- 16 units above the ground is still treated as "grounded"
	local Z_TOLLERANCE = 16;
		
	local elevation = self._position.z - self._arenaDepth - Z_TOLLERANCE;
	
	-- Elevation cannot be negative (for now)
	if elevation > 0 then
		return elevation;
	else 
		return 0;
	end
end


-------------------------------------------------------------------------------
--  DyzkModel:GetPerspScale : Returns the perspective scale of the Dyzk
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
-- The higher the dyzk goes the larger it appears, Normally this would be a
-- visualization thing and only ever be used when displaying the dyzx, however
-- we are faking 3D in the mechanics of the game too and instead of doing the
-- expensive operations required to fix the terrain's perspective and then 
-- applying the correct transformations to the objects, we settle for a much
-- cheaper solution which fakes it - physically scaling the dyzx.
-------------------------------------------------------------------------------
function DyzkModel:GetPerspScale()
	return (0.9+self._position.z/255 * 1.1);
end


-------------------------------------------------------------------------------
--  DyzkModel:Update : Updates the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:Update( dt )
	-- Timers...
	self._globalCooldownTimer:Update( dt );
	self._attackTimer:Update( dt );
	
	-- Update abilities		
	self:UpdateAbilities( dt );	
	
	-- Update the dyzk physics
	self:UpdatePhysics( dt );	
end


-------------------------------------------------------------------------------
--  DyzkModel:UpdatePhysics : Updates the DyzkModel's physics
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
-- Dyzx use naive Euler integration
-------------------------------------------------------------------------------
function DyzkModel:UpdatePhysics( dt )
	local USE_3D_CONTROL	= true
	local g					= self.GRAVITY_VECTOR
	local accel 			= self._accel
	
	-- If we are on the ground...
	if self:GetElevation() == 0 then
				
		-- Reset the acceleration to g
		accel.x = g.x;
		accel.y = g.y;
		accel.z = g.z;
		
		if not USE_3D_CONTROL then
			-- Update velocity based on external control vector
			local speed = self:GetSpeed();
			accel.x = accel.x + self._control.x*speed;
			accel.y = accel.y + self._control.y*speed;
		else		
			-- The following bit comes from the expression: N x ( C x N )
			-- Where N is the arena normal and C is the control vector
			-- This gives us the projection of C onto the plane with normal N
			-- We take advantage of the double cross product involving N
			-- and the fact that the control vector does not have a z component
			-- to reduce the number of operations (it is called every frame)
			local c = self._control;
			local n = self._arenaNormal;
			local cnx = c.x*n.x;
			local cny = c.y*n.y;
			local control3D_x = c.x*(n.y^2 + n.z^2) - n.x*cny;
			local control3D_y = c.y*(n.x^2 + n.z^2) - n.y*cnx;
			local control3D_z = -n.z*(cnx + cny);
			
			-- Now we apply dot product ( C . C3D ), and scale by speed
			local speed = self:GetSpeed();
			local control3D_len = (control3D_x*c.x + control3D_y*c.y) * speed;
			
			-- Finally we apply the force
			accel.x = accel.x + control3D_x*control3D_len;
			accel.y = accel.y + control3D_y*control3D_len;
			accel.z = accel.z + control3D_z*control3D_len;
		end
				
		-- Normal force is the force with which the surface counteracts to
		-- forces trying to push solid objects through it. It cancels out a bit
		-- of the gravity and the other forces that act in the direction
		-- opposite to the surface normal. This would usually leave the forces
		-- unbalanced and make the dyzk slide down the slope.
		-- The 0.9 term is a HACK that makes sure we are not applying more
		-- force than necessary (resulting in force loss) and is necessity
		-- because the physics model is imperfect (and a little faulty). 
		local normalForce = self._arenaNormal
							* self._arenaNormal:Dot( accel )*0.9;
							
		accel:Sub( normalForce );		
		
		-- After all said and done, make sure we are firmly on the ground
		if self._position.z<self._arenaDepth then 
			self._position.z = self._arenaDepth;
			
			if self._velocity.z <0 then
				self._velocity.z = 0;
			end
		end
		
	-- Else if we are in the air...
	else
		local luft = (1 - self:GetJaggedness()) * self:GetRadialVelocity()/2;
		local airResistance = 1/self:GetRadius();
		accel.x = g.x;
		accel.y = g.y;
		accel.z = g.z * 1--airResistance + luft;
	end	
	
	-- Update velocity based on acceleration and velocity decay
	local velWeight = 1 - self._friction*dt;
	self._velocity.x = self._velocity.x*velWeight + accel.x*dt;
	self._velocity.y = self._velocity.y*velWeight + accel.y*dt;
	self._velocity.z = self._velocity.z*velWeight + accel.z*dt;
	
	-- Update position based on velocity
	self._position.x = self._position.x + self._velocity.x*dt;
	self._position.y = self._position.y + self._velocity.y*dt;
	self._position.z = self._position.z + self._velocity.z*dt;
	
	-- Update angular velocity and angle
	local angDecay	= dt*(1.1 - self:GetBalance()^4) / ((self:GetRadius()/128)^2);
	self._rotation	= self._rotation - sign(self._spin)*angDecay;
	self._angle		= self._angle + self._rotation*dt;
end


-------------------------------------------------------------------------------
--  DyzkModel:OnDyzkCollision : Handles dyzk-dyzk collision
-------------------------------------------------------------------------------
function DyzkModel:OnDyzkCollision( other, primary )
	-- TODO: Refactor this monster
	
	-- Ignore if the collision is being handled by the other
	if not primary then return end;
	
	--------------------------------
	-- Basic variables
	--------------
	local pos1					= Vector:new( self:GetPosition() );
	local pos2					= Vector:new( other:GetPosition() );
	local rad1, rad2			= self:GetRadius(),	other:GetRadius();
	local weight1, weight2 		= self:GetWeight(),		other:GetWeight();
	local jag1, jag2	 		= self:GetJaggedness(), other:GetJaggedness();
	local bal1, bal2	 		= self:GetBalance(), 	other:GetBalance();
	local vel1, vel2			= Vector:new( self:GetVelocity() ),
								  Vector:new( other:GetVelocity() );
	local angVel1, angVel2		= self:GetRadialVelocity(),
								  other:GetRadialVelocity();
	local ctrl1, ctrl2			= Vector:new( self:GetControlVector() ),
								  Vector:new( other:GetControlVector() );
	
	
	-- Distance is the distance between the centers
	-- And the collision normal is a normalized vector in the direction of
	-- the collision (i.e. the two centers)
	local collisionNormal, distance = (pos2-pos1):Unit();
	local radDistance = rad1+rad2;
	
	-- Ratio is the ratio between the two radiuses
	local ratio = rad2/radDistance;
	
	-- The collision point
	local collisionPoint = pos1*ratio + pos2*(1-ratio);
	
	-- Work out the speed and the direction	
	local dir1, speed1 = vel1:Unit();
	local dir2, speed2 = vel2:Unit();
	
	-- Motion direction to collision normal dot product
	-- tells us which direction the dyzk is hit from in respect
	-- to the direction it is moving in:
	-- front(1), sides(0), back(-1)
	local dirNormDot1 = dir1:Dot( collisionNormal );
	local dirNormDot2 = -dir2:Dot( collisionNormal );
	
	-- Control direction to collision normal dot product
	-- tells us which direction the players are pushing the dyzx 
	-- to in respect to the collision when it happens:
	-- towards(1), away(-1) or indifferent(0)
	local ctrlNormDot1 = ctrl1:Dot( collisionNormal );
	local ctrlNormDot2 = ctrl2:Dot( collisionNormal );
		
	--[[
	-- facingTerm is how much do the two dyzx face each other
	-- safe arc is a modifier which increases or decreases the
	-- pushback negation area (higher is safer)
	local facingTerm = dirNormDot1*dirNormDot2
	facingTerm = facingTerm * colConfig.PUSHBACK_NEGATION_ARC;
	--]]
	
	-- Force is calculated such that, if a dyzk is striken from the
	-- side it takes the most damage, if the two dyzx face each other
	-- directly they will stop and take almost no damage
	local force1 = math.max(0, math.min(2, dirNormDot1-dirNormDot2/2) )
	local force2 = math.max(0, math.min(2, dirNormDot2-dirNormDot1/2) )
	local forceSpeed1 = speed1;
	local forceSpeed2 = speed2;
	
	--------------------------------
	-- Pushback
	--------------
	local tangentDir1 = Vector:new(-collisionNormal.y, collisionNormal.x );	
	local tangentDir2 = Vector:new( collisionNormal.y,-collisionNormal.x );
	local tangentForce1 = tangentDir1*0.7 - collisionNormal*0.3;
	local tangentForce2 = tangentDir2*0.7 + collisionNormal*0.3;
	
	-- We calculate the alignment of the movement directions with the tangent
	-- to the collision normal, when it goes over a certain threshold we'll
	-- initiate a grip
	local tanDot1 = tangentForce1:Dot( dir2 );
	local tanDot2 = tangentForce2:Dot( dir1 );
	local tanGrips = math.max(0,tanDot1) * math.max(0,tanDot2);
	
	-- Amplify the signal
	--[[
	if tanGrips>0.5 then
		tanGrips = tanGrips + (tanGrips-0.5)*3;
	else
		tanGrips = tanGrips - (0.5-tanGrips)*3;
	end
	--]]
	
	-- The grip is a value between 0 and 1 represents the chance for the
	-- grip event to occur. When it does it nullifies the speed of the dyzx
	-- essentially negating the pushback and the remaining force and leaving
	-- active only the tangent (spinning) force.
	local grip = ( tanGrips )*(jag1*jag2*2 + 0.2);
	grip = clamp( grip, 0, 0.7 );
	grip = grip + (ctrlNormDot1 + ctrlNormDot2)*0.3;
	
	if grip > math.random() then
		forceSpeed1=0;
		forceSpeed2=0;
	end
	
	local weightRate1 = (weight1/weight2)^1.5;
	local weightRate2 = (weight2/weight1)^1.5;
	local weightRatio = weight1/(weight1 + weight2)
	
	-- Preserved force (linear inertia)
	local preservedStrength1 = forceSpeed1 * (1-force1);
	local preservedStrength2 = forceSpeed2 * (1-force2);
	local preservedForce1 = dir1 * preservedStrength1;
	local preservedForce2 = dir2 * preservedStrength2;

	-- Pushback force (generated by the linear force)
	local pushBackStrength1 = forceSpeed1 * force1 * weightRate1;
	local pushBackStrength2 = forceSpeed2 * force2 * weightRate2;	
	local pushBackForce1 = Vector:new( collisionNormal.x, collisionNormal.y );
	local pushBackForce2 = Vector:new(-collisionNormal.x,-collisionNormal.y );
	pushBackForce1 = pushBackForce1 * pushBackStrength1;
	pushBackForce2 = pushBackForce2 * pushBackStrength2;
		
		
	-- Tangent force (generated by the spinning)
	local tangentStrength1 = ( jag1+jag2 ) * 2;
	local tangentStrength2 = tangentStrength1 * (angVel1*0.2+angVel2*0.8);	
	local tangentStrength1 = tangentStrength1 * (angVel2*0.2+angVel1*0.8);
	
	tangentForce1 = tangentForce1 * tangentStrength1 * weight1/weight2;
	tangentForce2 = tangentForce2 * tangentStrength2 * weight2/weight1;
	--local tangentForce2 = looseDir2 * (preservedStrength2 + tangentStrength2);
	
	-- Resulting forces
	local resultForce1 = preservedForce1 + pushBackForce2 + tangentForce2;
	local resultForce2 = preservedForce2 + pushBackForce1 + tangentForce1;
	
	-- Apply the forces as two impulses in direction opposite to the 
	-- collision normal (to the dyzk centers)
	self:SetVelocity(	resultForce1.x,	resultForce1.y );				
	other:SetVelocity(	resultForce2.x,	resultForce2.y );
	
	-- Deal with intersections and make sure dyzx don't overlap
	local intersectionAmount = (radDistance*self:GetPerspScale()+6-distance);	
	if intersectionAmount > 0 then
		self:SetPosition( 	pos1.x - collisionNormal.x * intersectionAmount * (1-weightRatio),
							pos1.y - collisionNormal.y * intersectionAmount * (1-weightRatio) )
							
		other:SetPosition( 	pos2.x + collisionNormal.x * intersectionAmount * (weightRatio),
							pos2.y + collisionNormal.y * intersectionAmount * (weightRatio) )
	end
	
	--------------------------------
	-- RPM Damage
	--------------
	-- The RPM damage depends on the collision force, the jagedness of the two dyzx and
	-- angular velocity of the other top... note that if the two dyzx have opposite spins	
	-- they will regenerate instead of damaging each other
	local rpmDmg1 = 0
	local rpmDmg2 = 0;
	if other._attackTimer:IsStopped() then
		-- RPM damage formula for dyzk 1
		local jagFactor = jag1*0.3 + jag2*0.7;
		local staticDamage = 
			weight2^2 * (2 - bal2)
			* rad2 * (jag2*0.7 + jag1*0.3)
			/ (weight1 * rad1 * 25);
		
		local knockDamage = 
			speed2 * force2 * weight2^2
			/ (weight1^2 * 1000)
		
		-- Razor (aka slash) damage is generated when one dyzk moves quickly
		-- trough the other's side without pushing it (like a sword)
		local razorDamage	= 
			math.abs(tanDot2) * speed2^2			-- Motion factor
			* angVel2 * rad2 * (jag2*1.6 + 0.4)		-- Rotation factor
			/ (weight1^2 * rad1^2 * 1000) 			-- Defence
			* (jag1*0.7 + 0.3)						-- some more defence
		if speed2<10 then  
			knockDamage = 0;
		end
		
		rpmDmg1 = staticDamage + knockDamage + razorDamage;
		
		-- reset the damage timer
		if rpmDmg1 > 0.01 or rpmDmg1 < -0.01 then
			other._attackTimer:Reset( other._attackTimeGap );
		end
	end
	if self._attackTimer:IsStopped() then	
		-- RPM damage formula for dyzk 2
		local staticDamage = 
			weight1^2 * (2 - bal1)
			* rad1 * (jag1*0.7 + jag2*0.3)
			/ (weight2 * rad2 * 25);
		--(self.angVel + other.angVel) * jagFactor * self:GetRadius()/32 * weight1/(weight2^2);
		
		--jagFactor * (speed1/8)^2 * force2 * weight1/(weight2^2) * sign(other.angVel);
		local knockDamage = 
			speed1 * force1 * weight1^2
			/ (weight2^2 * 1000)
		
		-- Razor (aka slash) damage is generated when one dyzk moves quickly
		-- trough the other's side without pushing it (like a sword)
		local razorDamage	= 
			math.abs(tanDot1) * speed1^2			-- Motion factor
			* angVel1 * rad1 * (jag1*1.6 + 0.4)		-- Rotation factor
			/ (weight2^2 * rad2^2 * 1000)			-- Defence
			* (jag2*0.7 + 0.3)						-- some more defence
		
		if speed1<10 then  
			knockDamage = 0;
		end
		
		rpmDmg2 = staticDamage + knockDamage + razorDamage;
		
		-- reset the damage timer
		if rpmDmg2 > 0.01 or rpmDmg2 < -0.01 then
			 self._attackTimer:Reset( self._attackTimeGap );
		end
	end
	
	-- A couple of fake adjustments
	rpmDmg1 = rpmDmg1;
	rpmDmg2 = rpmDmg2;
	
	-- Apply the damage
	self._rotation	= self._rotation  - rpmDmg1;
	other._rotation = other._rotation - rpmDmg2;	

	-- All that is left now is to report the collisions to the collision listeners,
	-- two reports are generated one for the listeners of each of the two dyzx
	local collisionReport1 = 
		DyzxCollisionReport:new(
				self, other, true,
				collisionPoint.x, collisionPoint.y, 
				collisionNormal.x, collisionNormal.y,
				rpmDmg1 * self.RPS_TO_RPM_SCALE, 
				rpmDmg2 * self.RPS_TO_RPM_SCALE )				
				--pushBack1, pushBack2 );
				
	local collisionReport2 = 
		DyzxCollisionReport:new(
				other, self, false,
				collisionPoint.x, collisionPoint.y, 
				-collisionNormal.x, -collisionNormal.y,
				rpmDmg2 * self.RPS_TO_RPM_SCALE,
				rpmDmg1 * self.RPS_TO_RPM_SCALE )
				--	pushBack2, pushBack1 );
	
	self._collisionAnnouncer:Announce( collisionReport1 );
	other._collisionAnnouncer:Announce( collisionReport2 );
end


-------------------------------------------------------------------------------
--  DyzkModel:OnArenaCollision : Handles arena out events
-------------------------------------------------------------------------------
function DyzkModel:OnArenaCollision( colX, colY, colZ )
	local x,y 			= self:GetPosition();
	local rad			= self:GetRadius() * self:GetPerspScale();
	local colVec		= Vector:new( colX-x, colY-y );
	local velocity		= Vector:new( self:GetVelocity() );
	local dir			= velocity:Unit();
	local invRadVec		= dir * (-rad);
	
	local projCol		= dir * colVec:Dot( dir );	
	local contactVec = invRadVec + projCol;
	
	-- For the time being just stop and go back to the contact point
	-- TODO: Make the effect more dramatic
	self:SetPosition( x+contactVec.x, y+contactVec.y );	
	self:SetVelocity( 0, 0 );
end


-------------------------------------------------------------------------------
--  DyzkModel:OnArenaOut : Handles arena out events
-------------------------------------------------------------------------------
function DyzkModel:OnArenaOut()
	self._arenaOut = true;
end


-------------------------------------------------------------------------------
--  DyzkModel:IsOutOfArena : Returns true if the dyzk is has come out of arena
-------------------------------------------------------------------------------
function DyzkModel:IsOutOfArena()
	return self._arenaOut;
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
	-- Then update each individual ability
	for i = 1, self.MAX_NUM_ABILITIES do
		local ability = self._abilities[i];
		
		if ability then
			ability:Update( dt );
		end;
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return DyzkModel