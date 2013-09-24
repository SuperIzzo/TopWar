--===========================================================================--
--  Dependencies
--===========================================================================--
local abs 		= math.abs



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Control: A single logical control representation
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local TriggerType = {}


-------------------------------------------------------------------------------
--  TriggerType.SWITCH : Creates a switch trigger function
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  Switches have two states on and off
-------------------------------------------------------------------------------
function TriggerType.SWITCH( trigger )
	
	local function TR_SWITCH( control, newValue )
		if type(newValue) == 'boolean' then
			if control.value == newValue then
				-- Do not trigger events
				return false;
			else
				-- Trigger the button
				control.value = newValue;
				return trigger;
			end
		end
	end
	
	return TR_SWITCH;
end


-------------------------------------------------------------------------------
--  TriggerType.SLIDER : Creates a slider trigger function
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  Sliders can obtain a value from a range usually between -1 and +1
--  The threshold is used to surpress noisy sensnosrs
--  deadzone kills small numbers (usefull with joysticks)
-------------------------------------------------------------------------------
function TriggerType.SLIDER( trigger, threshold, deadzone )
	local deadzone	= deadzone  or 0.1;
	local threshold	= threshold or 0.05;
	
	local sliderValue	  = 0;	-- Keep own local previous value
	local function TR_SLIDER( control, newValue )

		if type(newValue) == 'number' then
			if abs(newValue) < deadzone then
				newValue = 0;
			end
			
			if abs(newValue - sliderValue) > threshold then
				control.value = newValue;
				sliderValue = newValue;
				
				return trigger;
			end
		end
		
		return false;
	end
	
	return TR_SLIDER;
end


-------------------------------------------------------------------------------
--  TriggerType.SWITCH_TO_SPRING : Creates a slider trigger function
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  Sliders can obtain a value from a range usually between -1 and +1
--  The threshold is used to surpress noisy sensnosrs
-------------------------------------------------------------------------------
function TriggerType.SWITCH_TO_SPRING( trigger, numericOnVal, numericOffVal )

	local function TR_SWITCH_TO_SPRING( control, newValue )
		if type(newValue) == 'boolean' then
			if not newValue then
				control.value = numericOffVal;
				return false;
			else
				-- Trigger the button
				control.value = numericOnVal;
				return trigger;
			end
		end
	end
	
	return TR_SWITCH_TO_SPRING;
end


-------------------------------------------------------------------------------
--  TriggerType.ALWAYS : Always triggers
-------------------------------------------------------------------------------
function TriggerType.ALWAYS()

	local function TR_ALWAYS( control, newValue )
		return true;
	end
	
	return TR_ALWAYS;
end



--===========================================================================--
--  Initialization
--===========================================================================--
return TriggerType