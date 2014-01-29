--===========================================================================--
--  Dependencies
--===========================================================================--



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class NavNode: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local NavNode = {}
NavNode.__index = NavNode;


-------------------------------------------------------------------------------
--  NavNode:new : Creates a new NavNode
-------------------------------------------------------------------------------
function NavNode:new( object )
	local obj = {}
	
	obj._guiObject	= object;
	obj._links		= {};

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  NavNode:Link : Links the node to another node in a specific direction
-------------------------------------------------------------------------------
function NavNode:Link( dir, otherNode )
	self._links[ dir ] = otherNode;
end


-------------------------------------------------------------------------------
--  NavNode:GetLink : Returns a linked node in the specified direction
-------------------------------------------------------------------------------
function NavNode:GetLink( dir )
	return self._links[ dir ];
end


-------------------------------------------------------------------------------
--  NavNode:GetLink : Returns a linked node in the specified direction
-------------------------------------------------------------------------------
function NavNode:GetGUIObject()
	return self._guiObject;
end



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class NavGraph: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
-- Put controls in a net, then update the selected state of the controls in the 
-- network based on directional navigation input.
local NavGraph = {}
NavGraph.__index = NavGraph;


-------------------------------------------------------------------------------
--  NavGraph Constants
-------------------------------------------------------------------------------
-- Allowed directions
NavGraph.DIRECTIONS = 
{
	left	= true;
	right	= true;
	up		= true;
	down	= true;
}

-- Opposite directions
NavGraph.OPPOSITE_DIRECTIONS = 
{
	left	= "right";
	right	= "left";
	up		= "down";
	down	= "up";
}


-------------------------------------------------------------------------------
--  NavGraph:new : Creates a new NavGraph
-------------------------------------------------------------------------------
function NavGraph:new()
	local obj = {}
	
	obj._nodes = {}
	obj._defaultNode = nil
	obj._currentNode = nil;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  NavGraph:_GetNode : Returns the internal node associated with a GUI object
-------------------------------------------------------------------------------
function NavGraph:_GetNode( object, create )

	-- Create nodes as needed
	if not self._nodes[object] and create then	
		self._nodes[object] = NavNode:new( object );
	end
	
	return self._nodes[object];
end


-------------------------------------------------------------------------------
--  NavGraph:Link : Adds a gui object to the navigation graph
-------------------------------------------------------------------------------
function NavGraph:Link( dir, object1, object2, unidirectional )
	assert( object1 );
	assert( object2 );
	assert( self.DIRECTIONS[dir] )	-- See if the direction is valid
	
	-- Obtain the nodes for the two controls
	local node1 = self:_GetNode( object1, true );
	local node2 = self:_GetNode( object2, true );
	
	-- Add a forward link from node1 to node2
	node1:Link( dir, node2 );
	
	-- Now link backwards (node2 to node1)
	if not unidirectional then
		local oppositeDir = self.OPPOSITE_DIRECTIONS[dir];
		
		if oppositeDir then
			node2:Link( oppositeDir, node1 );
		end
	end
end


-------------------------------------------------------------------------------
--  NavGraph:SetDefaultObject : Adds a gui object to the navigation graph
-------------------------------------------------------------------------------
function NavGraph:SetDefaultObject( object, dir )
	-- TODO: make multiple defaults (for each direction)
	self._defaultNode = self:_GetNode( object, true );
end


-------------------------------------------------------------------------------
--  NavGraph:Move : Moves trough the graph selecting the appropriate object
-------------------------------------------------------------------------------
function NavGraph:Move( dir )
	assert( self.DIRECTIONS[dir] ) -- See if the direction is valid
	
	local activeNode = nil;
	
	local selectedObject = self:GetSelected();	
	if selectedObject then
		activeNode = self._nodes[ selectedObject ];
	end
	
	if not activeNode then
		-- We could not find a selected object,
		-- we fallback to our defaults
		
		if self._defaultNode then
			activeNode = self._defaultNode;
		else
			-- if no default, grab the first node
			for object, node in pairs( self._nodes ) do
				if node then
					activeNode = node;
					break
				end
			end
		end
	end
	
	
	if activeNode then
		local object = activeNode:GetGUIObject();
		local newActiveNode = nil;
		
		-- If the active object is selected we move from the active node
		-- to a different (in the given direction) however if the object is
		-- not selected that means that no object is selected, so we will
		-- select the active (default) node. Also if we cannot move in the
		-- direction, we stay on the active node.		
		if object:IsSelected() then
			newActiveNode = activeNode:GetLink( dir );			
		end

		if not newActiveNode then
			newActiveNode = activeNode;
		end
		
		self:Select( newActiveNode:GetGUIObject() );
	end
end


-------------------------------------------------------------------------------
--  NavGraph:Select : Moves trough the graph selecting the appropriate object
-------------------------------------------------------------------------------
function NavGraph:Select( object )

	-- Deselect all controls
	for object, node in pairs( self._nodes ) do
		object:Deselect();
	end

	-- Then select the specified
	if object then
		object:Select();
		self._currentNode = self:_GetNode( object );
	else
		self._currentNode = nil;
	end
end


-------------------------------------------------------------------------------
--  NavGraph:GetSelected : Returns the currently selected gui object
-------------------------------------------------------------------------------
function NavGraph:GetSelected()
	-- Start with the "current node" and see if it is selected
	if self._currentNode then
		local object = self._currentNode:GetGUIObject();
		
		if object:IsSelected() then
			return object;
		end
	end
	
	-- Our "current node" was out of date so now we have to go 
	-- trough all the nodes in the list and find a selected object
	for object, node in pairs( self._nodes ) do
		if object:IsSelected() then
			return object;
		end
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return NavGraph