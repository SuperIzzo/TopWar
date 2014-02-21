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
	
end


-------------------------------------------------------------------------------
--  ScBattleSetup:Init : Initializes the scene
-------------------------------------------------------------------------------
function ScBattleSetup:Init()
end


-------------------------------------------------------------------------------
--  ScBattleSetup:Leave : Initializes the scene
-------------------------------------------------------------------------------
function ScBattleSetup:Leave()
end


-------------------------------------------------------------------------------
--  ScBattleSetup:Update : Updates the scene
-------------------------------------------------------------------------------
function ScBattleSetup:Update( dt )
end


-------------------------------------------------------------------------------
--  ScBattleSetup:Draw : Draws the battle setup scene
-------------------------------------------------------------------------------
function ScBattleSetup:Draw()
	
end


--===========================================================================--
--  Initialization
--===========================================================================--
return ScBattleSetup