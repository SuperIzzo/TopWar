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
--  BattleController:Control : Handles controls
-------------------------------------------------------------------------------
function BattleController:Control( control )
	if control.player == self._player then
		if control.id == "xAxis" then
			local val = control.value;
			local vx, vy = self._dyzk:GetVelocity();
			
			self._dyzk:SetVelocity( vx+val*40/(self._dyzk:GetWeight()+2), vy );
		end
		
		if control.id == "yAxis" then
			local val = control.value;
			local vx, vy = self._dyzk:GetVelocity();
			
			self._dyzk:SetVelocity( vx, vy+val*40/(self._dyzk:GetWeight()+2) );
		end
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return BattleController