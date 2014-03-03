--===========================================================================--
--  Dependencies
--===========================================================================--


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Array : An utility class to handle tables as array data structures
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
--  Array.Find : Finds the index of the first matched item in tab
-------------------------------------------------------------------------------
function Array:Find( startPos, endPos, item )
	-- Work out the parameters
	if type(item)=="nil" then
		if not endPos then
			item = startPos;
			startPos = 1;
			endPos = table.getn( self );
		else
			item = endPos;
			startPos = startPos or 1;
			endPos = table.getn( self );
		end		
	end
	
	-- See if we'll be going backwards
	local inc = 1;
	if startPos>endPos then
		inc = -1;
	end
	
	-- Do the searching
	for i = startPos, endPos, inc do
		local currentItem = self[i];
		if item == currentItem then
			return i;
		end 
	end
end


-------------------------------------------------------------------------------
--  Array:RemoveItem : Removes the first value found that matches 'item'
-------------------------------------------------------------------------------
function Array:RemoveItem( ... )	
	local findFirst = self.Find or Array.Find;	
	local idx = findFirst( self, ... )
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
		return self[i], i;
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Array