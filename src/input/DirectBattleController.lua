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
function BattleController:new( player, phDyzk, camera )
	local obj = {}
	
	obj._dyzk			= phDyzk;
	obj._player			= player;
	obj._controlDirX	= 0;	
	obj._controlDirY	= 0;	
	obj._pointX			= 0;
	obj._pointY			= 0;	
	obj._pointUpdate	= false;
	obj._camera			= camera;
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  BattleController:Update : Updates the controller
-------------------------------------------------------------------------------
function BattleController:Update( dt )
	if self._pointUpdate then
		local pointX, pointY = 
			self._camera:ScreenToWorld( self._pointX, self._pointY);
		
		local dyzkX, dyzkY = self._dyzk:GetPosition();
				
		self._controlDirX = pointX - dyzkX;
		self._controlDirY = pointY - dyzkY;
		
		print( "Dyzk: ", dyzkX, dyzkY, "Point: ", pointX, pointY );
	end
	
	self._dyzk:SetControlVector( self._controlDirX, self._controlDirY );
end


-------------------------------------------------------------------------------
--  BattleController:Control : Handles controls
-------------------------------------------------------------------------------
function BattleController:Control( control )
	local player = control:GetBox().player;
	
	if player == self._player then
		if control:GetID() == "xPoint" then
			self._pointX = control:GetValue();
		end
		
		if control:GetID() == "yPoint" then
			self._pointY = control:GetValue();
		end
				
		if control:GetID() == "Click" then
			self._pointUpdate = control:GetValue();
			
			self._controlDirX = 0;
			self._controlDirY = 0;
		end		
		
		if control:GetID() == "xAxis" then
			self._controlDirX = control:GetValue();			
		end
		
		if control:GetID() == "yAxis" then
			self._controlDirY = control:GetValue();
		end
		
		if control:GetID() == "A" then
			self._dyzk:ActivateAbility( 1, control:GetValue() );
		end
		
		if control:GetID() == "B" then
			self._dyzk:ActivateAbility( 2, control.value );
		end
		
		if control:GetID() == "X" then
			self._dyzk:ActivateAbility( 3, control.value );
		end
		
		if control:GetID() == "Y" then
			self._dyzk:ActivateAbility( 4, control.value );
		end
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return BattleController