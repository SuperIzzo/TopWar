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
			local dist = (	(dyzk._position.x-myDyzk._position.x)^2 + 
							(dyzk._position.y-myDyzk._position.y)^2)^0.5;
			
			if closestDist > dist and dist>0 then 
				closestDist = dist;
				closestDyzk = dyzk;
			end
		end
	end
	
	-- Go towards it
	if closestDyzk then
		self:SuggestDirection( 
			(closestDyzk._position.x - myDyzk._position.x)/closestDist, 
			(closestDyzk._position.y - myDyzk._position.y)/closestDist
		);
	end
end



--===========================================================================--
--  Initialization
--===========================================================================--
return AIChasing