--===========================================================================--
--  Dependencies
--===========================================================================--
local Control 		= require 'src.input.Control'


-------------------------------------------------------------------------------
--  Control:new : Creates a new control
-------------------------------------------------------------------------------
local function defaultCallback( box, control )
	print("<" .. control.id .. "> = " .. tostring(control.value));
end



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class ControlBox: A collection of controls 
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--    Put simply control boxes are black boxes which react on external triggers
--  and trough internal filters and tests produce an output signal which can be
--  fed back into the external system. The intended use for ControlBox is to
--  create a unified input method where the input from keyboards, joysticks, 
--  mice and other devices can be converted into logical control signals that
--  is specific to a game but independent from hardware implementations.
--    The first step before using a ControlBox is configuring it. This is done
--  by creating controls and mapping them to external triggering events. 
--     The following snippet creates a control called "ctrlAction" and binds it
--  to two events - 'Joy1Button' and 'Key':
--
--         local ctrlAction		= box:CreateControl("A");
--               ctrlAction:Bind'Joy1Button'( 3, Trigger.SWITCH(true) );
--	             ctrlAction:Bind'Key'( 'Z', Trigger.SWITCH(true) );
--
--  The event names are symbolic, they are chosen by the developers. The 1st
--  argument is an input value and the second is a trigger (also called 
--  test function). The test function will be called whenever the event is fed
--  into the box and it will return true if the event is the control is 
--  triggered by this event.
--    Events are fed manually to the control box. Their names have to match the
--  bindings of the controls. The following code illustrates the triggering of
--  a keypress event for the key 'A':
--
--  		box:Trigger( 'Key', "A", true );
--
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local ControlBox = {}
ControlBox.__index = ControlBox;


-------------------------------------------------------------------------------
--  Control:new : Creates a new control box
-------------------------------------------------------------------------------
function ControlBox:new()
	local obj = {};
	
	obj._controls = {}
	obj._callback = defaultCallback;
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Control:SetCallback : Sets the box callback 
-------------------------------------------------------------------------------
function ControlBox:SetCallback( callback )
	self._callback = callback
end


-------------------------------------------------------------------------------
--  Control:GetCallback : Returns the box callbox
-------------------------------------------------------------------------------
function ControlBox:GetCallback()
	return self._callback
end


-------------------------------------------------------------------------------
--  ControlBox:ControlExists : Returns true if the box has a controlID
-------------------------------------------------------------------------------
function ControlBox:ControlExists( controlID )
	return (self._controls[controlID] and true) or false;
end


-------------------------------------------------------------------------------
--  Control:CreateControl : Creates a control with an id controlID
-------------------------------------------------------------------------------
function ControlBox:CreateControl( controlID )
	if self:ControlExists( controlID ) then
		error( "Control " .. controlID .. " already exists.");
	else
		local control = Control:new( controlID, self );
		
		self._controls[controlID] = control;
		
		return control;
	end;	
end


-------------------------------------------------------------------------------
--  Control:CreateControl : Returns the control with `controlID' or nil
-------------------------------------------------------------------------------
function ControlBox:GetControl( controlID )
	return self._controls[controlID];
end


-------------------------------------------------------------------------------
--  Control:Trigger : Triggers all controls which respond to the input
-------------------------------------------------------------------------------
function ControlBox:Trigger( event, input, value )
	for id, control in pairs(self._controls) do
		if control:Test( event, input, value ) then
			self:_callback( control );
		end
	end;
end



--===========================================================================--
--  Initialization
--===========================================================================--
return ControlBox;