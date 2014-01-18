--===========================================================================--
--  Dependencies
--===========================================================================--
local Array				= require 'src.util.Array'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class BattleController : A battle scene controller game object
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local BattleController = {}
BattleController.__index = BattleController;


-------------------------------------------------------------------------------
--  BattleController:new : Creates a new controller
-------------------------------------------------------------------------------
function BattleController:new( player, dyzkModel, arenaModel )
	local obj = {}
	
	obj._dyzk		= dyzkModel;
	obj._arena 		= arenaModel;
	obj._behaviours = Array:new()
	
	obj._dirX = 0; 
	obj._dirY = 0;
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  BattleController:Update : Updates the controller
-------------------------------------------------------------------------------
function BattleController:Update( dt )
	self._dirX, self._dirY = 0, 0;
	
	for i = 1, #self._behaviours do
		self._behaviours[i]:Update( dt );
	end
	
	self._dyzk:SetControlVector( self._dirX, self._dirY );
end


-------------------------------------------------------------------------------
--  BattleController:GetDyzk : Returns the dyzk we are controlling
-------------------------------------------------------------------------------
function BattleController:GetDyzk()
	return self._dyzk;
end


-------------------------------------------------------------------------------
--  BattleController:GetArena : Returns the arena of the dyzk
-------------------------------------------------------------------------------
function BattleController:GetArena()
	return self._arena;
end


-------------------------------------------------------------------------------
--  BattleController:Control : Handles controls
-------------------------------------------------------------------------------
function BattleController:Control( control )
	-- DO NOTHING
end


-------------------------------------------------------------------------------
--  BattleController:Control : Adds an ai behaviour to the controller
-------------------------------------------------------------------------------
function BattleController:AddBehaviour( behaviour )
	self._behaviours:Add( behaviour );
	behaviour:SetController( self );
end


-------------------------------------------------------------------------------
--  BattleController:AddControlVector : Adds a control direction
-------------------------------------------------------------------------------
function BattleController:AddControlVector( x, y )
	self._dirX = self._dirX + x;
	self._dirY = self._dirY + y;
end


--===========================================================================--
--  Initialization
--===========================================================================--
return BattleController