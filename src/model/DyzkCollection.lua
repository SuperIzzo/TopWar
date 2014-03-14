--===========================================================================--
--  Dependencies
--===========================================================================--
local Set 				= require 'src.util.collection.Set'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class DyzkCollection: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local DyzkCollection = {}
DyzkCollection.__index = DyzkCollection;


-------------------------------------------------------------------------------
--  DyzkCollection:new : Creates a new DyzkCollection
-------------------------------------------------------------------------------
function DyzkCollection:new()
	local obj = {}
	
	obj._dyzx = Set:new();

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  DyzkCollection:AddDyzk : Creates a new DyzkCollection
-------------------------------------------------------------------------------
function DyzkCollection:AddDyzk( dyzk )
	self._dyzx:Add( dyzk );
end


-------------------------------------------------------------------------------
--  DyzkCollection:AddDyzk : Creates a new DyzkCollection
-------------------------------------------------------------------------------
function DyzkCollection:Dyzx( dyzk )
	return self._dyzx:Add( dyzk );
end


--===========================================================================--
--  Initialization
--===========================================================================--
return DyzkCollection