--===========================================================================--
--  Dependencies
--===========================================================================--
local floor				= math.floor


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class MathUtils : general math functions
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local MathUtils = {}


-------------------------------------------------------------------------------
--  MathUtils.Clamp : clamps a value in range
-------------------------------------------------------------------------------
function MathUtils.Clamp( x, bot, top )
	if x < bot then
		x = bot
	elseif x > top then
		x = top
	end
	
	return x;
end


-------------------------------------------------------------------------------
--  MathUtils.Round : Rounds a number
-------------------------------------------------------------------------------
function MathUtils.Round(num, idp)
  local mult = 10^(idp or 0)
  return floor(num * mult + 0.5) / mult
end


-------------------------------------------------------------------------------
--  MathUtils.Lerp : Linearly interpolate between two values
-------------------------------------------------------------------------------
function MathUtils.Lerp( a, b, t )
	return a + (b-a)*t;
end


-------------------------------------------------------------------------------
--  MathUtils.Bilerp : Linearly interpolate between two values
-------------------------------------------------------------------------------
function MathUtils.Bilerp( a1, a2, b1, b2, t1, t2 )
	local a = MathUtils.Lerp(a1, a2, t1);
	local b = MathUtils.Lerp(b1, b2, t1);
	return MathUtils.Lerp(a, b, t2);
end


--===========================================================================--
--  Initialization
--===========================================================================--
return MathUtils