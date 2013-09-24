--===========================================================================--
--  Dependencies
--===========================================================================--
local TriggerType 		= require 'src.game.input.TriggerType'



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Control: A single logical control representation
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Control = {}
Control.__index = Control;


-------------------------------------------------------------------------------
--  Control:new : Creates a new control
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  A control has:
--	  id - a unique name for the control
--	  box - the box to which it belongs
--	  value - a value describing it's state
-------------------------------------------------------------------------------
function Control:new(id, box)
	local obj = {};
	
	obj.id = id;
	obj.box = box;
	obj.value = nil;
	obj._bindings = {};
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Control:GetID : Returns the control id
-------------------------------------------------------------------------------
function Control:GetID()
	return self.id;
end


-------------------------------------------------------------------------------
--  Control:GetBox : Returns the control box
-------------------------------------------------------------------------------
function Control:GetBox()
	return self.box;
end


-------------------------------------------------------------------------------
--  Control:GetValue : Returns the control value
-------------------------------------------------------------------------------
function Control:GetValue()
	return self.value;
end



-------------------------------------------------------------------------------
--  Control:SetValue : Sets the control value
-------------------------------------------------------------------------------
function Control:SetValue( value )
	self.value = value;
end


-------------------------------------------------------------------------------
--  Control:Bind : Binds an event, value and a trigger to the control
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  Binds the control to an event class and a specific input
--    usage: 	
-- 			control:Bind'Event'( <input> [, trigger] )
--    e.g:
--			control:Bind'KeyboardKey'( "W" );
--
--  'trigger' is an optional parameter which defines how the control
--  will react to events, defaults to a SWITCH
-------------------------------------------------------------------------------
function Control:Bind( event )
	return function( input, trigger )
		self._bindings[event] = self._bindings[event] or {};
		self._bindings[event][input] = 
			{
				trigger = trigger or TriggerType.SWITCH();
			};
	end
end


-------------------------------------------------------------------------------
--  Control:Test : Tests the trigger condition of the control
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
-- Tries the control, if it triggers the value of the control
-- may be changed.
-- Returns true if the control responded to the trigger and
-- false otherwise
-------------------------------------------------------------------------------
function Control:Test( event, input, value )
	local inputBinding = 	self._bindings 
							and self._bindings[event]
							and self._bindings[event][input]
							
	if inputBinding then
		return inputBinding.trigger( self, value );
	else
		return false;
	end
end



--===========================================================================--
--  Initialization
--===========================================================================--
return Control