--
-- strict.lua
-- checks uses of undeclared global variables
-- All global variables must be 'declared' through a regular assignment
-- (even assigning nil will do) in a main chunk before being used
-- anywhere or assigned to inside a function.
--
-- From Lua distribution (etc/strict.lua)
--

-- Modified version. Added keywords to enable the explicit declaration of global variables
-- without an assignment 

local getinfo		= _G.debug.getinfo
local error			= _G.error
local rawset		= _G.rawset
local rawget 		= _G.rawget
local getmetatable	= _G.getmetatable
local setmetatable	= _G.setmetatable


local mt = getmetatable(_G)
if mt == nil then
  mt = {}
end

mt.__declared = {}

local function what ()
  local d = getinfo(3, "S")
  return d and d.what or "C"
end

mt.__newindex = function (t, n, v)
  if not mt.__declared[n] then
    local w = what()
	print( w, n, v );
    if w ~= "C" then
      error("assign to undeclared variable '"..n.."'", 2)
    end
    mt.__declared[n] = true
  end
  rawset(t, n, v)
end

mt.__index = function (t, n)
  if not mt.__declared[n] and what() ~= "C" then
    error("variable '"..n.."' is not declared", 2)
  end
  return rawget(t, n)
end

function declared( name , env )
	local env = getmetatable(env) or mt;
	if env.__declared then
		return env.__declared[name]
	else
		return true;	-- Not a subject to restrictions
	end
end

function declare( name , env )
	local env = getmetatable(env) or mt;
	if env.__declared then
		env.__declared[name] = true;
	end;
end

function undeclare( name )
	local env = getmetatable(env) or mt;
	if env.__declared then
		env.__declared[name] = nil;
	end;
end

declare 'declared'
declare 'declare'
declare 'undeclare'
declare '__declared'

setmetatable(_G, mt)