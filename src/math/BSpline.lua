--===========================================================================--
--  Dependencies
--===========================================================================--
local MathUtils			= require 'src.math.MathUtils'

local floor				= math.floor
local ceil				= math.ceil
local clamp				= MathUtils.Clamp



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class TablePointData1D : Point data from 1D table
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local TablePointData1D = {}
TablePointData1D.__index = TablePointData1D;


-------------------------------------------------------------------------------
--  TablePointData1D:new : Creates a new TablePointData1D
-------------------------------------------------------------------------------
function TablePointData1D:new( tab )
	local obj = {}

	obj.table		= tab;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  TablePointData1D:GetDimension : Returns the dimension of the data
-------------------------------------------------------------------------------
function TablePointData1D:GetDimension()
	return 1;
end


-------------------------------------------------------------------------------
--  TablePointData1D:GetLimits : Returns the min and max of the array
-------------------------------------------------------------------------------
function TablePointData1D:GetLimits()
	return 1, #self.table;
end


-------------------------------------------------------------------------------
--  TablePointData1D:GetPoint : Returns point with the given index
-------------------------------------------------------------------------------
function TablePointData1D:GetPoint( idx )
	return self.table[idx];
end



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class TablePointData2D : Point data from 2D table
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local TablePointData2D = {}
TablePointData2D.__index = TablePointData2D;


-------------------------------------------------------------------------------
--  TablePointData2D:new : Creates a new TablePointData2D
-------------------------------------------------------------------------------
function TablePointData2D:new( tab )
	local obj = {}

	obj.table		= tab;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  TablePointData2D:GetDimension : Returns the dimension of the data
-------------------------------------------------------------------------------
function TablePointData2D:GetDimension()
	return 2;
end


-------------------------------------------------------------------------------
--  TablePointData2D:GetLimits : Returns the min and max of the array
-------------------------------------------------------------------------------
function TablePointData2D:GetLimits( u )
	if u then
		return 1, #self.table[u];
	else
		return 1, #self.table;
	end
end


-------------------------------------------------------------------------------
--  TablePointData2D:GetPoint : Returns point with the given index
-------------------------------------------------------------------------------
function TablePointData2D:GetPoint( u, v )
	return self.table[u][v];
end




--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class BSpline : A mathematical b-spline interpolator class
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local BSpline = {}
BSpline.__index = BSpline;



-------------------------------------------------------------------------------
--  BSpline:new : Creates a new BSpline
-------------------------------------------------------------------------------
function BSpline:new()
	local obj = {}
	
	self.level		= 2;
	obj.knots		= self.UNIFORM_KNOT_VECTOR;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  BSpline:SetLevel : Sets the curve level (2 is linear, 3 is cubic, etc...)
-------------------------------------------------------------------------------
function BSpline:SetLevel( level )
	self.level = level;
end


-------------------------------------------------------------------------------
--  BSpline:GetLevel : Returns the level of the curve
-------------------------------------------------------------------------------
function BSpline:GetLevel()
	return self.level;
end


-------------------------------------------------------------------------------
--  BSpline:new  Creates a new BSpline
-------------------------------------------------------------------------------
function BSpline:Interpolate( d, i, u )
	local t = self.knots;

	if d==1 then
		if u >= t(i) and u < t(i+1) then
			return 1;
		else
			return 0;
		end
	else
		local w1 = (  u-t(i)  ) / ( t(i+d-1)-t(i) );
		local w2 = ( t(i+d)-u )	/ ( t(i+d)-t(i+1) );

		return	w1 * self:Interpolate(d-1,i  , u) +
				w2 * self:Interpolate(d-1,i+1, u );
	end
end


-------------------------------------------------------------------------------
--  BSpline:SetPoints : Sets the point data for 
-------------------------------------------------------------------------------
function BSpline:SetPoints( points, dimension )
	self._points = nil;
	
	if 	type(points) == "table" and 
		points.GetPoint and 
		points.GetDimension 
	then
		self._points = points;
		self._pointDimension = points:GetDimension();
	elseif type(points) == "table" then
		local dimension = dimension or 1;
		
		if dimension==1 then
			self._points = TablePointData1D:new(points);
		elseif dimension==2 then
			self._points = TablePointData2D:new(points);
		end
	else
		error( "Unsupported type of point data - " .. type(points) );
	end
end


-------------------------------------------------------------------------------
--  BSpline:new : Creates a new BSpline
-------------------------------------------------------------------------------
function BSpline:_GetRawPoint( u, v )
	-- implements clamp warp type... repeat and blank can be done too 
	local points = self._points
	if points then
		local u,v = u,v;
		
		if points:GetDimension()>=1 then
			local low, high = points:GetLimits();
			u = clamp(u, low, high);
		end
		
		if points:GetDimension()>=2 then
			local low, high = points:GetLimits(u);
			v = clamp(v, low, high);
		end
		
		return points:GetPoint(u,v);
	end
end


-------------------------------------------------------------------------------
--  BSpline:GetPoint : Returns an interpolated point based on the data
-------------------------------------------------------------------------------
function BSpline:GetPoint( ... )
	local dimension = self._points:GetDimension();
	
	if dimension==1 then
		return self:_GetPoint1D(...);
	else
		return self:_GetPoint2D(...);
	end
end


-------------------------------------------------------------------------------
--  BSpline:new : Creates a new BSpline
-------------------------------------------------------------------------------
function BSpline:_GetPoint1D( t )
	local d 	= self.level+1;
	local low	= ceil(-d/2);
	local high	= floor(d/2+0.5);	
	
	-- Initiate our weighted sum of points to 0 (type independence hack)
	local point 	= self:_GetRawPoint(1)*0;
	
	for offset = low, high do
		local pointIdx	= floor(t+offset);
		local knotIdx 	= pointIdx - d/2;
			  
		local tempPoint	= self:_GetRawPoint( pointIdx );
		local weight 	= self:Interpolate( d, knotIdx, t )
		
		point = point + tempPoint*weight;
	end
	
	return point;
end


-------------------------------------------------------------------------------
--  BSpline:GetPoint2D : Creates a new BSpline
-------------------------------------------------------------------------------
function BSpline:_GetPoint2D( u, v )
	local d 	= self.level+1;
	local low	= ceil(-d/2);
	local high	= floor(d/2+0.5);	
	
	-- Initiate our weighted sum of points to 0 (type independence hack)
	local point 	= self:_GetRawPoint(1,1)*0;
	
	for offU = low, high do
		local pointU	= floor(u+offU);
		local knotU 	= pointU - d/2;
		
		local weightU 	= self:Interpolate( d, knotU, u );
		
		for offV = low, high do
			local pointV	= floor(v+offV);
			local knotV 	= pointV - d/2;
			  
			local weightV 	= self:Interpolate( d, knotV, v );
			
			local tempPoint	= self:_GetRawPoint( pointU, pointV );		
			point = point + (tempPoint * weightU*weightV);
		end
	end
	
	return point;
end


-------------------------------------------------------------------------------
--  UNIFORM_KNOT_VECTOR
-------------------------------------------------------------------------------
function BSpline.UNIFORM_KNOT_VECTOR(i)
	return i
end



--===========================================================================--
--  Initialization
--===========================================================================--
return BSpline;