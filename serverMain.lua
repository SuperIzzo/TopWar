local Server 			= require 'src.network.Server'


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
	end

end