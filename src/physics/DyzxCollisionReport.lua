--===========================================================================--
--  Dependencies
--===========================================================================--


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class DyzxCollisionReport: A class used to report collision between dyzx
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local DyzxCollisionReport = {}
DyzxCollisionReport.__index = DyzxCollisionReport;


-------------------------------------------------------------------------------
--  DyzxCollisionReport:new : Creates a new dyzx collision report
-------------------------------------------------------------------------------
function DyzxCollisionReport:new( 
					dyzk1, dyzk2, primary, 
					colX, colY, colNx, colNy, 
					rpmDmg1, rpmDmg2, pushback1, pushback2 )
	local obj = {}

	obj._dyzk1 		= dyzk1;
	obj._dyzk2 		= dyzk2;
	obj._primary 	= primary;
	obj._colX 		= colX;
	obj._colY 		= colY;
	obj._colNx 		= colNx;
	obj._colNy 		= colNy;
	obj._rpmDmg1 	= rpmDmg1;
	obj._rpmDmg2 	= rpmDmg2;
	obj._pushback1 	= pushback1;
	obj._pushback2 	= pushback2;	

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  DyzxCollisionReport:GetDyzk1 : Returns the first dyzk in the collision
-------------------------------------------------------------------------------
function DyzxCollisionReport:GetDyzk1()
	return self._dyzk1;
end


-------------------------------------------------------------------------------
--  DyzxCollisionReport:GetDyzk2 : Returns the second dyzk in the collision
-------------------------------------------------------------------------------
function DyzxCollisionReport:GetDyzk2()
	return self._dyzk2;
end


-------------------------------------------------------------------------------
--  DyzxCollisionReport:IsPrimary : Returns true if this is the primary report
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  When two dyzx colide both of them will produce a collision report, 
--  depending on an internal order one of them will the marked as a primary and
--  other as a secondary. This information is can come in handy when a listener
--  is interested in more than one dyzk, but wants to reflect each collision
--  only once (ignoring secondary reports).
-------------------------------------------------------------------------------
function DyzxCollisionReport:IsPrimary()
	return self._primary;
end


-------------------------------------------------------------------------------
--  DyzxCollisionReport:GetCollisionPoint : Returns location of the collision
-------------------------------------------------------------------------------
function DyzxCollisionReport:GetCollisionPoint()
	return self._colX, self._colY;
end


-------------------------------------------------------------------------------
--  DyzxCollisionReport:GetCollisionNormal : Returns normal of the collision
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  The collision normal is a unit vector shows the direction of the collision,
--  which in the case of dyzx is the difference of their centers.
-------------------------------------------------------------------------------
function DyzxCollisionReport:GetCollisionNormal()
	return self._colNx, self._colNy;
end


-------------------------------------------------------------------------------
--  DyzxCollisionReport:GetRPMDamage1 : Returns RPM damage done to the 1st dyzk
-------------------------------------------------------------------------------
function DyzxCollisionReport:GetRPMDamage1()
	return self._rpmDmg1;
end


-------------------------------------------------------------------------------
--  DyzxCollisionReport:GetRPMDamage2 : Returns RPM damage done to the 2nd dyzk
-------------------------------------------------------------------------------
function DyzxCollisionReport:GetRPMDamage2()
	return self._rpmDmg2;
end


-------------------------------------------------------------------------------
--  DyzxCollisionReport:GetPushback1 : Returns pushback force for the 1st dyzk
-------------------------------------------------------------------------------
function DyzxCollisionReport:GetPushback1()
	return self._pushback1;
end


-------------------------------------------------------------------------------
--  DyzxCollisionReport:GetPushback2 : Returns pushback force for the 2nd dyzk
-------------------------------------------------------------------------------
function DyzxCollisionReport:GetPushback2()
	return self._pushback2;
end


--===========================================================================--
--  Initialization
--===========================================================================--
return DyzxCollisionReport