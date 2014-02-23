--===========================================================================--
--  Dependencies
--===========================================================================--


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Array: An utility class to handle tables as array data structures
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  In a manner the Array class works like the standard table library and uses
-- 	it quite a lot. The difference being it provides some extra functionality
--  and can be used to create Array objects. All functions can be used on
--  regular tables as well.
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Array = {}
Array.__index = Array


-------------------------------------------------------------------------------
--  Array.new : Creates a new array
-------------------------------------------------------------------------------
function Array:new( obj )
	local obj = obj or {}
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  Array:Add : Adds an item to the array 
-------------------------------------------------------------------------------
Array.Add = table.insert


-------------------------------------------------------------------------------
--  Array:RemoveAt : Removes an item at index (shifts the rest of the items)
-------------------------------------------------------------------------------
Array.RemoveAt = table.remove


-------------------------------------------------------------------------------
--  Array.FindFirst : Finds the index of the first matched item in tab
-------------------------------------------------------------------------------
function Array:FindFirst( item )
	
	return table.foreach( self, 
		function( idx, value ) 
			if value == item then 
				return idx;
			end
		end 
	);
end


-------------------------------------------------------------------------------
--  Array:RemoveFirst : Removes the first value found that matches 'item'
-------------------------------------------------------------------------------
function Array:RemoveFirst( item )
	
	local findFirst = self.FindFirst or Array.FindFirst;	
	local idx = findFirst( self, item )
	if idx then
		return table.remove( self, idx );
	end
end


-------------------------------------------------------------------------------
--  Array:Items : Returns an iterator to the array items
-------------------------------------------------------------------------------
function Array:Items()
	local i = 0;
	
	return function ()
		i=i+1;
		return self[i];
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Array