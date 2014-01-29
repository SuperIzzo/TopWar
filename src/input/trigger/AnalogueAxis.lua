--===========================================================================--
--  Dependencies
--===========================================================================--


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class AnalogueAxis: a brief...
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local AnalogueAxis = {}
AnalogueAxis.__index = AnalogueAxis;


-------------------------------------------------------------------------------
--  AnalogueAxis:new : Creates a new AnalogueAxis
-------------------------------------------------------------------------------
function AnalogueAxis:new()
	local obj = {}
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  triggerFunction : A private function we return every time we are asked to
-------------------------------------------------------------------------------
local function triggerFunction( control, newValue )
	assert( type(newValue)=="number" );
	
	if control:GetValue() ~= newValue then
		control:SetValue( newValue );
		return true;
	else
		return false;
	end
end


-------------------------------------------------------------------------------
--  AnalogueAxis.Trigger : Returns a analogue axis trigger
-------------------------------------------------------------------------------
function AnalogueAxis:Trigger()
	return triggerFunction;
end


--===========================================================================--
--  Initialization
--===========================================================================--
return AnalogueAxis