--===========================================================================--
--  Dependencies
--===========================================================================--
local Vector				= require 'src.math.Vector'
local MathUtils				= require 'src.math.MathUtils'
local Announcer				= require 'src.util.Announcer'
local Timer					= require 'src.util.Timer'
local DyzxCollisionReport	= require 'src.model.DyzxCollisionReport'

local assert 				= _G.assert
local sqrt					= _G.math.sqrt
local sign					= MathUtils.Sign




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
	PUSHBACK_NEGATION_ARC = 0.6;
	
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
	PUSHBACK_BALANCE_RATIO = 0.7;
	
	-- Disbalanced dyzks shift from short to long radius, but they they also
	-- shift their center of mass which has far greater impact on the pushback
	-- than the periferal jaggedness of the dyzk, especially if the dyzk is
	-- heavy.
	PUSHBACK_BALANCE_EFFECT = 2;
	
	
	PUSHBACK_MULTIPLIER = 4;
}
local colConfig = CollisionConfigurationConstants -- Shorthand name


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class DyzkModel : The physical data and logic of a spinning DyzkModel object
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local DyzkModel = {}
DyzkModel.__index = DyzkModel;


-------------------------------------------------------------------------------
--  DyzkModel constants
-------------------------------------------------------------------------------
DyzkModel.RPS_TO_RPM_SCALE			= 9.5493
DyzkModel.MAX_NUM_ABILITIES			= 8



-------------------------------------------------------------------------------
--  DyzkModel:new : Creates a new DyzkModel instance
-------------------------------------------------------------------------------
function DyzkModel:new()
	local obj = {}
	
	obj._dyzkID	= "";
	obj._weight 	= 0;
	obj._jaggedness = 0;
	obj._maxRadius 	= 0;
	obj._balance	= 0;
	obj._speed		= 0;
	obj._maxAngVel	= 0;
	obj._spin		= 0;
	
	obj.x = 0;
	obj.y = 0;
	obj.vx = 0;
	obj.vy = 0;
	obj.ax = 0;
	obj.ay = 0;
	
	obj.ang = 0;
	obj.angVel = 0;
	
	obj._friction	= 0.01;	
	obj._collisionAnnouncer = Announcer:new()
	
	-- Control vector
	obj._controlVecX = 0;
	obj._controlVecY = 0;
	
	-- Abilities
	obj._abilities = {};
	obj._globalCooldownTimer = Timer:new();
	obj._globalCooldownPeriod = 0;
	
	-- Damage
	obj._damageTimer = Timer:new();
	obj._damageTimeGap = 0.2;	-- 0.1 seconds of invulnerability
	
	-- Extra information
	obj.metaData = {}
	
	return setmetatable(obj, self);
end



-------------------------------------------------------------------------------
--  DyzkModel:AddCollisionListener : Updates the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:AddCollisionListener( func, obj )
	self._collisionAnnouncer:AddListener( obj, func );
end


-------------------------------------------------------------------------------
--  DyzkModel:SetPosition : Sets the location of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:SetPosition( x, y )
	self.x = x;
	self.y = y;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetPosition : Returns the location of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:GetPosition()
	return self.x, self.y;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetVelocity : Sets the velocity of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:SetVelocity( vx, vy )
	self.vx = vx;
	self.vy = vy;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetVelocity : Returns the velocity of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:GetVelocity()
	return self.vx, self.vy;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetAcceleration : Sets the acceleration of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:SetAcceleration( ax, ay )
	self.ax = ax;
	self.ay = ay;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetAngularVelocity : Returns the angular velocity
-------------------------------------------------------------------------------
function DyzkModel:GetAngularVelocity()
	return self.angVel;
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
--  DyzkModel:SetDyzkID : Sets a unique dyzk ID for the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:SetDyzkID( dyzkID )
	assert( type(dyzkID) == "string" )
	
	self._dyzkID = dyzkID;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetDyzkID : Returns the dyzkID of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:GetDyzkID()
	return self._dyzkID;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetWeight : Sets the weight of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:SetWeight( weigth )
	assert( weigth >= 0 )
	
	self._weight = weigth;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetWeight : Returns the weight of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:GetWeight()
	return self._weight;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetJaggedness : Sets the jaggedness of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:SetJaggedness( jag )
	assert( jag >= 0 and jag <= 1 )
	
	self._jaggedness = jag;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetJaggedness : Returns the jaggedness of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:GetJaggedness()
	return self._jaggedness;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetBalance : Sets the balance of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:SetMaxRadius( rad )
	assert( rad >= 0 )
	
	self._maxRadius = rad;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetMaxRadius : Returns the radius of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:GetMaxRadius()
	return self._maxRadius;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetBalance : Sets the balance of the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:SetBalance( balance )
	assert( balance >= 0 and balance <= 1)
	
	self._balance = balance;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetBalance : Returns the balance if the dyzk
-------------------------------------------------------------------------------
function DyzkModel:GetBalance()
	return self._balance;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetSpeed : Sets the control speed of the dyzk
-------------------------------------------------------------------------------
function DyzkModel:SetSpeed( speed )
	assert( speed >= 0 )
	
	self._speed = speed;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetSpeed : Returns the control speed of the dyzk
-------------------------------------------------------------------------------
function DyzkModel:GetSpeed()
	return self._speed;
end


-------------------------------------------------------------------------------
--  DyzkModel:SetMaxAngularVelocity : Sets the max angular velocity of the dyzk
-------------------------------------------------------------------------------
function DyzkModel:SetMaxAngularVelocity( angVel )
	assert( angVel >= 0 )
	
	self._maxAngVel = angVel;
end


-------------------------------------------------------------------------------
--  DyzkModel:GetMaxAngularVelocity : Returns the maximal dyzk angular velocity
-------------------------------------------------------------------------------
function DyzkModel:GetMaxAngularVelocity()
	return self._maxAngVel;
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
	self._spin = self._spin + spin;	
	self.angVel = self.angVel + spin * self:GetMaxAngularVelocity()
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
	return 	sign(self._spin) == sign(self.angVel) and 
			sign(self._spin) ~= 0;
end


-------------------------------------------------------------------------------
--  DyzkModel:Update : Updates the DyzkModel
-------------------------------------------------------------------------------
function DyzkModel:Update( dt )
	-- Timers...
	self._globalCooldownTimer:Update( dt );
	self._damageTimer:Update( dt );
	
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
	local angDecay = dt*(1.1 - self:GetBalance()) / ((self:GetMaxRadius()/128)^2);
	self.angVel = self.angVel - sign(self._spin)*angDecay;
	self.ang = self.ang + self.angVel*dt;	
	
	-- Reset the control vector
	self._controlVecX = 0;
	self._controlVecY = 0;
end


-------------------------------------------------------------------------------
--  DyzkModel:OnDyzkCollision : Handles dyzk-dyzk collision
-------------------------------------------------------------------------------
function DyzkModel:OnDyzkCollision( other, primary )
	-- Ignore if the collision is being handled by the other
	if not primary then return end;
	
	--------------------------------
	-- Basic variables
	--------------
	local x1, y1 = self:GetPosition();
	local x2, y2 = other:GetPosition();
	local rad1, rad2 = self:GetMaxRadius(), other:GetMaxRadius();
	
	-- Distance is the distance between the centers
	local distance = math.sqrt((x1-x2)^2 + (y1-y2)^2);
	local radDistance = rad1+rad2;
	
	-- Ratio is the ratio between the two radiuses
	local ratio = rad2/radDistance;
	
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
	local dir1 = Vector:new(0,0);
	local dir2 = Vector:new(0,0);
	
	if speed1>0 then
		dir1 = vel1/speed1;
	end
	if speed2>0 then
		dir2 = vel2/speed2;
	end
	
	-- Motion direction to collision normal dot product
	-- tell us which direction the dyzk is hit from in respect
	-- to the direction it is moving in:
	-- frontal collision(1), sides(0), back(-1)
	local dirNormDot1 = dir1:Dot( collisionNormal );
	local dirNormDot2 = -dir2:Dot( collisionNormal );
	
	-- facingTerm is how much do the two dyzx face each other
	-- safe arc is a modifier which increases or decreases the
	-- pushback negation area (higher is safer)
	local facingTerm = 
		dirNormDot1*dirNormDot2  *  colConfig.PUSHBACK_NEGATION_ARC;
	
	-- Force is calculated such that, if a dyzk is striken from the
	-- side it takes the most damage, if the two dyzx face each other
	-- directly they will stop and take almost no damage
	local force1 = math.max(0, math.min(1, dirNormDot2-facingTerm) )
	local force2 = math.max(0, math.min(1, dirNormDot1-facingTerm) )
	
	
	--------------------------------
	-- Pushback
	--------------
	local weightRatio = self._weight/(self._weight + other._weight)	
	
	local jagednessFactor1 =
		1 +	(   other._jaggedness * colConfig.PUSHBACK_JAG_RATIO
			  + self._jaggedness * ( 1-colConfig.PUSHBACK_JAG_RATIO ) )
		* colConfig.PUSHBACK_JAG_EFFECT;
		
	local jagednessFactor2 =
		1 +	(   self._jaggedness * colConfig.PUSHBACK_JAG_RATIO
			  + other._jaggedness * ( 1-colConfig.PUSHBACK_JAG_RATIO ) )
		* colConfig.PUSHBACK_JAG_EFFECT;
		
	local balanceFactor1 = 
		1 - (	other._balance * colConfig.PUSHBACK_BALANCE_RATIO 
				+ self._balance * (1 - colConfig.PUSHBACK_BALANCE_RATIO) ) 
		* colConfig.PUSHBACK_BALANCE_EFFECT;
		
	local balanceFactor2 = 
		1 - (	self._balance * colConfig.PUSHBACK_BALANCE_RATIO 
				+ other._balance * (1 - colConfig.PUSHBACK_BALANCE_RATIO) ) 
		* colConfig.PUSHBACK_BALANCE_EFFECT;
	
	local pushBack1  =  colConfig.PUSHBACK_MULTIPLIER *
		( force1*speed2*jagednessFactor1 + balanceFactor1 ) * (1-weightRatio);
	local pushBack2  =  colConfig.PUSHBACK_MULTIPLIER *
		( force2*speed1*jagednessFactor2 + balanceFactor2 ) * weightRatio;
		
		  
	-- Apply the forces as two impulses in direction opposite to the 
	-- collision normal (to the dyzk centers)
	self:SetVelocity(	vel1.x*weightRatio -collisionNormal.x*pushBack1*(1-weightRatio),
						vel1.y*weightRatio -collisionNormal.y*pushBack1*(1-weightRatio));
				
	other:SetVelocity(	vel2.x*(1-weightRatio) + collisionNormal.x*pushBack2*weightRatio,
						vel2.x*(1-weightRatio) + collisionNormal.y*pushBack2*weightRatio );
	
	-- Deal with intersections and make sure dyzx don't overlap
	local intersectionAmount = (radDistance+6-distance);	
	if intersectionAmount > 0 then
		self:SetPosition( 	x1 - collisionNormal.x * intersectionAmount * (1-weightRatio),
							y1 - collisionNormal.y * intersectionAmount * (1-weightRatio) )
							
		other:SetPosition( 	x2 + collisionNormal.x * intersectionAmount * (weightRatio),
							y2 + collisionNormal.y * intersectionAmount * (weightRatio) )
	end
	
	--------------------------------
	-- RPM Damage
	--------------	
	-- The RPM damage depends on the collision force, the jagedness of the two dyzx and
	-- angular velocity of the other top... note that if the two dyzx have opposite spins	
	-- they will regenerate instead of damaging each other
	local rpmDmg1 = 0
	local rpmDmg2 = 0;
	if self._damageTimer:IsStopped() then
		-- RPM damage formula for dyzk 1
		local jagFactor = self._jaggedness*0.3 + other._jaggedness*0.7;
		local staticDamage = (self.angVel + other.angVel) * jagFactor * other:GetMaxRadius()/32 * other._weight/(self._weight^2);
		
		local kineticDamage = 0;
		if speed2>10 then  
			kineticDamage = jagFactor * (speed2/8)^2 * force1 * other._weight/(self._weight^2) * sign(self.angVel);
		end
		
		rpmDmg1 = staticDamage + kineticDamage;	
		
		-- reset the damage timer
		if rpmDmg1 > 0.01 or rpmDmg1 < -0.01 then
			self._damageTimer:Reset( self._damageTimeGap );
		end
	end
	if other._damageTimer:IsStopped() then	
		-- RPM damage formula for dyzk 2
		local jagFactor = self._jaggedness*0.7 + other._jaggedness*0.3;
		local staticDamage = (self.angVel + other.angVel) * jagFactor * self:GetMaxRadius()/32 * self._weight/(other._weight^2);
		
		local kineticDamage = 0;
		if speed1>10 then  
			kineticDamage = jagFactor * (speed1/8)^2 * force2 * self._weight/(other._weight^2) * sign(other.angVel);		
		end
		
		rpmDmg2 = staticDamage + kineticDamage;
		
		-- reset the damage timer
		if rpmDmg2 > 0.01 or rpmDmg2 < -0.01 then
			other._damageTimer:Reset( other._damageTimeGap );
		end
	end
	
	-- A couple of fake adjustments
	rpmDmg1 = rpmDmg1/40;
	rpmDmg2 = rpmDmg2/40;
	
	-- Apply the damage
	self.angVel = self.angVel 	- rpmDmg1;
	other.angVel = other.angVel - rpmDmg2;	

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
	
	self._collisionAnnouncer:Announce( collisionReport1 );
	other._collisionAnnouncer:Announce( collisionReport2 );
end


-------------------------------------------------------------------------------
--  DyzkModel:CopyFromDyzkData : Sets the properties of this dyzk from another
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  dyzkData can be any object which conforms the dyzk data interface. This
--  makes the function quite versetile as it can copy from another DyzkModel,
--  Dyzk or DyzkImageAnalysis object.
-------------------------------------------------------------------------------
function DyzkModel:CopyFromDyzkData( dyzkData )
	self:SetDyzkID( 				dyzkData:GetDyzkID() 				);
	self:SetMaxRadius( 				dyzkData:GetMaxRadius() 			);
	self:SetJaggedness( 			dyzkData:GetJaggedness() 			);
	self:SetWeight( 				dyzkData:GetWeight() 				);
	self:SetBalance( 				dyzkData:GetBalance()				);
	self:SetSpeed( 					dyzkData:GetSpeed()					);
	self:SetMaxAngularVelocity( 	dyzkData:GetMaxAngularVelocity()	);
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