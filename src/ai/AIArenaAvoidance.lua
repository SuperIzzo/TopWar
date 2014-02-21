--===========================================================================--
--  Dependencies
--===========================================================================--
local AIBase				= require 'src.ai.AIBehaviourBase'
local Timer					= require 'src.util.Timer'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class AIArenaAvoidance: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local AIArenaAvoidance = {}
AIArenaAvoidance.__index = setmetatable( AIArenaAvoidance, AIBase );


-------------------------------------------------------------------------------
--  AIArenaAvoidance:new : Creates a new AIArenaAvoidance
-------------------------------------------------------------------------------
function AIArenaAvoidance:new()
	local obj = {}

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  AIArenaAvoidance:Update : Creates a new AIArenaAvoidance
-------------------------------------------------------------------------------
function AIArenaAvoidance:Update( dt )
	local dyzkX, dyzkY		= self:GetDyzk():GetPosition();
	local arenaW, arenaH	= self:GetArena():GetSize();
	
	local relX, relY = dyzkX/arenaW, dyzkY/arenaH;
	self:SuggestDirection( ((0.5-relX)*2)^3, ((0.5-relY)*2)^3 )
end


--===========================================================================--
--  Initialization
--===========================================================================--
return AIArenaAvoidance