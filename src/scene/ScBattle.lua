--===========================================================================--
--  Dependencies
--===========================================================================--
local MathUtils			= require 'src.math.MathUtils'
local Vector			= require 'src.math.Vector'
local Arena				= require 'src.object.Arena'
local Dyzk				= require 'src.object.Dyzk'
local Camera			= require 'src.object.Camera'
local Lights			= require 'src.object.Lights'
local RPMMeter			= require 'src.object.RPMMeter'
local AbilityGadget		= require 'src.object.AbilityGadget'
local SceneManager		= require 'src.scene.SceneManager'
local DBC				= require 'src.input.DirectBattleController'
local AIBC				= require 'src.input.AIBattleController'

local SABoost			= require 'src.abilities.SABoost'
local SARedirect		= require 'src.abilities.SARedirect'
local SAReverseLeap		= require 'src.abilities.SAReverseLeap'
local SAStone			= require 'src.abilities.SAStone'
local SADash			= require 'src.abilities.SADash'

local sign				= MathUtils.Sign

local RPMCoords = 
{
	[1] = { x=0,	y=0  },
	[2] = { x=600,	y=0  }
}


local AbilityCoords = 
{
	[1] = { x=0,	y=25  },
	[2] = { x=600,	y=25  }
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
	local obj = setmetatable( {}, self );	
	
	obj._lights	= Lights:new();
	obj._arena	= Arena:new(	"data/arena/arena3", 4000, 4000, 4000 );
	obj._arena:SetupLights( obj._lights );
	
	obj._camera = Camera:new();
	obj._camera:SetZoom( 0.25 );
	obj._camera:SetZoomSpeed( 0.05, 4 );
	obj._camera:SetMinZoom( 0.1 );
	obj._camera:SetMaxZoom( 0.5 );
	
	-- Create a directional light to lit the scene
	obj._lights:CreateDirectionalLight(
		{255,255,255}, 1, 0, 
		Vector:new( -10, 5, -5):Unit()
	);
	
	obj:_Renew();
	
	return obj;
end


-------------------------------------------------------------------------------
--  ScBattle:_Renew : Clears the scene
-------------------------------------------------------------------------------
function ScBattle:_Renew()
	self._dyzx = {};
	self._controllers = {}
	self._rpmMeters = {}
	self._abilityGadgets = {}
	
	self._arena:RemoveAllDyzx();
	self._camera:RemoveAllTrackObjects();
	
	self._skipUpdate = 0;
	self._gameOverTimer = nil;
end


-------------------------------------------------------------------------------
--  ScBattle:Init : Initializes the scene
-------------------------------------------------------------------------------
function ScBattle:Init()
	local dyzx = 
	{
		"data/dyzx/DyzkAA001.png",
		"data/dyzx/DyzkAA002.png",
		"data/dyzx/DyzkAA003.png",
		"data/dyzx/DyzkAA004.png",
		"data/dyzx/DyzkAA005.png",
		"data/dyzx/DyzkAA006.png",
		"data/dyzx/DyzkAA007.png",
		"data/dyzx/DyzkAA007b.png",
	}

	-- Do some defaiult initialisation in case we have not been setup
	if #self._dyzx==0 then
		local dyzkID = dyzx[ math.random(#dyzx) ];
		local dyzk1 = Dyzk:new( dyzkID );
		local model1 = dyzk1:GetModel();		
		model1.x = 1048;
		model1.y = 1048;
		model1.vx = 10;
		model1.vy = 10;
		model1:SetAbility( 1, SARedirect:new( model1 ) 		);
		model1:SetAbility( 2, SADash:new( model1 ) 		);
		model1:SetAbility( 3, SAReverseLeap:new( model1 )	);
		model1:SetAbility( 4, SAStone:new( model1 ) 		);
		model1:Spin(1);
		self._dyzx[1] = dyzk1;
		
		dyzkID = dyzx[ math.random(#dyzx) ];
		local dyzk2 = Dyzk:new( dyzkID );
		local model2 = dyzk2:GetModel();
		model2.x = 2048;
		model2.y = 2048;
		model2.vx = -10;
		model2.vy = -10;
		model2:SetAbility( 1, SARedirect:new( model2 ) );
		model2:SetAbility( 2, SABoost:new( model2 ) );
		model2:SetAbility( 3, SAReverseLeap:new( model2 ) );
		model2:SetAbility( 4, SAStone:new( model2 ) );
		model2:Spin(1);
		self._dyzx[2] = dyzk2;
		
		dyzkID = dyzx[ math.random(#dyzx) ];
		local dyzk = Dyzk:new( dyzkID );
		local model = dyzk:GetModel();
		model.x = 3048;
		model.y = 3048;
		model.vx = -10;
		model.vy = -10;
		model:SetAbility( 1, SARedirect:new( model ) );
		model:SetAbility( 2, SABoost:new( model ) );
		model:SetAbility( 3, SAReverseLeap:new( model ) );
		model:SetAbility( 4, SAStone:new( model ) );
		model:Spin(1);
		self._dyzx[3] = dyzk;
		
		dyzkID = dyzx[ math.random(#dyzx) ];
		dyzk = Dyzk:new( dyzkID );
		model = dyzk:GetModel();
		model.x = 1048;
		model.y = 3048;
		model.vx = 10;
		model.vy = -10;
		model:SetAbility( 1, SARedirect:new( model ) );
		model:SetAbility( 2, SABoost:new( model ) );
		model:SetAbility( 3, SAReverseLeap:new( model ) );
		model:SetAbility( 4, SAStone:new( model ) );
		model:Spin(1);
		--self._dyzx[4] = dyzk;
		
		dyzkID = dyzx[ math.random(#dyzx) ];
		dyzk = Dyzk:new(dyzkID);
		model = dyzk:GetModel();
		model.x = 3048;
		model.y = 1048;
		model.vx = -10;
		model.vy = 10;
		model:SetAbility( 1, SARedirect:new( model ) );
		model:SetAbility( 2, SABoost:new( model ) );
		model:SetAbility( 3, SAReverseLeap:new( model ) );
		model:SetAbility( 4, SAStone:new( model ) );
		model:Spin(1);
		--self._dyzx[5] = dyzk;
	end


	for i=1, #self._dyzx do
		local dyzk = self._dyzx[i];
		
		self._arena:AddDyzk( dyzk );
		self._camera:AddTrackObject( dyzk:GetModel() );
		
		local w, h = self._arena:GetSize();
		dyzk:SetupLights( self._lights, w, h );
		
		if i<3 then
			self._controllers[i] = DBC:new(i, dyzk:GetModel(), self._camera );		
		else			
			self._controllers[i] = self:ConstructAIController( dyzk )
		end
		
		local rpmCoord = RPMCoords[i]
		if rpmCoord then
			self._rpmMeters[i] = 
				RPMMeter:new( dyzk:GetModel(), rpmCoord.x, rpmCoord.y );
		end		
		
		local abilityCoord = AbilityCoords[i]
		if abilityCoord then
			self._abilityGadgets[i] = 
				AbilityGadget:new( dyzk:GetModel(), abilityCoord.x, abilityCoord.y );
		end	
	end
	
	-- Skip a few update events before we start the game...
	-- This is a hack to ensure that there are no huge time deltas
	-- during the first frame(s) of the game, while we are loading up
	self._skipUpdate = 5;
end


-------------------------------------------------------------------------------
--  ScBattle:Leave : Updates the scene
-------------------------------------------------------------------------------
function ScBattle:Leave()
	self:_Renew()
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
function ScBattle:DestroyDyzk( dyzk )
	-- Remove from the arena
	if self._arena then
		self._arena:RemoveDyzk( dyzk );
	end
	
	-- Remove from the camera track list
	if self._camera then
		self._camera:RemoveTrackObject( dyzk:GetModel() );
	end
end	


-------------------------------------------------------------------------------
--  ScBattle:Update : Updates the scene
-------------------------------------------------------------------------------
function ScBattle:Update( dt )
	
	-- Skip frames if we are not ready
	if self._skipUpdate>0 then
		self._skipUpdate = self._skipUpdate-1;
		return;
	end
	
	self._camera:Update( dt );
	self._arena:Update( dt );
	
	-- Update the controllers
	for i=1, #self._controllers do
		self._controllers[i]:Update( dt );
	end
	
	local dyzxForRemoval = nil
	for dyzk in self._arena:Dyzx() do				
		dyzk:Update( dt );
		
		-- Flag dyzx that need removing from the arena
		if 	not dyzk:GetModel():IsSpinning() or 
			dyzk:GetModel():IsOutOfArena()
		then
			dyzxForRemoval = dyzxForRemoval or {};
			table.insert( dyzxForRemoval, dyzk );
		end		
	end
	
	-- If any dyzx need removing do it now
	if dyzxForRemoval then
		for _, dyzk in ipairs( dyzxForRemoval ) do
			self:DestroyDyzk( dyzk )
		end
	end
		
	for i=1, #self._rpmMeters do
		self._rpmMeters[i]:Update( dt );
	end
	
	
	-- Setup the game over timer
	if self._arena:GetDyzkCount() <=1 and not self._gameOverTimer then
		self._gameOverTimer = 5;
	end
	
	if self._gameOverTimer and self._gameOverTimer>0 then
		self._gameOverTimer = self._gameOverTimer - dt;
		
		if self._gameOverTimer<=0 then
			local sceneManager = SceneManager:GetInstance();
			sceneManager:SetScene( "Main Menu" );
		end
	end
end


-------------------------------------------------------------------------------
--  ScBattle:Draw : Draws the scene
-------------------------------------------------------------------------------
function ScBattle:Draw()
	self._camera:Draw();
	self._arena:Draw();	
	
	for dyzk in self._arena:Dyzx() do
		dyzk:Draw();
	end
	
	self._camera:PostDraw();
	
	for i=1, #self._rpmMeters do
		self._rpmMeters[i]:Draw();
	end
	
	for i=1, #self._abilityGadgets do
		self._abilityGadgets[i]:Draw();
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


-------------------------------------------------------------------------------
--  ScBattle:Control : Handle input event
-------------------------------------------------------------------------------
function ScBattle:ConstructAIController( dyzk )
	local ai = AIBC:new( nil, dyzk:GetModel(), self._arena:GetModel() );
	
	local AIChasing			= require 'src.ai.AIChasing'	
	local AIRandom			= require 'src.ai.AIRandom'
	local AIArenaAvoidance	= require 'src.ai.AIArenaAvoidance'
	local chase 	= AIChasing:new();
	local rand		= AIRandom:new();
	local avoid		= AIArenaAvoidance:new();
	
	chase:SetWeight( math.random()*40 - 10 );
	rand:SetWeight( math.random()*10 );
	avoid:SetWeight( math.random()*40 );
	ai:AddBehaviour( chase );
	ai:AddBehaviour( rand  );
	ai:AddBehaviour( avoid  );
	
	return ai;
end


--===========================================================================--
--  Initialization
--===========================================================================--
return ScBattle;