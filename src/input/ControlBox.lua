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