--===========================================================================--
--  Dependencies
--===========================================================================--
local Arena				= require 'src.object.Arena'
local Dyzk				= require 'src.object.Dyzk'
local Client	 		= require 'src.network.Client'
local NetUtils	 		= require 'src.network.NetworkUtils'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class ScBattleSetup : Battle scene 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local ScBattleSetup = {}
ScBattleSetup.__index = ScBattleSetup


-------------------------------------------------------------------------------
--  ScBattleSetup:new : Creates a new scene
-------------------------------------------------------------------------------
function ScBattleSetup:new()
	local obj = {}
	
	obj._dyzx = {};
	obj._controllers = {}
	
	obj._dyzkInfoStatus = false;
	
	obj._arena = Arena:new("data/arena/arena_mask2.png");
	obj._arena:SetScale(2,2,4);
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  ScBattleSetup:Init : Initializes the scene
-------------------------------------------------------------------------------
function ScBattleSetup:Init()
	local msg = {}
	
	self._dyzx[1] = Dyzk:new("data/dyzx/DyzkAA004.png");
	
	local client = Client:GetInstance();
	client:Authenticate( "Izzo", "123456" );	
end


-------------------------------------------------------------------------------
--  ScBattleSetup:Update : Updates the scene
-------------------------------------------------------------------------------
function ScBattleSetup:Update( dt )
	local client = Client:GetInstance();
	
	if client:IsAuthentic() then
	
		if not self._dyzkInfoStatus then
			client:Send( NetUtils.NewDyzkDescMsg( self._dyzx[1].phDyzk, 1 ) );
			
			self._dyzkInfoStatus = "sent"
		end
		
	end
end


-------------------------------------------------------------------------------
--  ScBattleSetup:Leave : Initializes the scene
-------------------------------------------------------------------------------
function ScBattleSetup:Leave()
end


--===========================================================================--
--  Initialization
--===========================================================================--
return ScBattleSetup