--===========================================================================--
--  Dependencies
--===========================================================================--
local LbBattle			= require 'src.server.lobbies.LbBattle'
local LobbyManager		= require 'src.server.lobbies.LobbyManager'
local Message			= require 'src.network.Message'
local setmetatable 		= setmetatable



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class LbGameSetup: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local LbGameSetup = {}
LbGameSetup.__index = LbGameSetup;


-------------------------------------------------------------------------------
--  LbGameSetup:new : Creates a new LbGameSetup
-------------------------------------------------------------------------------
function LbGameSetup:new( numSlots )
	local obj = {}
	
	obj._numSlots		= numSlots or 2;
	obj._players		= {};
	obj._ready			= 0;
	obj._battleLobby	= nil;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  LbGameSetup:GetNumSlots : Returns the number of slots
-------------------------------------------------------------------------------
function LbGameSetup:GetNumSlots()
	return self._numSlots;
end


-------------------------------------------------------------------------------
--  LbGameSetup:GetRemainingSlots : Returns the number of slots
-------------------------------------------------------------------------------
function LbGameSetup:GetRemainingSlots()
	return self._numSlots - #self._players;
end


-------------------------------------------------------------------------------
--  LbGameSetup:AddPlayer : Enters a player into the game setup lobby
-------------------------------------------------------------------------------
function LbGameSetup:AddPlayer( player )
	local success = false;
	
	if self:GetRemainingSlots()>0 and player then
		table.insert( self._players, player );
		player:SetLobby( self );
		success = true;
	end
	
	return success;
end


-------------------------------------------------------------------------------
--  LbGameSetup:ReadyPlayer : 
-------------------------------------------------------------------------------
function LbGameSetup:ReadyPlayer( player, dyzk )
	player._dyzk = dyzk
	self._ready = self._ready + 1;
	
	if self:IsGameReady() then
		self:SetupBattleLobby();
	end
end


-------------------------------------------------------------------------------
--  LbGameSetup:IsGameReady : 
-------------------------------------------------------------------------------
function LbGameSetup:IsGameReady()	
	return self._ready >= self._numSlots;
end


-------------------------------------------------------------------------------
--  LbGameSetup:SetupBattleLobby : 
-------------------------------------------------------------------------------
function LbGameSetup:SetupBattleLobby( )
	local battleLobby = LbBattle:new();
		
	for i =1, #self._players do
		local pl = self._players[i]
		battleLobby:AddPlayer( pl );
	end
	
	battleLobby:Init();
	self._battleLobby = battleLobby;
end


-------------------------------------------------------------------------------
--  LbGameSetup:Update : 
-------------------------------------------------------------------------------
function LbGameSetup:Update( dt )
	if self._battleLobby then
		return self._battleLobby:Update( dt );
	end
end


-------------------------------------------------------------------------------
--  LbGameSetup:GetArena : Returns the LbGameSetup arena 
-------------------------------------------------------------------------------
function LbGameSetup:Message( msg )
	
	if battleLobby then
		return battleLobby:Message( msg );
	end
	
	if msg:GetType() == Message.Type.LOBBY_ENTER then
	
		local client = msg:GetClient()
		
		print( "Adding player: ", client )
		if  client  then
			local added = self:AddPlayer( client );
		
			if added then
				-- TODO: send confirmation message
			else
				-- TODO: send error message
			end
		end
	end
	
	if msg:GetType() == Message.Type.DYZK_DESC then
		local client = msg:GetClient()
		
		if client then
			self:ReadyPlayer( client, msg.dyzk );
		end
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return LbGameSetup