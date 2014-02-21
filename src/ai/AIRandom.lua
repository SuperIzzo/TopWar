--===========================================================================--
--  Dependencies
--===========================================================================--
local AIBase				= require 'src.ai.AIBehaviourBase'
local Timer					= require 'src.util.Timer'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class AIRandom: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local AIRandom = {}
AIRandom.__index = setmetatable( AIRandom, AIBase );


-------------------------------------------------------------------------------
--  AIRandom:new : Creates a new AIRandom
-------------------------------------------------------------------------------
function AIRandom:new()
	local obj = {}
	
	self.switchCoolDownMin = 3;
	self.switchCoolDownMax = 6;
	
	obj.switchTimer = Timer:new();
	obj.x = 0;
	obj.y = 0;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  AIRandom:Update : Creates a new AIRandom
-------------------------------------------------------------------------------
function AIRandom:Update( dt )
	
	self.switchTimer:Update( dt );	
	if self.switchTimer:IsStopped() then
		self.x = math.random()*2 -1;
		self.y = math.random()*2 -1;
		
		local coolDownDist = self.switchCoolDownMax - self.switchCoolDownMin;
		local coolDown = self.switchCoolDownMin + math.random()*coolDownDist;
		self.switchTimer:Reset( coolDown );
	end
	
	self:SuggestDirection( self.x, self.y )
end


--===========================================================================--
--  Initialization
--===========================================================================--
return AIRandom