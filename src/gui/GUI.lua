--===========================================================================--
--  Dependencies
--===========================================================================--
local NavGraph			= require 'src.gui.NavGraph'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class ScBattle : Battle scene 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local GUI = {}
GUI.__index = GUI


-------------------------------------------------------------------------------
--  GUI Constants
-------------------------------------------------------------------------------
GUI._registeredClasses = {}


-------------------------------------------------------------------------------
--  GUI:new : Creates a new GUI manager
-------------------------------------------------------------------------------
function GUI:new()
	local obj = {}	
	
	obj._objects	= {};
	obj._navGraph	= NavGraph:new();
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  GUI:RegisterClass : Registers a new GUI class
-------------------------------------------------------------------------------
function GUI:RegisterClass( name, class )
	GUI._registeredClasses[ name ] = class;
end


-------------------------------------------------------------------------------
--  GUI:Add : Adds the object
-------------------------------------------------------------------------------
function GUI:Add( object )
	self._objects[ #self._objects+1 ] = object;
end


-------------------------------------------------------------------------------
--  GUI:Create : Creates a new GUI object and adds it
-------------------------------------------------------------------------------
function GUI:Create( class, ... )
	if type(class) == "table" then
		local obj = class:new( ... );
		self:Add( obj );	
		return obj;
		
	elseif type(class) == "string" then
		local regClass = self._registeredClasses[ class ]		
		assert( regClass, 'GUI class "' .. class .. '" is not registered.' );
		return self:Create( regClass );
		
	end
end


-------------------------------------------------------------------------------
--  GUI:Link : Links two objects
-------------------------------------------------------------------------------
function GUI:Link( ... )
	self._navGraph:Link( ... );
end


-------------------------------------------------------------------------------
--  GUI:SetDefaultObject : Sets the default control
-------------------------------------------------------------------------------
function GUI:SetDefaultObject( ... )
	self._navGraph:SetDefaultObject( ... );
end


-------------------------------------------------------------------------------
--  GUI:Draw : Draws the gui
-------------------------------------------------------------------------------
function GUI:Draw()
	for i =1, #self._objects do
		self._objects[i]:Draw();
	end
end


-------------------------------------------------------------------------------
--  GUI:Control : React to input controls
-------------------------------------------------------------------------------
function GUI:Control( control )
	local pressEvent		= false;
	local down 				= false
	local selectedObject	= self._navGraph:GetSelected();
	local objectIsPressed	= selectedObject and selectedObject:IsPressed();
	
	if control:GetID() == "Click" or control:GetID() == "A" then
		down = control:GetValue();
		pressEvent = (selectedObject and true) or false;
	end	
	
	if not objectIsPressed then
		if 	control:GetID() == "xPoint" or 
			control:GetID() == "yPoint" or 
			control:GetID() == "Click"
		then
			local box = control:GetBox();		
			local xPoint = box:GetControl("xPoint"):GetValue();
			local yPoint = box:GetControl("yPoint"):GetValue();		
			
			local hitObject = nil;
			for _, object in pairs(self._objects) do
				local isHit = object:IsHit( xPoint, yPoint );
				
				if isHit then
					hitObject = object;
					break;
				end
			end
			
			self._navGraph:Select( hitObject );
		end
		
		if control:GetID() == "Up" and control:GetValue() then		
			self._navGraph:Move( "up" );
		end
		
		if control:GetID() == "Down" and control:GetValue() then
			self._navGraph:Move( "down" );
		end
		
		if control:GetID() == "Left" and control:GetValue() then		
			self._navGraph:Move( "left" );
		end
		
		if control:GetID() == "Right" and control:GetValue() then
			self._navGraph:Move( "right" );
		end
		
		selectedObject	= self._navGraph:GetSelected();
		if selectedObject and pressEvent and down then
			selectedObject:Press();
		end
	else
		-- The object has been pressed and we are waiting 
		-- for the release event
		if selectedObject and pressEvent and not down then
			selectedObject:Release();
		end
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return GUI;