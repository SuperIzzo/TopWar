--===========================================================================--
--  Dependencies
--===========================================================================--
local ControlBox 		= require 'src.input.ControlBox'
local DigitalAxis		= require 'src.input.trigger.DigitalAxis'
local BinaryButton		= require 'src.input.trigger.BinaryButton'
local AnalogueButton	= require 'src.input.trigger.AnalogueButton'
local AnalogueAxis		= require 'src.input.trigger.AnalogueAxis'

-- Note: Separate in multiple classes when it grows - graphics, input, sound...



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Settings: Game settings management class
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  The Settings class is best place to put specific or general variables and 
--  constants that relate to and configure one or more subsystems- i.e.settings
--  This class will handle loading and saving settings from multiple locations,
--  default settings, recomended settings and more... 
--  For the time being though it will be a mess.
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Settings = {}
Settings.__index = Settings


-------------------------------------------------------------------------------
--  Settings:new : Creates a settings object
-------------------------------------------------------------------------------
function Settings:new()
	local obj = {}
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  Settings_LoadConfig : Loads the love configurations
-------------------------------------------------------------------------------
local function Settings_LoadConfig()
	Settings._config = nil
	
	if love.conf then
		local gameConf	 = {}
		gameConf.window  = {}
		gameConf.modules = {}
		
		-- For backwards compatibility
		gameConf.screen  = gameConf.window
	
		love.conf( gameConf );		
		
		Settings._config = gameConf;
	end
end


-------------------------------------------------------------------------------
--  Settings:GetConfig : Returns a configuration setting
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  If a 'name' has been given returns the config with the given name, 
--  otherwise it returns the configuration table.
--	If a configuration table has not been loaded or the config option does not
--  exist it will return `nil'
-------------------------------------------------------------------------------
function Settings:GetConfig( name )
	if self._config then		
		if name then
			return self._config[ name ];
		else
			return self._config;
		end		
	end	
end


-------------------------------------------------------------------------------
--  Settings:LoadDefaultControls : Loads the default controls
-------------------------------------------------------------------------------
function Settings:LoadDefaultControls( box )

	-- player 1
	if box.player and box.player==1 then
		
		-- Setup the triggers (some can be reused on multiple controls)
		local digitalAxisX 			= DigitalAxis:new();
		local digitalAxisY 			= DigitalAxis:new();
		local digitalJoyAxisX		= DigitalAxis:new();
		local digitalJoyAxisY		= DigitalAxis:new();
		local negAxisTrigger		= AnalogueButton:new( -2, -0.5 );
		local posAxisTrigger		= AnalogueButton:new( 0.5,  2 );
		local anlgAxisTrigger		= AnalogueAxis:new()
		local binButtonTrigger		= BinaryButton:new();
		
		digitalAxisX:SetOffValue(0)
		digitalAxisY:SetOffValue(0)
		digitalJoyAxisX:SetOffValue(0)
		digitalJoyAxisY:SetOffValue(0)
		
		local xAxis = box:CreateControl("xAxis");
		xAxis:SetValue(0);
		xAxis:Bind'Key'( 'a', digitalAxisX:TriggerOn(-1) );
		xAxis:Bind'Key'( 'd', digitalAxisX:TriggerOn( 1) );
		xAxis:Bind'Joy1Axis'( 1, anlgAxisTrigger:Trigger() );
		xAxis:Bind'Joy1Hat'( 'l', digitalJoyAxisX:TriggerOn(-1) );
		xAxis:Bind'Joy1Hat'( 'ld', digitalJoyAxisX:TriggerOn(-1) );
		xAxis:Bind'Joy1Hat'( 'lu', digitalJoyAxisX:TriggerOn(-1) );
		xAxis:Bind'Joy1Hat'( 'r', digitalJoyAxisX:TriggerOn( 1) );
		xAxis:Bind'Joy1Hat'( 'ru', digitalJoyAxisX:TriggerOn( 1) );
		xAxis:Bind'Joy1Hat'( 'rd', digitalJoyAxisX:TriggerOn( 1) );

		local yAxis	= box:CreateControl("yAxis");
		yAxis:SetValue(0);
		yAxis:Bind'Key'( 'w', digitalAxisY:TriggerOn(-1) );
		yAxis:Bind'Key'( 's', digitalAxisY:TriggerOn( 1) );
		yAxis:Bind'Joy1Axis'( 2, anlgAxisTrigger:Trigger() );
		yAxis:Bind'Joy1Hat'( 'u', digitalJoyAxisY:TriggerOn(-1) );
		yAxis:Bind'Joy1Hat'( 'lu', digitalJoyAxisY:TriggerOn(-1) );
		yAxis:Bind'Joy1Hat'( 'ru', digitalJoyAxisY:TriggerOn(-1) );
		yAxis:Bind'Joy1Hat'( 'd', digitalJoyAxisY:TriggerOn( 1) );
		yAxis:Bind'Joy1Hat'( 'ld', digitalJoyAxisY:TriggerOn( 1) );
		yAxis:Bind'Joy1Hat'( 'rd', digitalJoyAxisY:TriggerOn( 1) );
		
		local Left				= box:CreateControl("Left");
		Left:SetValue( false );
		Left:Bind'Control'( 'xAxis',	negAxisTrigger:Trigger()	);

		local Right				= box:CreateControl("Right");		
		Right:SetValue( false );
		Right:Bind'Control'( 'xAxis',	posAxisTrigger:Trigger()	);

		local Up				= box:CreateControl("Up");		
		Up:SetValue( false );
		Up:Bind'Control'( 'yAxis',		negAxisTrigger:Trigger() 	);

		local Down				= box:CreateControl("Down");
		Down:SetValue( false );
		Down:Bind'Control'( 'yAxis',	posAxisTrigger:Trigger()	);


		local xPoint			= box:CreateControl( "xPoint" )
		xPoint:SetValue( 0 );
		xPoint:Bind'MousePos'( 'x',		anlgAxisTrigger:Trigger()	);

		local yPoint			= box:CreateControl( "yPoint" )
		yPoint:SetValue( 0 );
		yPoint:Bind'MousePos'( 'y',		anlgAxisTrigger:Trigger()	);

		local Click				= box:CreateControl( "Click" )
		Click:SetValue( false );
		Click:Bind'MouseBtn'( 'l',		binButtonTrigger:Trigger()	);
	
	
		local A					= box:CreateControl( "A" )
		A:SetValue( false );
		A:Bind'Key'( 'j',				binButtonTrigger:Trigger()	);
		A:Bind'Joy1Button'( 3,			binButtonTrigger:Trigger()	);
		
		local B					= box:CreateControl( "B" )
		B:SetValue( false );
		B:Bind'Key'( 'k',				binButtonTrigger:Trigger()	);
		B:Bind'Joy1Button'( 2,			binButtonTrigger:Trigger()	);
		
		local X					= box:CreateControl( "X" )
		X:SetValue( false );
		X:Bind'Key'( 'u',				binButtonTrigger:Trigger()	);
		X:Bind'Joy1Button'( 4,			binButtonTrigger:Trigger()	);
		
		local Y					= box:CreateControl( "Y" )
		Y:SetValue( false );
		Y:Bind'Key'( 'i',				binButtonTrigger:Trigger()	);
		Y:Bind'Joy1Button'( 1,			binButtonTrigger:Trigger()	);

	elseif box.player and box.player==2 then
		-- Setup the triggers (some can be reused on multiple controls)
		local digitalAxisX 			= DigitalAxis:new();
		local digitalAxisY 			= DigitalAxis:new();
		local digitalJoyAxisX		= DigitalAxis:new();
		local digitalJoyAxisY		= DigitalAxis:new();
		local negAxisTrigger		= AnalogueButton:new( -2, -0.5 );
		local posAxisTrigger		= AnalogueButton:new( 0.5,  2 );
		local anlgAxisTrigger		= AnalogueAxis:new()
		local binButtonTrigger		= BinaryButton:new();
		
		digitalAxisX:SetOffValue(0)
		digitalAxisY:SetOffValue(0)
		digitalJoyAxisX:SetOffValue(0)
		digitalJoyAxisY:SetOffValue(0)
		
		local xAxis = box:CreateControl("xAxis");
		xAxis:SetValue(0);
		xAxis:Bind'Key'( 'left', digitalAxisX:TriggerOn(-1) );
		xAxis:Bind'Key'( 'right', digitalAxisX:TriggerOn( 1) );
		xAxis:Bind'Joy2Axis'( 1, anlgAxisTrigger:Trigger() );
		xAxis:Bind'Joy2Hat'( 'l', digitalJoyAxisX:TriggerOn(-1) );
		xAxis:Bind'Joy2Hat'( 'ld', digitalJoyAxisX:TriggerOn(-1) );
		xAxis:Bind'Joy2Hat'( 'lu', digitalJoyAxisX:TriggerOn(-1) );
		xAxis:Bind'Joy2Hat'( 'r', digitalJoyAxisX:TriggerOn( 1) );
		xAxis:Bind'Joy2Hat'( 'ru', digitalJoyAxisX:TriggerOn( 1) );
		xAxis:Bind'Joy2Hat'( 'rd', digitalJoyAxisX:TriggerOn( 1) );

		local yAxis	= box:CreateControl("yAxis");
		yAxis:SetValue(0);
		yAxis:Bind'Key'( 'up', digitalAxisY:TriggerOn(-1) );
		yAxis:Bind'Key'( 'down', digitalAxisY:TriggerOn( 1) );
		yAxis:Bind'Joy2Axis'( 2, anlgAxisTrigger:Trigger() );
		yAxis:Bind'Joy2Hat'( 'u', digitalJoyAxisY:TriggerOn(-1) );
		yAxis:Bind'Joy2Hat'( 'lu', digitalJoyAxisY:TriggerOn(-1) );
		yAxis:Bind'Joy2Hat'( 'ru', digitalJoyAxisY:TriggerOn(-1) );
		yAxis:Bind'Joy2Hat'( 'd', digitalJoyAxisY:TriggerOn( 1) );
		yAxis:Bind'Joy2Hat'( 'ld', digitalJoyAxisY:TriggerOn( 1) );
		yAxis:Bind'Joy2Hat'( 'rd', digitalJoyAxisY:TriggerOn( 1) );
		
		local Left				= box:CreateControl("Left");
		Left:SetValue( false );
		Left:Bind'Control'( 'xAxis',	negAxisTrigger:Trigger()	);

		local Right				= box:CreateControl("Right");		
		Right:SetValue( false );
		Right:Bind'Control'( 'xAxis',	posAxisTrigger:Trigger()	);

		local Up				= box:CreateControl("Up");		
		Up:SetValue( false );
		Up:Bind'Control'( 'yAxis',		negAxisTrigger:Trigger() 	);

		local Down				= box:CreateControl("Down");
		Down:SetValue( false );
		Down:Bind'Control'( 'yAxis',	posAxisTrigger:Trigger()	);

		local A					= box:CreateControl( "A" )
		A:SetValue( false );
		A:Bind'Key'( 'kp1',				binButtonTrigger:Trigger()	);
		A:Bind'Joy2Button'( 3,			binButtonTrigger:Trigger()	);
		
		local B					= box:CreateControl( "B" )
		B:SetValue( false );
		B:Bind'Key'( 'kp2',				binButtonTrigger:Trigger()	);
		B:Bind'Joy2Button'( 2,			binButtonTrigger:Trigger()	);
		
		local X					= box:CreateControl( "X" )
		X:SetValue( false );
		X:Bind'Key'( 'kp3',				binButtonTrigger:Trigger()	);
		X:Bind'Joy2Button'( 4,			binButtonTrigger:Trigger()	);
		
		local Y					= box:CreateControl( "Y" )
		Y:SetValue( false );
		Y:Bind'Key'( 'kp4',				binButtonTrigger:Trigger()	);
		Y:Bind'Joy2Button'( 1,			binButtonTrigger:Trigger()	);
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
Settings_LoadConfig();
return Settings;