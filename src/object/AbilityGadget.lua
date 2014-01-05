--===========================================================================--
--  Dependencies
--===========================================================================--
-- Modules

-- Aliases
local setmetatable 		= setmetatable


local AbilityCircle = {}



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class AbilityGadget: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local AbilityGadget = {}
AbilityGadget.__index = AbilityGadget;


-------------------------------------------------------------------------------
--  AbilityGadget:new : Creates a new AbilityGadget
-------------------------------------------------------------------------------
function AbilityGadget:new( dyzk, x, y )
	local obj = {}
	
	obj.dyzk	= dyzk;
	obj.x 		= x;
	obj.y 		= y;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  AbilityGadget:Draw : Draws the ability gadget
-------------------------------------------------------------------------------
function AbilityGadget:Draw()
	local globalCDLeft 		= self.dyzk:GetGlobalCooldown();
	local globalCDPeriod 	= self.dyzk:GetGlobalCooldownPeriod();
	local globalCD 			= 0;
	
	if globalCDPeriod>0 then
		globalCD = globalCDLeft/globalCDPeriod; 
	end
		
	
	for i =1, 4 do
		love.graphics.setColor( 255,255,255 );
		love.graphics.circle( "fill", self.x + i*20, self.y, 8 );
		
		local ability = self.dyzk:GetAbility(i);
		if ability then
			local abilityCDLeft		= ability:GetCooldown();
			local abilityCDPeriod	= ability:GetCooldownPeriod();
			local abilityCD			= 0;
			
			if abilityCDPeriod>0 then
				abilityCD = abilityCDLeft/abilityCDPeriod; 
			end
			
			local maxCD = globalCD;
			if abilityCDLeft > globalCDLeft then
				maxCD = abilityCD;
			end
			
			love.graphics.setColor( 0,0,0, 120 );			
			
			while maxCD > 0 do				
				love.graphics.arc( "fill", self.x + i*20, self.y, 8, math.pi*1.5, math.pi*1.5 - maxCD*math.pi*2 );
				maxCD = maxCD-1;
			end
		end
	end
	
	love.graphics.setColor( 255,255,255 );
end


-------------------------------------------------------------------------------
--  AbilityGadget:Update : Updates the ability gadget
-------------------------------------------------------------------------------
function AbilityGadget:Update( dt )
end


--===========================================================================--
--  Initialization
--===========================================================================--
return AbilityGadget