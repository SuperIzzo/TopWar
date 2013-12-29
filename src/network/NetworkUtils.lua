--===========================================================================--
--  Dependencies
--===========================================================================--
local Message			= require 'src.network.Message'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Constants
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local DEFAULT_PORT = 18553;


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class NetworkUtils: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local NetworkUtils = {}


-------------------------------------------------------------------------------
--  NetworkUtils.GetDefaultPort : Returns a default port
-------------------------------------------------------------------------------
function NetworkUtils.GetDefaultPort()
	return DEFAULT_PORT
end


-------------------------------------------------------------------------------
--  NetworkUtils.GetDefaultAddress : Returns a default address
-------------------------------------------------------------------------------
function NetworkUtils.GetDefaultAddress()
	return NetworkUtils.GetLocalHost();
end


-------------------------------------------------------------------------------
--  NetworkUtils.GetLocalHost : Returns a localhost address
-------------------------------------------------------------------------------
function NetworkUtils.GetLocalHost()
	return 'localhost';
end


-------------------------------------------------------------------------------
--  NetworkUtils.NewAuthMsg : Creates a new handshake message
-------------------------------------------------------------------------------
function NetworkUtils.NewHandshakeMsg()
	local msg = Message:new();
	
	msg:SetType( Message.Type.HANDSHAKE );
	
	return msg;
end


-------------------------------------------------------------------------------
--  NetworkUtils.NewAuthMsg : Creates authentication message
-------------------------------------------------------------------------------
function NetworkUtils.NewAuthMsg( name, pass )
	local msg = Message:new();

	msg:SetType( Message.Type.AUTH );
	msg:SetSubtype( Message.Type.ACTION );
	msg.name = name;
	msg.pass = pass;

	return msg;
end


-------------------------------------------------------------------------------
--  NetworkUtils.NewAuthMsg : Creates authentication information message
-------------------------------------------------------------------------------
function NetworkUtils.NewAuthInfoMsg( name, status )
	local msg = Message:new();

	msg:SetType( Message.Type.AUTH );
	msg:SetSubtype( Message.Type.INFO );
	msg.name 	= name;
	msg.status 	= status;

	return msg;
end


-------------------------------------------------------------------------------
--  NetworkUtils.NewDyzkDescMsg : Sends a dyzk description
-------------------------------------------------------------------------------
function NetworkUtils.NewDyzkDescMsg( dyzk, player )
	local msg = Message:new();

	msg:SetType( Message.Type.DYZK_DESC )
	msg.player = player;		
	
	msg.dyzkDesc = {}		
	msg.dyzkDesc.radius 	= dyzk:GetRadius();
	msg.dyzkDesc.jaggedness	= dyzk:GetJaggedness();
	msg.dyzkDesc.weight 	= dyzk:GetWeight();
	msg.dyzkDesc.balance 	= dyzk:GetBalance();

	return msg;
end


--===========================================================================--
--  Initialization
--===========================================================================--
return NetworkUtils