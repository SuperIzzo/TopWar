--===========================================================================--
--  Dependencies
--===========================================================================--
local Arena				= require 'src.object.Arena'
local Dyzk				= require 'src.object.Dyzk'
local Camera			= require 'src.object.Camera'
local RPMMeter			= require 'src.object.RPMMeter'
local DBC				= require 'src.input.DirectBattleController'

local SABoost			= require 'src.abilities.SABoost'
local SARedirect		= require 'src.abilities.SARedirect'
local SAReverseLeap		= require 'src.abilities.SAReverseLeap'



local RPMCoords = 
{
	[1] = { x=0,	y=0  },
	[2] = { x=600,	y=0  }
}

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class ScBattle : Battle scene 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local ScBattle = {}
ScBattle.__index = ScBattle


-------------------------------------------------------------------------------
--  ScBattle:new : Creates a new scene
-------------------------------------------------------------------------------
function ScBattle:new()
	local obj = {}
	
	obj._dyzx = {};
	obj._controllers = {}
	obj._rpmMeters = {}
	
	obj._arena = Arena:new("data/arena/arena_mask2.png");
	obj._arena:SetScale(4,4,8);
	
	obj._camera = Camera:new();
	obj._camera:SetScale( 0.25, 0.25 );
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  ScBattle:Init : Initializes the scene
-------------------------------------------------------------------------------
function ScBattle:Init()

	-- Do some defaiult initialisation in case we have not been setup
	if #self._dyzx==0 then
		local dyzk1 = Dyzk:new("data/dyzx/DyzkAA002.png");
		dyzk1.phDyzk.x = 100;
		dyzk1.phDyzk.y = 100;
		dyzk1.phDyzk.vx = 10;
		dyzk1.phDyzk.vy = 10;
		dyzk1.phDyzk.angVel = 600;
		dyzk1.phDyzk:SetAbility( 1, SAReverseLeap:new( dyzk1.phDyzk ) );
		
		local dyzk2 = Dyzk:new("data/dyzx/DyzkAA003.png");
		dyzk2.phDyzk.x = 2048;
		dyzk2.phDyzk.y = 2048;
		dyzk2.phDyzk.vx = -10;
		dyzk2.phDyzk.vy = -10;
		dyzk2.phDyzk.angVel = 600;
		
		self._dyzx[1] = dyzk1;
		self._dyzx[2] = dyzk2;
	end


	for i=1, #self._dyzx do
		local dyzk = self._dyzx[i];
		
		self._arena:AddDyzk( dyzk );
		self._camera:AddTrackObject( dyzk:GetPhysicsBody() );
		self._controllers[i] = DBC:new(i, dyzk:GetPhysicsBody());
		
		local rpmCoord = RPMCoords[i]
		if rpmCoord then
			self._rpmMeters[i] = 
				RPMMeter:new( dyzk:GetPhysicsBody(), rpmCoord.x, rpmCoord.y );
		end		
	end
end


-------------------------------------------------------------------------------
--  ScBattle:Update : Updates the scene
-------------------------------------------------------------------------------
function ScBattle:AddDyzk( dyzk )
	self._dyzx[ #self._dyzx+1 ] = dyzk;
end


-------------------------------------------------------------------------------
--  ScBattle:Update : Updates the scene
-------------------------------------------------------------------------------
function ScBattle:Update( dt )
	self._camera:Update( dt );
	self._arena:Update( dt );
	
	for i=1, #self._dyzx do
		self._dyzx[i]:Update( dt );
	end
	
	for i=1, #self._rpmMeters do
		self._rpmMeters[i]:Update( dt );
	end
end


-------------------------------------------------------------------------------
--  ScBattle:Draw : Draws the scene
-------------------------------------------------------------------------------
function ScBattle:Draw()
	self._camera:Draw();
	self._arena:Draw();
	
	for i=1, #self._dyzx do
		self._dyzx[i]:Draw();
	end
	
	self._camera:PostDraw();
	
	for i=1, #self._rpmMeters do
		self._rpmMeters[i]:Draw();
	end
end


-------------------------------------------------------------------------------
--  ScBattle:Control : Handle input event
-------------------------------------------------------------------------------
function ScBattle:Control( control )
	for i=1, #self._controllers do
		self._controllers[i]:Control( control );
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return ScBattle;