--===========================================================================--
--  Dependencies
--===========================================================================--


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class AnalogueButton: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local AnalogueButton = {}
AnalogueButton.__index = AnalogueButton;


-------------------------------------------------------------------------------
--  AnalogueButton:new : Creates a new AnalogueButton
-------------------------------------------------------------------------------
function AnalogueButton:new( minVal, maxVal )
	local obj = {}

	if minVal and maxVal then
		self.SetRange( obj, minVal, maxVal );
	end
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  AnalogueButton:SetRange : Sets the range of the input analogue signal
-------------------------------------------------------------------------------
function AnalogueButton:SetRange( minVal, maxVal )
	self._minVal, self._maxVal = minVal, maxVal;
end


-------------------------------------------------------------------------------
--  AnalogueButton:SetRange : Sets the range of the input analogue signal
-------------------------------------------------------------------------------
function AnalogueButton:Trigger()
	self._triggerFunction = self._triggerFunction or 
	
	function ( control, analogueValue )
		local newValue = false;
		
		if analogueValue < self._maxVal and analogueValue > self._minVal then
			newValue = true;
		end
		
		if newValue ~= control:GetValue() then
			control:SetValue( newValue );
			return true;
		else
			return false;
		end
	end
	
	return self._triggerFunction;
end


--===========================================================================--
--  Initialization
--===========================================================================--
return AnalogueButton