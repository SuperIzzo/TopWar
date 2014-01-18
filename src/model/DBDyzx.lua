--===========================================================================--
--  Dependencies
--===========================================================================--


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class DBDyzx: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local DBDyzkEntry = {}
DBDyzx.__index = DBDyzx;


-------------------------------------------------------------------------------
--  DBDyzkEntry:new : Creates a new dyzk database
-------------------------------------------------------------------------------
function DBDyzkEntry:new()
	local obj = {}
	
	obj.dyzkID		= "";
	obj.maxRadius	= 0;
	obj.jaggedness	= 0;
	obj.weight		= 0;
	obj.balance		= 0;
	obj.speed		= 0;
	obj.maxAngVel	= 0;
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  DBDyzkEntry:Set : Sets the db entry
-------------------------------------------------------------------------------
function DBDyzkEntry:SetMaxRadius( maxRad )
	self.maxRadius = maxRad;
end	


-------------------------------------------------------------------------------
--  DBDyzx:Get : Returns the db entry
-------------------------------------------------------------------------------
function DBDyzkEntry:GetMaxRadius()
	return self.maxRadius
end


-------------------------------------------------------------------------------
--  DBDyzkEntry:Set : Sets the db entry
-------------------------------------------------------------------------------
function DBDyzkEntry:SetJaggedness( jag )
	self.jaggedness = jag; 
end


-------------------------------------------------------------------------------
--  DBDyzx:Get : Returns the db entry
-------------------------------------------------------------------------------
function DBDyzkEntry:GetJaggedness()
	return self.jaggedness;
end


-------------------------------------------------------------------------------
--  DBDyzkEntry:Set : Sets the db entry
-------------------------------------------------------------------------------
function DBDyzkEntry:SetWeight( weight )
	self.weight		= weight;
end


-------------------------------------------------------------------------------
--  DBDyzx:Get : Returns the db entry
-------------------------------------------------------------------------------
function DBDyzkEntry:GetWeight()
	return self.weight;
end


-------------------------------------------------------------------------------
--  DBDyzkEntry:Set : Sets the db entry
-------------------------------------------------------------------------------
function DBDyzkEntry:SetBalance( balance )
	self.balance = balance;
end


-------------------------------------------------------------------------------
--  DBDyzx:Get : Returns the db entry
-------------------------------------------------------------------------------
function DBDyzkEntry:GetBalance()
	return self.balance;
end


-------------------------------------------------------------------------------
--  DBDyzkEntry:Set : Sets the db entry
-------------------------------------------------------------------------------
function DBDyzkEntry:SetSpeed( speed )
	self.speed = speed;
end


-------------------------------------------------------------------------------
--  DBDyzx:Get : Returns the db entry
-------------------------------------------------------------------------------
function DBDyzkEntry:GetSpeed()
	return self.speed;
end


-------------------------------------------------------------------------------
--  DBDyzkEntry:Set : Sets the db entry
-------------------------------------------------------------------------------
function DBDyzkEntry:SetMaxAngularVelocity( angVel )
	self.maxAngVel = angVel;
end


-------------------------------------------------------------------------------
--  DBDyzx:Get : Returns the db entry
-------------------------------------------------------------------------------
function DBDyzkEntry:GetMaxAngularVelocity()
	return self.maxAngVel;
end



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class DBDyzx: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local DBDyzx = {}
DBDyzx.__index = DBDyzx;


-------------------------------------------------------------------------------
--  DBDyzx:new : Creates a new dyzk database
-------------------------------------------------------------------------------
function DBDyzx:new()
	local obj = {}
	
	obj.entries = {}; 

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  DBDyzx:AddEntryFromDyzk : Adds a dyzk to the database
-------------------------------------------------------------------------------
function DBDyzx:AddEntry( dyzk )
	local id = dyzk:GetDyzkID()

	self.entries[ id ] = dyzk;
end



--===========================================================================--
--  Initialization
--===========================================================================--
return DBDyzx