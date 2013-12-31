--===========================================================================--
--  Dependencies
--===========================================================================--
local ControlBox 	= require 'src.input.ControlBox'
local Trigger	 	= require 'src.input.TriggerType'

-- Note: Separate in multiple classes when it grows - raphics, input, sound...



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

	local xAxis1	= box:CreateControl("xAxis");
	xAxis1:SetValue(0);
	xAxis1:Bind'Joy1Axis'( 1, 	Trigger.SLIDER(false) 						);
	xAxis1:Bind'Key'( 'a', 		Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
	xAxis1:Bind'Key'( 'd', 		Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
	xAxis1:Bind'Joy1Hat'( 'l1', Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
	xAxis1:Bind'Joy1Hat'( 'lu1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	xAxis1:Bind'Joy1Hat'( 'ld1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	xAxis1:Bind'Joy1Hat'( 'r1', Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
	xAxis1:Bind'Joy1Hat'( 'ru1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	xAxis1:Bind'Joy1Hat'( 'rd1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	xAxis1:Bind'Update'( 1, 	Trigger.ALWAYS() 						);

	local yAxis1	= box:CreateControl("yAxis");
	yAxis1:SetValue(0);
	yAxis1:Bind'Joy1Axis'( 2, 	Trigger.SLIDER(false) 					);
	yAxis1:Bind'Key'( 'w', 		Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
	yAxis1:Bind'Key'( 's', 		Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
	yAxis1:Bind'Joy1Hat'( 'u1', Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
	yAxis1:Bind'Joy1Hat'( 'ru1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	yAxis1:Bind'Joy1Hat'( 'lu1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	yAxis1:Bind'Joy1Hat'( 'd1', Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
	yAxis1:Bind'Joy1Hat'( 'rd1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	yAxis1:Bind'Joy1Hat'( 'ld1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	yAxis1:Bind'Update'( 1, 	Trigger.ALWAYS() 						);

	local A1		= box:CreateControl("A");
	A1:Bind'Joy1Button'( 3,		Trigger.SWITCH(true)					);
	A1:Bind'Key'( ' ', 			Trigger.SWITCH(true)			 		);

	local Left1		= box:CreateControl("Left");
	Left1:Bind'Control'( 'xAxis',	Trigger.SPRING_TO_SWITCH(true, -2, -0.5)	);

	local Right1	= box:CreateControl("Right");
	Right1:Bind'Control'( 'xAxis',	Trigger.SPRING_TO_SWITCH(true, 0.5,  2)	);

	local Up1		= box:CreateControl("Up");
	Up1:Bind'Control'( 'yAxis',		Trigger.SPRING_TO_SWITCH(true, -2, -0.5)	);

	local Down1		= box:CreateControl("Down");
	Down1:Bind'Control'( 'yAxis',	Trigger.SPRING_TO_SWITCH(true, 0.5,  2)	);
	
	-- player 2
	elseif box.player and box.player==2 then
	
	local xAxis1	= box:CreateControl("xAxis");
	xAxis1:SetValue(0);
	xAxis1:Bind'Joy2Axis'( 1, 	Trigger.SLIDER(false) 					);
	xAxis1:Bind'Joy2Hat'( 'l1', Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
	xAxis1:Bind'Joy2Hat'( 'lu1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	xAxis1:Bind'Joy2Hat'( 'ld1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	xAxis1:Bind'Joy2Hat'( 'r1', Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
	xAxis1:Bind'Joy2Hat'( 'ru1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	xAxis1:Bind'Joy2Hat'( 'rd1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	xAxis1:Bind'Update'( 1, 	Trigger.ALWAYS() 						);

	local yAxis1	= box:CreateControl("yAxis");
	yAxis1:SetValue(0);
	yAxis1:Bind'Joy2Axis'( 2, 	Trigger.SLIDER(false) 					);
	yAxis1:Bind'Joy2Hat'( 'u1', Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
	yAxis1:Bind'Joy2Hat'( 'ru1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	yAxis1:Bind'Joy2Hat'( 'lu1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	yAxis1:Bind'Joy2Hat'( 'd1', Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
	yAxis1:Bind'Joy2Hat'( 'rd1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	yAxis1:Bind'Joy2Hat'( 'ld1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	yAxis1:Bind'Update'( 1, 	Trigger.ALWAYS() 						);

	local A1		= box:CreateControl("A");
	A1:Bind'Joy2Button'( 3,		Trigger.SWITCH(true)					);

	local Left1		= box:CreateControl("Left");
	Left1:Bind'Control'( 'xAxis',	Trigger.SPRING_TO_SWITCH(true, -2, -0.5)	);

	local Right1	= box:CreateControl("Right");
	Right1:Bind'Control'( 'xAxis',	Trigger.SPRING_TO_SWITCH(true, 0.5,  2)	);

	local Up1		= box:CreateControl("Up");
	Up1:Bind'Control'( 'yAxis',		Trigger.SPRING_TO_SWITCH(true, -2, -0.5)	);

	local Down1		= box:CreateControl("Down");
	Down1:Bind'Control'( 'yAxis',	Trigger.SPRING_TO_SWITCH(true, 0.5,  2)	);
	
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
Settings_LoadConfig();
return Settings;