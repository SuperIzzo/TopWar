--===========================================================================--
--  Dependencies
--===========================================================================--
-- Modules
local PhArena			= require 'src.game.physics.PhArena'
local PhDyzk			= require 'src.game.physics.PhDyzkBody'
local GDImageWrapper 	= require 'src.network.GDImageWrapper'
local ImageUtils		= require 'src.game.graphics.ImageUtils'

-- Aliases
local setmetatable 		= setmetatable



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class LbBattle: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local LbBattle = {}
LbBattle.__index = LbBattle;



local function PrepareArena( img )
	local phArena = PhArena:new();
	
	local depthImg = GDImageWrapper:new( img )
	local normalImg = GDImageWrapper:newImageData(
			depthImg:getWidth(), 
			depthImg:getHeight()
		)

	ImageUtils.DepthToNormalMap( depthImg, normalImg );

	phArena:SetDepthMask( depthImg );
	phArena:SetNormalMask( normalImg );
	
	return phArena;
end


-------------------------------------------------------------------------------
--  LbBattle:new : Creates a new server battle scene
-------------------------------------------------------------------------------
function LbBattle:new()
	local obj = {}
	
	obj._dyzx = {};
	obj._controllers = {};
	
	obj._arena = PrepareArena("data/arena/arena_mask2.png");
	obj._arena:SetScale( 2,2,4 );
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  LbBattle:Init : Initializes the scene
-------------------------------------------------------------------------------
function LbBattle:Init()
	for i=1, #self._dyzx do
		local dyzk = self._dyzx[i];
		
		self._arena:AddDyzk( dyzk );	
	end
end


-------------------------------------------------------------------------------
--  LbBattle:AddPlayer : Adds a player to the room
-------------------------------------------------------------------------------
function LbBattle:AddPlayer( player )
	local dyzk = PhDyzk:new();
	dyzk:SetRadius( 	player._dyzk.radius  )
	dyzk:SetWeight( 	player._dyzk.weight  )
	dyzk:SetJaggedness( player._dyzk.jag 	 )
	dyzk:SetBalance( 	player._dyzk.balance )
	
	dyzk.player = player;
	
	print( dyzk );
	
	return self:AddDyzk( dyzk )
end


-------------------------------------------------------------------------------
--  LbBattle:AddDyzk : Adds a dyzk to the scene
-------------------------------------------------------------------------------
function LbBattle:AddDyzk( dyzk )
	self._dyzx[ #self._dyzx+1 ] = dyzk;
end


-------------------------------------------------------------------------------
--  LbBattle:Update : Updates the scene
-------------------------------------------------------------------------------
function LbBattle:Update( dt )
	self._arena:Update( dt );
	
	print( "f" );
	
	for i=1, #self._dyzx do
		self._dyzx[i]:Update( dt );
		
		msg = { d = "foo" }
		
		self._dyzx[i].player:Send( msg );
	end
end


-------------------------------------------------------------------------------
--  LbBattle:Control : Handle input event
-------------------------------------------------------------------------------
function LbBattle:Control( control )
	for i=1, #self._controllers do
		self._controllers[i]:Control( control );
	end
end


-------------------------------------------------------------------------------
--  LbBattle:Message : Handle messages
-------------------------------------------------------------------------------
function LbBattle:Message( msg )
end



--===========================================================================--
--  Initialization
--===========================================================================--
return LbBattle