--===========================================================================--
--  Dependencies
--===========================================================================--



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class BattleController : A battle scene controller game object
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local BattleController = {}
BattleController.__index = BattleController;


-------------------------------------------------------------------------------
--  BattleController:Control : Handles controls
-------------------------------------------------------------------------------
function BattleController:Control( control )
	if control.player == self._player then
		if control.id == "xAxis" then
			local val = control.value;
			local vx, vy = self._dyzk:GetControlVector();
			
			self._dyzk:SetControlVector( val, vy );
		end
		
		if control.id == "yAxis" then
			local val = control.value;
			local vx, vy = self._dyzk:GetControlVector();
			
			self._dyzk:SetControlVector( vx, val );
		end
	end
end