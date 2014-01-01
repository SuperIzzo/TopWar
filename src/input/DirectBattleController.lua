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
			local vx, vy = self._dyzk:GetControlVector();
			
			self._dyzk:SetControlVector( val, vy );
		end
		
		if control.id == "yAxis" then
			local val = control.value;
			local vx, vy = self._dyzk:GetControlVector();
			
			self._dyzk:SetControlVector( vx, val );
		end
		
		if control.id == "A" then
			self._dyzk:ActivateAbility( 1, control.value );
		end
		
		if control.id == "B" then
			self._dyzk:ActivateAbility( 2, control.value );
		end
		
		if control.id == "X" then
			self._dyzk:ActivateAbility( 3, control.value );
		end
		
		if control.id == "Y" then
			self._dyzk:ActivateAbility( 4, control.value );
		end
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return BattleController