--===========================================================================--
--  Dependencies
--===========================================================================--


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Set: An utility class to handle tables as set data structures
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  The Set class can create set objects or use any other tables as an input.
--  Table keys are treated as the elements and the values indicate whether the
--	element is in the set (true - yes, and nil - no )
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Set = {}
Set.__index = Set;
set.__mode	= "k"	-- weak keys because a nil value means it is not needed


-------------------------------------------------------------------------------
--  Set:new : Creates a new Set
-------------------------------------------------------------------------------
function Set:new()
	local obj = {}

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Set:Add : Adds an element to the set
-------------------------------------------------------------------------------
function Set:Add( elem )
	assert( type(elem)~="nil" );
	
	self[ elem ] = true;	
end


-------------------------------------------------------------------------------
--  Set:Remove : Removes an element from the set (and returns true if removed)
-------------------------------------------------------------------------------
function Set:Remove( elem )
	assert( type(elem)~="nil" );
	
	local removed = self[ elem ];
	self[ elem ] = nil;
	
	return removed;
end


-------------------------------------------------------------------------------
--  Set:Has : Returns true if the set has the given element
-------------------------------------------------------------------------------
function Set:Has( elem )
	return self[ elem ];
end


-------------------------------------------------------------------------------
--  Set:Items : Returns an iterator to the set items
-------------------------------------------------------------------------------
function Set:Items()
	local iter, t = pairs(self);
	local elem, has = nil, nil

	return function()
	
		-- skip elements which are not in the set ( i.e. has == nil )
		repeat			
			elem, has = iter(t,elem, has)			
		until  has  or  not elem;

		return elem;
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Set