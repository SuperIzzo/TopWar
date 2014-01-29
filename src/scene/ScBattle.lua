--===========================================================================--
--  Dependencies
--===========================================================================--
local MathUtils			= require 'src.math.MathUtils'
local Arena				= require 'src.object.Arena'
local Dyzk				= require 'src.object.Dyzk'
local Camera			= require 'src.object.Camera'
local RPMMeter			= require 'src.object.RPMMeter'
local AbilityGadget		= require 'src.object.AbilityGadget'
local DBC				= require 'src.input.DirectBattleController'
local AIBC				= require 'src.input.AIBattleController'

local SABoost			= require 'src.abilities.SABoost'
local SARedirect		= require 'src.abilities.SARedirect'
local SAReverseLeap		= require 'src.abilities.SAReverseLeap'
local SAStone			= require 'src.abilities.SAStone'

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
	local obj = {}
	
	obj._dyzx = {};
	obj._controllers = {}
	obj._rpmMeters = {}
	obj._abilityGadgets = {}
	
	obj._arena = Arena:new(
			"data/arena/arena_image2.png", 
			"data/arena/arena_mask2.png" );
	obj._arena:SetScale(4,4,8);
	
	obj._camera = Camera:new();
	obj._camera:SetScale( 0.25, 0.25 );
	
	obj._skipUpdate = 0;
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  ScBattle:Init : Initializes the scene
-------------------------------------------------------------------------------
function ScBattle:Init()

	-- Do some defaiult initialisation in case we have not been setup
	if #self._dyzx==0 then
		local dyzk1 = Dyzk:new("data/dyzx/DyzkAA007b.png");
		local model1 = dyzk1:GetModel();		
		model1.x = 1048;
		model1.y = 1048;
		model1.vx = 10;
		model1.vy = 10;
		model1:SetAbility( 1, SARedirect:new( model1 ) 		);
		model1:SetAbility( 2, SABoost:new( model1 ) 		);
		model1:SetAbility( 3, SAReverseLeap:new( model1 )	);
		model1:SetAbility( 4, SAStone:new( model1 ) 		);
		model1:Spin(1);
		self._dyzx[1] = dyzk1;
		
		local dyzk2 = Dyzk:new("data/dyzx/DyzkAA001.png");
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
		
		local dyzk = Dyzk:new("data/dyzx/DyzkAA003.png");
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
		--self._dyzx[3] = dyzk;
		
		dyzk = Dyzk:new("data/dyzx/DyzkAA002.png");
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
		
		dyzk = Dyzk:new("data/dyzx/DyzkAA004.png");
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
		
		if i<2 then
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
--  ScBattle:Update : Updates the scene
-------------------------------------------------------------------------------
function ScBattle:AddDyzk( dyzk )
	self._dyzx[ #self._dyzx+1 ] = dyzk;
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
		if not dyzk:GetModel():IsSpinning() then
			dyzxForRemoval = dyzxForRemoval or {};
			table.insert( dyzxForRemoval, dyzk );
		end		
	end
	
	-- If any dyzx need removing do it now
	if dyzxForRemoval then
		for _, dyzk in ipairs( dyzxForRemoval ) do			
			self._arena:RemoveDyzk( dyzk );
		end
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
	
	local AIChasing	= require 'src.ai.AIChasing'	
	ai:AddBehaviour( AIChasing:new() );
	
	return ai;
end

--===========================================================================--
--  Initialization
--===========================================================================--
return ScBattle;