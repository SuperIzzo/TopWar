local Server 			= require 'src.network.Server'

local LobbyManager		= require 'src.server.lobbies.LobbyManager'
local LbGameSetup		= require 'src.server.lobbies.LbGameSetup'


local lobbyManager = LobbyManager:GetInstance();

local gameSetup = LbGameSetup:new( 1, 1 );
lobbyManager:AddLobby( gameSetup );
lobbyManager:SetDefaultLobby( gameSetup );


local server = Server:new();
server:Bind()

print "Beginning server loop."
local runing = true

local currentTime = socket.gettime();

while runing do
	local prevTime = currentTime
	currentTime = socket.gettime();
	local timeDelta = currentTime - prevTime;
	
	
	for msg in server:Messages() do	
		--print("[from " .. msg:GetClient()._ip .. "]" );

		for k,v in pairs(msg) do
			print(" >".. tostring(k) .. " = " .. tostring(v));
		end
		
		--lobbyManager:Message( msg );
	
		local client = msg:GetClient()
		local lobby = client and client:GetLobby();
			  lobby = lobby or lobbyManager:GetDefaultLobby();
			  
		print( lobby );
		if lobby then
			if lobby.Message then
				lobby:Message( msg );
			end
		end
		
	end
	
	lobbyManager:Update( timeDelta );

end