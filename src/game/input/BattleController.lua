--===========================================================================--
--  Dependencies
--===========================================================================--



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class BattleController : A battle scene controller game object
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local BattleController = {}
BattleController.__index = BattleController;


-------------------------------------------------------------------------------
--  BattleController:new : Creates a new controller
-------------------------------------------------------------------------------
function BattleController:new( player, phDyzk )
	local obj = {}
	
	obj._dyzk	= phDyzk;
	obj._player	= player;
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  BattleController:new : Creates a new controller
-------------------------------------------------------------------------------
function BattleController:Control( control )
	if control.player == self._player and control.type == "axis" then
		if control.name == "x" then
			local val = control.value;
			local vx, vy = self._dyzk:GetVelocity();
			
			self._dyzk:SetVelocity( vx+val*5, vy );
		end
		
		if control.name == "y" then
			local val = control.value;
			local vx, vy = self._dyzk:GetVelocity();
			
			self._dyzk:SetVelocity( vx, vy+val*5 );
		end
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return BattleController