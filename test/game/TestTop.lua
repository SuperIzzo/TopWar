--===========================================================================--
--  Dependencies
--===========================================================================--
local Top 			= require 'src.game.Top'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Test
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local T = {}


-------------------------------------------------------------------------------
--  LoadTop : loads and caches top test images
-------------------------------------------------------------------------------
local loadedTops = {}	-- cache loaded tops
local function LoadTop( topFileName )
	if not loadedTops[ topFileName ] then
		local top = Top:new();
		local topImg = love.image.newImageData( topFileName );
		top:SetImage( topImg );
		
		loadedTops[ topFileName ] = top;
	end;
	
	return loadedTops[topFileName];
end


-------------------------------------------------------------------------------
--  TEST_default_initializes_to_blank
-------------------------------------------------------------------------------
function T: TEST_default_initializes_to_blank()
	local top = Top:new();

	assert_equal( 0,		top:GetWeight(), 0.001 );
	assert_equal( 0,		top:GetJaggedness(), 0.001 );
	assert_equal( 0,		top:GetRadius(), 0.001 );
end


-------------------------------------------------------------------------------
--  TEST_setting_and_retreiving_the_weight_of_a_top
-------------------------------------------------------------------------------
function T: TEST_setting_and_retreiving_the_weight_of_a_top()
	local top = Top:new()
	
	top:SetWeight( 5.6 );
	
	assert_equal( 5.6,		top:GetWeight(), 0.001 );
end


-------------------------------------------------------------------------------
--  TEST_setting_and_retreiving_the_jaggedness_of_a_top
-------------------------------------------------------------------------------
function T: TEST_setting_and_retreiving_the_jaggedness_of_a_top()
	local top = Top:new()
	
	top:SetJaggedness( 5.6 );
	
	assert_equal( 5.6,		top:GetJaggedness(), 0.001 );
end


-------------------------------------------------------------------------------
--  TEST_setting_and_retreiving_the_radius_of_a_top
-------------------------------------------------------------------------------
function T: TEST_setting_and_retreiving_the_radius_of_a_top()
	local top = Top:new()
	
	top:SetRadius( 5.6 );
	
	assert_equal( 5.6,		top:GetRadius(), 0.001 );
end


-------------------------------------------------------------------------------
--  TEST_error_when_setting_negative_weight
-------------------------------------------------------------------------------
function T: TEST_error_when_setting_negative_weight()
	local top = Top:new()
	
	local function f() 
		top:SetWeight( -1 );
	end;
	
	assert_error( f );
end


-------------------------------------------------------------------------------
--  TEST_error_when_setting_weigth_to_anything_other_than_a_number
-------------------------------------------------------------------------------
function T: TEST_error_when_setting_weigth_to_anything_other_than_a_number()
	local top = Top:new()
	
	-- Create a coroutine or testing
	local co = coroutine.create( function() end )
	
	assert_error( 	function() top:SetWeight( 'a' ); end			);
	assert_error( 	function() top:SetWeight( true ); end			);
	assert_error( 	function() top:SetWeight( nil ); end			);
	assert_error( 	function() top:SetWeight( {} ); end				);
	assert_error( 	function() top:SetWeight( function() end ); end	);
	assert_error( 	function() top:SetWeight( co ); end				);
end


-------------------------------------------------------------------------------
--  TEST_loaded_top_has_correct_radius
-------------------------------------------------------------------------------
function T: TEST_loaded_top_has_correct_radius()	
	local radTests = 
	{
		--[[--  test image				|  radius  |  tolerance  --]]--
		{ 	"test/img/top0000.png",			128,		2			  },
		{ 	"test/img/top0002.png",			128,		2			  },
		{ 	"test/img/top0010.png",			98,			2			  },
		{ 	"test/img/top0012.png",			98,			2			  },
		{ 	"test/img/top0004.png",			175,		4			  },
		{ 	"test/img/top0005.png",			120,		4			  },
		{ 	"test/img/top0006.png",			128,		2			  },
		{ 	"test/img/top0007.png",			128,		2			  },
	}
	
	for i= 1, #radTests do
		local imgFile 		=  radTests[i][1];
		local expectedRad 	=  radTests[i][2];
		local tolerance 	=  radTests[i][3];
		
		local top = LoadTop( imgFile );
	
		assert_equal( expectedRad,  	top:GetRadius(), 	tolerance );
	end
	
end


-------------------------------------------------------------------------------
--  TEST_loaded_top_has_correct_jaggedness
-------------------------------------------------------------------------------
function T: TEST_loaded_top_has_correct_jaggedness()
	local top0000 = LoadTop( "test/img/top0000.png" );
	assert_equal( 0,	top0000:GetJaggedness(), 	0.3);
	
	local top0020 = LoadTop( "test/img/top0020.png" );
	assert_equal( 0,	top0020:GetJaggedness(), 	0.3);
	
	local top0001 = LoadTop( "test/img/top0001.png" );
	assert_gt( top0000:GetJaggedness(), 		top0001:GetJaggedness() );
	
	local top0002 = LoadTop( "test/img/top0002.png" );
	assert_gt( top0001:GetJaggedness(), 		top0002:GetJaggedness() );
	
	local top0003 = LoadTop( "test/img/top0003.png" );
	assert_gt( top0002:GetJaggedness(), 		top0003:GetJaggedness() );
	
	local top0004 = LoadTop( "test/img/top0004.png" );
	assert_gt( top0003:GetJaggedness(), 		top0004:GetJaggedness() );
	
	local top0005 = LoadTop( "test/img/top0005.png" );
	assert_gt( top0004:GetJaggedness(), 		top0005:GetJaggedness() );
	
	local top0006 = LoadTop( "test/img/top0006.png" );
	assert_gt( top0005:GetJaggedness(), 		top0006:GetJaggedness() );
	
	local top0026 = LoadTop( "test/img/top0026.png" );
	
	assert_equal( 1, top0006:GetJaggedness(), 		0.2 );
	assert_equal( 1, top0026:GetJaggedness(), 		0.2 );
end


--===========================================================================--
--  Initialization
--===========================================================================--
return T;