--=====================================================================================--
--  Dependencies
--=====================================================================================--
require 'test.lib.lunatest.lunatest';




-----------------------------------------------------------------------------------------
--  is_test_key : Overwrite the default lunatest test function pattern 
-----------------------------------------------------------------------------------------
--  Tests start with a capital TEST_ followed by anything
function lunatest.is_test_key(k)
   return type(k) == "string" and k:match("TEST_.*")
end




--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	TestMain : 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local TestMain = 
{
}




-----------------------------------------------------------------------------------------
--  TestMain:GetSuiteList : Generates a list of suites to be tested
-----------------------------------------------------------------------------------------
function TestMain:GetSuiteList()
	local list = 
	{
		'test.TestVector',
		'test.TestPolarVector',
		'test.TestTop'
	}
	
	return list;
end


-----------------------------------------------------------------------------------------
--  TestMain:Run : Runs all test suits
-----------------------------------------------------------------------------------------
function TestMain:Run()
	local suiteList = self:GetSuiteList();
	
	for i = 1, #suiteList do
		lunatest.suite( suiteList[i] );
	end;
	
	print("====== T e s t ======");
	lunatest.run();
	print("====== T e s t ======");
end;




return TestMain;