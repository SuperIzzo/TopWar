--===========================================================================--
--  Dependencies (I)
--===========================================================================--
require 'src.strict';


--===========================================================================--
--  Forward Declarations
--===========================================================================--
-- lunatest dependencies
declare 'random'
declare 'fail'
declare 'skip'
declare 'assert_true'
declare 'assert_false'
declare 'assert_nil'
declare 'assert_not_nil'
declare 'assert_equal'
declare 'assert_not_equal'
declare 'assert_gt'
declare 'assert_lt'
declare 'assert_gte'
declare 'assert_lte'
declare 'assert_len'
declare 'assert_not_len'
declare 'assert_match'
declare 'assert_not_match'
declare 'assert_boolean'
declare 'assert_not_boolean'
declare 'assert_number'
declare 'assert_not_number'
declare 'assert_string'
declare 'assert_not_string'
declare 'assert_table'
declare 'assert_not_table'
declare 'assert_function'
declare 'assert_not_function'
declare 'assert_thread'
declare 'assert_not_thread'
declare 'assert_userdata'
declare 'assert_not_userdata'
declare 'assert_metatable'
declare 'assert_not_metatable'
declare 'assert_error'
declare 'assert_random'


--===========================================================================--
--  Dependencies (II)
--===========================================================================--
require 'test.lib.lunatest.lunatest';




-------------------------------------------------------------------------------
--  is_test_key : Overwrite the default lunatest test function pattern 
-------------------------------------------------------------------------------
--  Tests start with a capital TEST_ followed by anything
function lunatest.is_test_key(k)
   return type(k) == "string" and k:match("TEST_.*")
end




--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	TestMain : 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local TestMain = {}




-------------------------------------------------------------------------------
--  TestMain:GetSuiteList : Generates a list of suites to be tested
-------------------------------------------------------------------------------
function TestMain:GetSuiteList()
	local list = 
	{
		'test.math.TestVector',
		'test.math.TestPolarVector',
		'test.math.TestImageUtils',
		'test.game.physics.TestTop',
		'test.game.physics.TestArena',
	}
	
	return list;
end


-------------------------------------------------------------------------------
--  TestMain:Run : Runs all test suits
-------------------------------------------------------------------------------
function TestMain:Run()
	local suiteList = self:GetSuiteList();
	
	for i = 1, #suiteList do
		lunatest.suite( suiteList[i] );
	end;
	
	print("====== T e s t ======");
	lunatest.run();
	print("====== T e s t ======");
end;


--===========================================================================--
--  Initialization
--===========================================================================--
return TestMain;