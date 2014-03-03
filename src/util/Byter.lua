--===========================================================================--
--  Dependencies
--===========================================================================--
local floor		= math.floor
local frexp		= math.frexp
local abs		= math.abs


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Internal Constants
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local BYTE_RANGE;	-- Integer range of 1 byte


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Byter: a brief...
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Byter = {}
Byter.__index = Byter;


-------------------------------------------------------------------------------
--  Byter:new : Creates a new Byter
-------------------------------------------------------------------------------
function Byter:new()
	local obj = {}

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Byter.IntegerRange : Returns the size of s bytes
-------------------------------------------------------------------------------
function Byter.IntegerRange( s )
	local singleByte = 0x100;
	return singleByte ^ s;
end


-------------------------------------------------------------------------------
--  NumberToBytes : A helper function that turns a number into a byte sequence
-------------------------------------------------------------------------------
function Byter.UIntegerToBytes( n, b )
	if b<1 then
		return;
	end

	local n = floor(n);

	if n>0 then
		return 	n % BYTE_RANGE,	Byter.UIntegerToBytes( n/BYTE_RANGE, b-1 );
	else
		return 	0,				Byter.UIntegerToBytes( 0, b-1 );
	end
end


-------------------------------------------------------------------------------
--  Byter.IntegerToBytes : Returns the size of s bytes
-------------------------------------------------------------------------------
function Byter.IntegerToBytes( n, b )
	-- Warp around negative numbers (as if we are setting the highest bit)
	while n<0 do
		n = Byter.IntegerRange(b)+n;
	end

	return  Byter.UIntegerToBytes(n, b)
end


-------------------------------------------------------------------------------
--  Byter.IntegerToBytes : Returns the size of s bytes
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  Kudos to mniip for this.
--  http://snippets.luacode.org/snippets/IEEE_float_conversion_144
-------------------------------------------------------------------------------
function Byter.FloatToBytes( n )
	local sign = n<0 and 1 or 0
	local absN = abs(n);

	-- +/-INF
	if absN == 1/0 then
		if sign==1 then
			return 255,0,0,0;
		else
			return 127,0,0,0;
		end
	end

	-- NaN
	if n~=n then
		return 255,170,170,170;
	end

	local fr,exp = frexp(absN)
	exp=exp+64

	return		floor(exp)	% 128 + 128*sign,
				floor(fr * 2^8 ) % 256,
				floor(fr * 2^16) % 256,
				floor(fr * 2^24) % 256;
end


-------------------------------------------------------------------------------
--  Byter.IntegerToBytes : Returns the size of s bytes
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  Kudos to mniip for this.
--  http://snippets.luacode.org/snippets/IEEE_float_conversion_144
-------------------------------------------------------------------------------
function Byter.DoubleToBytes( n )
	local sign = n<0 and 1 or 0
	local absN = abs(n);

	-- +/-INF
	if absN==1/0 then
		if sign==1 then
			return 255,240,0,0,0,0,0,0;
		else
			return 127,240,0,0,0,0,0,0;
		end
	end

	-- NaN
	if n~=n then
		return 255,250,170,170,170,170,170,170;
	end

	local fr,exp = frexp( absN )
	fr	= fr*2
	exp = (exp-1)+1023

	return	floor(exp / 2^4) % 128 + 128*sign,
			floor(fr * 2^4 ) % 16 + floor(exp)%16*16,
			floor(fr * 2^12) % 256,
			floor(fr * 2^20) % 256,
			floor(fr * 2^28) % 256,
			floor(fr * 2^36) % 256,
			floor(fr * 2^44) % 256,
			floor(fr * 2^52) % 256;
end


-------------------------------------------------------------------------------
--  Byter.IntegerToBytes : Returns the size of s bytes
-------------------------------------------------------------------------------
local function _GetBytesArgs( b, ... )
	local bytes;

	if type(b) == "table" then
		bytes = b;

	elseif type(b) == "number" then
		bytes = { b, ... }

	elseif type(b) == "string" then
		bytes = {};
		for i=1, string.len(b) do
			bytes[i] = string.byte( b, i );
		end
	end

	return bytes;
end


-------------------------------------------------------------------------------
--  Byter.IntegerToBytes : Returns the size of s bytes
-------------------------------------------------------------------------------
function Byter.BytesToUInteger( ... )
	local bytes = _GetBytesArgs( ... );

	local n = 0;
	for i=#bytes, 1, -1 do
		n = n*BYTE_RANGE + bytes[i];
	end

	return n;
end


-------------------------------------------------------------------------------
--  Byter.IntegerToBytes : Returns the size of s bytes
-------------------------------------------------------------------------------
function Byter.BytesToInteger( ... )
	local bytes = _GetBytesArgs( ... );

	local n = Byter.BytesToUInteger( bytes );
	local numBytes = #bytes;

	local range = Byter.IntegerRange(numBytes);
	if n > range/2-1 then
		n = n-range;
	end

	return n;
end


-------------------------------------------------------------------------------
--  Byter.IntegerToBytes : Returns the size of s bytes
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  Kudos to mniip for this.
--  http://snippets.luacode.org/snippets/IEEE_float_conversion_144
-------------------------------------------------------------------------------
function Byter.BytesToFloat( ... )
	local bytes = _GetBytesArgs( ... );
	local fr = bytes[2]/2^8 + bytes[3]/2^16 + bytes[4]/2^24;

	local exp  = bytes[1]%128 - 64;
	local sign = floor( bytes[1]/128 );

	-- +/-INF and NaN
	if exp==63 then
		return fr==0 and (1-2*sign)/0 or 0/0;
	end

	return (1-2*sign)*fr*2^exp
end


-------------------------------------------------------------------------------
--  Byter.IntegerToBytes : Returns the size of s bytes
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  Kudos to mniip for this.
--  http://snippets.luacode.org/snippets/IEEE_float_conversion_144
-------------------------------------------------------------------------------
function Byter.BytesToDouble( ... )
	local bytes = _GetBytesArgs( ... );

	local fr =	1 +	( bytes[2]%16 ) / 2^4 +
				bytes[3] / 2^12 +
				bytes[4] / 2^20 +
				bytes[5] / 2^28 +
				bytes[6] / 2^36 +
				bytes[7] / 2^44 +
				bytes[8] / 2^52;

	local exp  = (bytes[1]%128)*16 + floor(bytes[2]/16) - 1023;
	local sign = floor( bytes[1]/128 );

	-- +/-INF and NaN
	if exp==1024 then
		return fr==1 and (1-2*sign)/0 or 0/0;
	end

	return (1-2*sign)*fr*2^exp
end


--===========================================================================--
--  Initialization
--===========================================================================--

BYTE_RANGE = Byter.IntegerRange(1);
return Byter