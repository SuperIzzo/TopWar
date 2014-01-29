--===========================================================================--
--  Dependencies
--===========================================================================--



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class DigitalAxis: a digital axis trigger
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  Digital axes are axes that are composed out of one or more binary input
--	controls. When one of the controls is 'on' state the axis takes a value 
--  that has been assigned to that control. If no control is on the axis takes
--	a default off value.
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local DigitalAxis = {}
DigitalAxis.__index = DigitalAxis;


-------------------------------------------------------------------------------
--  DigitalAxis:new : Creates a new DigitalAxis
-------------------------------------------------------------------------------
function DigitalAxis:new()
	local obj = {}
	
	obj._triggerValues	= {};
	obj._triggerStack	= {};
	obj._offValue		= 0;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  DigitalAxis:new : Creates a new DigitalAxis
-------------------------------------------------------------------------------
function DigitalAxis:SetOffValue( val )
	self._offValue = val;
end


-------------------------------------------------------------------------------
--  DigitalAxis:new : Creates a new DigitalAxis
-------------------------------------------------------------------------------
function DigitalAxis:TriggerOn( analogueVal )
	local id = #self._triggerValues+1;
	self._triggerValues[id] = analogueVal;
		
	return function ( control, on )
		if on then
			-- if the control is just being 'pressed'
			-- we put it on the top of the stack
			table.insert( self._triggerStack, 1, id);
		else
			-- ...however when it is being 'released',
			-- we remove it from anywhere on the stack
			for i=1, #self._triggerStack do
				if self._triggerStack[i] == id then
					table.remove( self._triggerStack, i );
					break;
				end
			end
		end
				
		-- Regardless of what we did earlier,
		-- take the value from the top of the stack 
		-- (or the off value if the stack is empty)
		local newValue	= self._offValue;
		local triggerID	= self._triggerStack[1];
		if triggerID then
			newValue = self._triggerValues[triggerID];
		end
		
		-- And finally - only trigger if the value has actually changed
		if newValue == control:GetValue() then
			return false;
		else
			control:SetValue( newValue );
			return true;
		end
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return DigitalAxis