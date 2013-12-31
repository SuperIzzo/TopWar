--===========================================================================--
--  Dependencies
--===========================================================================--
local DyzkModel 		= require 'src.model.DyzkModel'
local ipairs			= ipairs
local coroutine			= coroutine


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Test
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local T = {}


-------------------------------------------------------------------------------
--  LoadDyzk : loads and caches DyzkModel test images
-------------------------------------------------------------------------------
local loadedDyzx = {}	-- cache loaded DyzkModels
local function LoadDyzk( dyzkFName )
	if not loadedDyzx[ dyzkFName ] then
		local dyzk = DyzkModel:new();
		local dyzkImg = love.image.newImageData( dyzkFName );
		dyzk:SetFromImageData( dyzkImg );
		
		loadedDyzx[ dyzkFName ] = dyzk;
	end;
	
	return loadedDyzx[dyzkFName];
end


-------------------------------------------------------------------------------
--  TEST_default_initializes_to_blank
-------------------------------------------------------------------------------
function T: TEST_default_initializes_to_blank()
	local dyzk = DyzkModel:new();

	assert_equal( 0,		dyzk:GetWeight(), 0.001 );
	assert_equal( 0,		dyzk:GetJaggedness(), 0.001 );
	assert_equal( 0,		dyzk:GetMaxRadius(), 0.001 );
end


-------------------------------------------------------------------------------
--  TEST_setting_and_retreiving_the_weight_of_a_dyzk
-------------------------------------------------------------------------------
function T: TEST_setting_and_retreiving_the_weight_of_a_dyzk()
	local dyzk = DyzkModel:new()
	
	dyzk:SetWeight( 5.6 );
	
	assert_equal( 5.6,		dyzk:GetWeight(), 0.001 );
end


-------------------------------------------------------------------------------
--  TEST_setting_and_retreiving_the_jaggedness_of_a_dyzk
-------------------------------------------------------------------------------
function T: TEST_setting_and_retreiving_the_jaggedness_of_a_dyzk()
	local dyzk = DyzkModel:new()
	
	dyzk:SetJaggedness( 0.6 );
	
	assert_equal( 0.6,		dyzk:GetJaggedness(), 0.001 );
end


-------------------------------------------------------------------------------
--  TEST_setting_and_retreiving_the_max_radius_of_a_dyzk
-------------------------------------------------------------------------------
function T: TEST_setting_and_retreiving_the_max_radius_of_a_dyzk()
	local dyzk = DyzkModel:new()
	
	dyzk:SetMaxRadius( 5.6 );
	
	assert_equal( 5.6,		dyzk:GetMaxRadius(), 0.001 );
end


-------------------------------------------------------------------------------
--  TEST_setting_and_retreiving_the_balance_of_a_dyzk
-------------------------------------------------------------------------------
function T: TEST_setting_and_retreiving_the_balance_of_a_dyzk()
	local dyzk = DyzkModel:new()
	
	dyzk:SetBalance( 0.6 );
	
	assert_equal( 0.6,		dyzk:GetBalance(), 0.001 );
end


-------------------------------------------------------------------------------
--  TEST_error_when_setting_parameters_in_incorrect_range
-------------------------------------------------------------------------------
function T: TEST_error_when_setting_parameters_in_incorrect_range()
	local dyzk = DyzkModel:new()
	
	-- Weight cannot be negative
	assert_error(	function() dyzk:SetWeight( -1 );	end				);
	
	-- Radius cannot be negative
	assert_error(	function() dyzk:SetMaxRadius( -1 );	end				);
	
	-- Jaggedness can only be between 0 and 1	
	assert_error(	function() dyzk:SetJaggedness( -1 ); end			);
	assert_error(	function() dyzk:SetJaggedness( 2 ); end			);
	
	-- Balance can only be between 0 and 1
	assert_error(	function() dyzk:SetBalance( -1 ); end			);
	assert_error(	function() dyzk:SetBalance( 2 ); end				);
end


-------------------------------------------------------------------------------
--  TEST_error_when_setting_weigth_to_anything_other_than_a_number
-------------------------------------------------------------------------------
function T: TEST_error_when_setting_weigth_to_anything_other_than_a_number()
	local setters = 
	{
		"SetWeight",
		"SetMaxRadius",
		"SetJaggedness",
		"SetBalance",
	}
	local dyzk = DyzkModel:new()
	
	-- Create a coroutine or testing
	local co = coroutine.create( function() end )
	
	for i, setter in ipairs( setters ) do
		assert_error( 	function() DyzkModel[setter]( DyzkModel, 'a' ); end				);
		assert_error( 	function() DyzkModel[setter]( DyzkModel, true ); end			);
		assert_error( 	function() DyzkModel[setter]( DyzkModel, nil ); end				);
		assert_error( 	function() DyzkModel[setter]( DyzkModel, {} ); end				);
		assert_error( 	function() DyzkModel[setter]( DyzkModel, function() end ); end	);
		assert_error( 	function() DyzkModel[setter]( DyzkModel, co ); end				);
	end
end


-------------------------------------------------------------------------------
--  TEST_loaded_dyzk_has_correct_max_radius
-------------------------------------------------------------------------------
function T: TEST_loaded_dyzk_has_correct_max_radius()	
	local radTests = 
	{
		--[[--  test image				|  radius  |  tolerance  --]]--
		{ 	"test/img/dyzk0000.png",			128,		2			  },
		{ 	"test/img/dyzk0002.png",			128,		2			  },
		{ 	"test/img/dyzk0010.png",			98,			2			  },
		{ 	"test/img/dyzk0012.png",			98,			2			  },
		{ 	"test/img/dyzk0004.png",			175,		4			  },
		{ 	"test/img/dyzk0005.png",			120,		4			  },
		{ 	"test/img/dyzk0006.png",			128,		2			  },
		{ 	"test/img/dyzk0007.png",			128,		2			  },
	}
	
	for i= 1, #radTests do
		local imgFile 		=  radTests[i][1];
		local expectedRad 	=  radTests[i][2];
		local tolerance 	=  radTests[i][3];
		
		local dyzk = LoadDyzk( imgFile );
	
		assert_equal( expectedRad,  	dyzk:GetMaxRadius(), 	tolerance );
	end
	
end


-------------------------------------------------------------------------------
--  TEST_loaded_dyzk_has_correct_jaggedness
-------------------------------------------------------------------------------
function T: TEST_loaded_dyzk_has_correct_jaggedness()
	local dyzk0000 = LoadDyzk( "test/img/dyzk0000.png" );
	assert_equal( 0,	dyzk0000:GetJaggedness(), 	0.3);
	
	local dyzk0020 = LoadDyzk( "test/img/dyzk0020.png" );
	assert_equal( 0,	dyzk0020:GetJaggedness(), 	0.3);
	
	local dyzk0001 = LoadDyzk( "test/img/dyzk0001.png" );
	assert_gt( dyzk0000:GetJaggedness(), 		dyzk0001:GetJaggedness() );
	
	local dyzk0002 = LoadDyzk( "test/img/dyzk0002.png" );
	assert_gt( dyzk0001:GetJaggedness(), 		dyzk0002:GetJaggedness() );
	
	local dyzk0003 = LoadDyzk( "test/img/dyzk0003.png" );
	assert_gt( dyzk0002:GetJaggedness(), 		dyzk0003:GetJaggedness() );
	
	local dyzk0004 = LoadDyzk( "test/img/dyzk0004.png" );
	assert_gt( dyzk0003:GetJaggedness(), 		dyzk0004:GetJaggedness() );
	
	local dyzk0005 = LoadDyzk( "test/img/dyzk0005.png" );
	assert_gt( dyzk0004:GetJaggedness(), 		dyzk0005:GetJaggedness() );
	
	local dyzk0006 = LoadDyzk( "test/img/dyzk0006.png" );
	assert_gt( dyzk0005:GetJaggedness(), 		dyzk0006:GetJaggedness() );
	
	local dyzk0026 = LoadDyzk( "test/img/dyzk0026.png" );
	
	assert_equal( 1, dyzk0006:GetJaggedness(), 		0.2 );
	assert_equal( 1, dyzk0026:GetJaggedness(), 		0.2 );
end


-------------------------------------------------------------------------------
--  TEST_loaded_dyzk_has_correct_weight
-------------------------------------------------------------------------------
function T: TEST_loaded_dyzk_has_correct_weight()
	local weightTests = 
	{
		--[[--  test image				|  weight  |  tolerance  --]]--
		{ 	"test/img/dyzk0000.png",			51.1,		0.05		  },
		{ 	"test/img/dyzk0010.png",			28.8,		0.05		  },
		{ 	"test/img/dyzk0020.png",			12.8,		0.05		  },
		{ 	"test/img/dyzk0001.png",			48.8,		0.05		  },
		{ 	"test/img/dyzk0004.png",			55.9,		0.05		  },
	}
	
	for i= 1, #weightTests do
		local imgFile 		=  weightTests[i][1];
		local expWeight 	=  weightTests[i][2];
		local tolerance 	=  weightTests[i][3];
		
		local dyzk = LoadDyzk( imgFile );
	
		assert_equal( expWeight,  	dyzk:GetWeight(), 	tolerance );
	end
end


-------------------------------------------------------------------------------
--  TEST_loaded_dyzk_has_correct_balance
-------------------------------------------------------------------------------
function T: TEST_loaded_dyzk_has_correct_balance()
	local balanceTests = 
	{
		--[[--  test image				| balance  |  tolerance  --]]--
		{ 	"test/img/dyzk0000.png",			1,			0.05		  },
		{ 	"test/img/dyzk0010.png",			1,			0.05		  },
		{ 	"test/img/dyzk0020.png",			1,			0.05		  },
		{ 	"test/img/dyzk0001.png",			1,			0.05		  },
		{ 	"test/img/dyzk0004.png",			1,			0.05		  },
		{ 	"test/img/dyzk0006.png",			0.5,		0.05		  },
		{ 	"test/img/dyzk0026.png",			0.5,		0.05		  },
		{ 	"test/img/dyzk0005.png",			0.83,		0.05		  },
	}
	
	for i= 1, #balanceTests do
		local imgFile 		=  balanceTests[i][1];
		local expBalance 	=  balanceTests[i][2];
		local tolerance 	=  balanceTests[i][3];
		
		local dyzk = LoadDyzk( imgFile );
	
		assert_equal( expBalance,  	dyzk:GetBalance(), 	tolerance );
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return T;