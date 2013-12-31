--===========================================================================--
--  Dependencies
--===========================================================================--
local Message			= require 'src.network.Message'
local PhDyzk			= require 'src.model.DyzkModel'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class LbBattleSetup : Battle scene 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local LbBattleSetup = {}
LbBattleSetup.__index = LbBattleSetup


-------------------------------------------------------------------------------
--  LbBattleSetup:new : Creates a new scene
-------------------------------------------------------------------------------
function LbBattleSetup:new()
	local obj = {}
	
	obj._dyzx = {};
	obj._controllers = {}
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  LbBattleSetup:Init : Initializes the scene
-------------------------------------------------------------------------------
function LbBattleSetup:Init()
end


-------------------------------------------------------------------------------
--  LbBattleSetup:Network : Handle network messages
-------------------------------------------------------------------------------
function LbBattleSetup:Network( msg )
	if msg.type == Message.Type.DYZK_DESC then
		local client = msg:GetClient();
		local player = msg.player;		
		local dyzkDesc = msg.dyzkDesc;
		dyzkDesc.confirmed = false;
		
		local dyzk = PhDyzk:new();
		dyzk:SetRadius( 	dyzkDesc.radius 	);
		dyzk:SetJaggedness( dyzkDesc.jaggedness );
		dyzk:SetWeight( 	dyzkDesc.weight 	);
		dyzk:SetBalance( 	dyzkDesc.balance 	);
		dyzk.metaData.client 	= client;
		dyzk.metaData.player 	= player;
		
		client._dyzx = client._dyzx or {}
		client._dyzx[player] 	= dyzk;
		
		print( "Added dyzk" );
	end
end


-------------------------------------------------------------------------------
--  LbBattleSetup:Leave : Initializes the scene
-------------------------------------------------------------------------------
function LbBattleSetup:Leave()
end


--===========================================================================--
--  Initialization
--===========================================================================--
return LbBattleSetup