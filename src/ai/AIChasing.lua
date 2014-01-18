--===========================================================================--
--  Dependencies
--===========================================================================--
local AIBase				= require 'src.ai.AIBehaviourBase'
local Vector				= require 'src.math.Vector'



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class AIChasing: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local AIChasing = {}
AIChasing.__index = setmetatable( AIChasing, AIBase );


-------------------------------------------------------------------------------
--  AIChasing:new : Creates a new AIChasing
-------------------------------------------------------------------------------
function AIChasing:new()
	local obj = {}

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  AIChasing:Update : Creates a new AIChasing
-------------------------------------------------------------------------------
function AIChasing:Update( dt )
	local arena 	= self:GetArena();
	local myDyzk	= self:GetDyzk();
	
	local closestDyzk = nil;
	local closestDist = 1/0;	-- +INF
	
	-- Find the closest dyzk to us
	for dyzk in arena:Dyzx() do
		if dyzk ~= myDyzk then
			local dist = ((dyzk.x-myDyzk.x)^2 + (dyzk.y-myDyzk.y)^2)^0.5;
			
			if closestDist > dist and dist>0 then 
				closestDist = dist;
				closestDyzk = dyzk;
			end
		end
	end
	
	-- Go towards it
	if closestDyzk then
		self:SuggestDirection( 
			(closestDyzk.x - myDyzk.x)/closestDist, 
			(closestDyzk.y - myDyzk.y)/closestDist
		);
	end
end



--===========================================================================--
--  Initialization
--===========================================================================--
return AIChasing