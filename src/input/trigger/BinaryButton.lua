--===========================================================================--
--  Dependencies
--===========================================================================--


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class BinaryButton: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local BinaryButton = {}
BinaryButton.__index = BinaryButton


-------------------------------------------------------------------------------
--  BinaryButton:new : Creates a new BinaryButton
-------------------------------------------------------------------------------
function BinaryButton:new()
	local obj = {}
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  triggerFunction : A private function we return every time we are asked to
-------------------------------------------------------------------------------
local function triggerFunction( control, newValue )
	assert( type(newValue)=="boolean" );
	
	if control:GetValue() ~= newValue then
		control:SetValue( newValue );
		return true;
	else
		return false;
	end
end


-------------------------------------------------------------------------------
--  BinaryButton.Trigger : Returns a binary button trigger
-------------------------------------------------------------------------------
function BinaryButton:Trigger()
	return triggerFunction;
end


--===========================================================================--
--  Initialization
--===========================================================================--
return BinaryButton