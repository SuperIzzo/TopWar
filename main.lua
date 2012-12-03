require 'src.strict'

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

local TestMain =		require "test.TestMain"


TestMain:Run();

--Shape affects physical traits - speed, weight, attack
--Color and symbols affect special abilities