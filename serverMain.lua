require "src.strict"

local Server 			= require 'src.network.Server'
local LobbyManager		= require 'src.network.LobbyManager'

local LbBattleSetup		= require 'src.network.LbBattleSetup'



local server = Server:new();
server:Bind()

print "Beginning server loop."
local runing = true

local currentTime = socket.gettime();

local lobbyManager = LobbyManager:GetInstance()
local setupLobby = LbBattleSetup:new();

lobbyManager:AddLobby( setupLobby );


while runing do
	local prevTime = currentTime
	currentTime = socket.gettime();
	local timeDelta = currentTime - prevTime;
	
	for msg in server:Messages() do
		lobbyManager:Network( msg );
		
		for k,v in pairs(msg) do
			print(" >".. tostring(k) .. " = " .. tostring(v));
		end
	end
	
end