--===========================================================================--
--  Dependencies
--===========================================================================--
-- Modules

-- Aliases
local setmetatable 		= setmetatable



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class AIBehaviourBase: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local AIBehaviourBase = {}
AIBehaviourBase.__index = AIBehaviourBase;


-------------------------------------------------------------------------------
--  AIBehaviourBase:new : Creates a new AIBehaviourBase
-------------------------------------------------------------------------------
function AIBehaviourBase:new()
	local obj = {}
	
	obj._controller	= nil;
	obj._weight		= 1;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  AIBehaviourBase:SetController : Sets the controller to the dyzk
-------------------------------------------------------------------------------
function AIBehaviourBase:SetController( controller )
	self._controller = controller;
end


-------------------------------------------------------------------------------
--  AIBehaviourBase:SetWeight : Sets the weight of the behaviour
-------------------------------------------------------------------------------
function AIBehaviourBase:SetWeight( weight )
	self._weight = weight;
end


-------------------------------------------------------------------------------
--  AIBehaviourBase:GetWeight : Returns the weight of the behaviour
-------------------------------------------------------------------------------
function AIBehaviourBase:GetWeight()
	return self._weight;
end


-------------------------------------------------------------------------------
--  AIBehaviourBase:GetArena : Returns the area
-------------------------------------------------------------------------------
function AIBehaviourBase:GetArena()
	if self._controller then
		return self._controller:GetArena();
	end
end


-------------------------------------------------------------------------------
--  AIBehaviourBase:GetDyzk : Returns the dyzk we are controlling
-------------------------------------------------------------------------------
function AIBehaviourBase:GetDyzk()
	if self._controller then
		return self._controller:GetDyzk();
	end
end


-------------------------------------------------------------------------------
--  AIBehaviourBase:GetDyzk : Returns the dyzk we are controlling
-------------------------------------------------------------------------------
function AIBehaviourBase:SuggestDirection( x,y )
	if self._controller then
		local len = (x^2+y^2)^0.5;
		
		if len == 0 then 
			len = 1; 
		end
		
		len = len/self._weight;
		self._controller:AddControlVector( x/len, y/len );
	end
end



--===========================================================================--
--  Initialization
--===========================================================================--
return AIBehaviourBase