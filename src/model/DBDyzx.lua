--===========================================================================--
--  Dependencies
--===========================================================================--
local DyzkData		= require 'src.model.DyzkData'
local SlaXML 		= require 'src.lib.slaxml.slaxml'



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class DBDyzx: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local DBDyzkEntry = {}
DBDyzkEntry.__index = setmetatable( DBDyzkEntry, DyzkData );


-------------------------------------------------------------------------------
--  DBDyzkEntry:new : Creates a new dyzk database
-------------------------------------------------------------------------------
function DBDyzkEntry:new()
	local obj = {}
	
	return setmetatable(obj, self);
end



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class DBDyzx: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local DBDyzx = {}
DBDyzx.__index = DBDyzx;


-------------------------------------------------------------------------------
--  DBDyzx:new : Creates a new dyzk database
-------------------------------------------------------------------------------
function DBDyzx:new()
	local obj = {}
	
	obj.signature	= "LOC"
	obj.entries 	= {};
	obj.numEntries 	= 0;
	obj.fileName	= "DBDyzx.xml"
	obj.filePath	= "./";

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  DBDyzx:SetSignature : Sets the signature of the database
-------------------------------------------------------------------------------
function DBDyzx:SetSignature( sign )
	self.signature = sign
end


-------------------------------------------------------------------------------
--  DBDyzx:GetSignature : Returns the signature of the database
-------------------------------------------------------------------------------
function DBDyzx:SetSignature()
	return self.signature;
end


-------------------------------------------------------------------------------
--  DBDyzx:SetFilePath : Sets the path to the database file
-------------------------------------------------------------------------------
function DBDyzx:SetFilePath( path )
	self.filePath = path;
end


-------------------------------------------------------------------------------
--  DBDyzx:GetFilePath : Returns the path to the database file
-------------------------------------------------------------------------------
function DBDyzx:GetFilePath()
	return self.filePath;
end


-------------------------------------------------------------------------------
--  DBDyzx:SetFileName : Sets the name of the database file
-------------------------------------------------------------------------------
function DBDyzx:SetFileName( name )
	self.fileName = name;
end


-------------------------------------------------------------------------------
--  DBDyzx:GetFileName : Returns the name of the database file
-------------------------------------------------------------------------------
function DBDyzx:GetFileName()
	return self.fileName;
end


-------------------------------------------------------------------------------
--  DBDyzx:AddEntry : Adds a dyzk to the database
-------------------------------------------------------------------------------
function DBDyzx:AddEntry( dyzk )
	local dyzkEntry = DBDyzkEntry:new();
	local id;
		
	if dyzk then
		id = dyzk:GetDyzkID();		
		dyzkEntry:CopyFromDyzkData( dyzk );
	end
	
	-- If the dyzk doesn't come with an ID then generate one for it
	if not id or string.len(id) == 0 then
		id = self:GenerateDyzkID();
	end	
	
	if not self.entries[ id ] then
		self.numEntries = self.numEntries + 1;
		self.entries[ self.numEntries ] = dyzkEntry;
		self.entries[ id ] = dyzkEntry;
		
		dyzkEntry:SetDyzkID( id );
		
		return dyzkEntry;
	else
		-- ERROR	
	end	
end


-------------------------------------------------------------------------------
--  DBDyzx:Entries : Enumerates all entries
-------------------------------------------------------------------------------
function DBDyzx:Entries()
	local i = 0;
	
	-- iterator
	return function()
		if i<self.numEntries then
			i =i+1;
			return self.entries[i]
		end
	end
end


-------------------------------------------------------------------------------
--  DBDyzx:GenerateDyzkID : Generates a unique identifier
-------------------------------------------------------------------------------
function DBDyzx:GenerateDyzkID()
	local IDChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local id;
	
	repeat
		-- the id starts with the database signature
		id = self.signature;
		
		-- generate 10 random characters		
		for i=1, 10 do
			local randomByte = IDChars:byte( math.random( IDChars:len() ) );
			local randomChar = string.char( randomByte );
			
			id = id .. randomChar;
		end
		
		-- see if we have a record with that id
	until not self.entries[id];
	
	return id;
end


-------------------------------------------------------------------------------
--  DBDyzx:_CreateParser : Creates an XML parser
-------------------------------------------------------------------------------
function DBDyzx:_CreateParser()
	local db = self
	local parser = {}
	
	function parser.startElement(name,nsURI)
		if not parser.dyzk then
			if name == "dyzk" then
				parser.dyzk = DBDyzkEntry:new()
				parser.element = "dyzk";
			end
		end
		
		parser.data = nil;
	end

	function parser.attribute(name,value,nsURI)
		if name == "id" then
			if parser.element == "dyzk" and parser.dyzk then
				parser.dyzk:SetDyzkID( value );
			end
		end
	end

	function parser.closeElement(name,nsURI)
		
		if parser.dyzk then
			if name == "dyzk" then
				db:AddEntry( parser.dyzk );
				parser.dyzk = nil;
			end
			
			if name == "image" then
				parser.dyzk:SetImageName( parser.data );
			end
			
			if name == "maxradius" then
				parser.dyzk:SetMaxRadius( parser.data+0 );
			end
			
			if name == "jaggedness" then
				parser.dyzk:SetJaggedness( parser.data+0 );
			end
			
			if name == "weight" then
				parser.dyzk:SetWeight( parser.data+0 );
			end
			
			if name == "balance" then
				parser.dyzk:SetBalance( parser.data+0 );
			end
			
			if name == "speed" then
				parser.dyzk:SetSpeed( parser.data+0 );
			end
			
			if name == "maxangvel" then
				parser.dyzk:SetMaxAngularVelocity( parser.data+0 );
			end
		end
	end

	function parser.text(text)
		parser.data = text;
	end

	return SlaXML:parser( parser );
end


-------------------------------------------------------------------------------
--  DBDyzx:Store : Stores the database to a file
-------------------------------------------------------------------------------
function DBDyzx:Store()
	local ok, file = pcall( io.open(self.filePath .. self.fileName, "w") );
	
	if not ok then
		return;
	end;
	
	file:write("<dyzxdb>\n");
	for i=1, self.numEntries do
		local dyzk = self.entries[i];
		
		file:write('\t<dyzk id="'..dyzk:GetDyzkID()..'">\n');
		
		file:write("\t\t<image>"
			..dyzk:GetImageName().."</image>\n");
		file:write("\t\t<maxradius>"
			..dyzk:GetMaxRadius().."</maxradius>\n");
		file:write("\t\t<jaggedness>"
			..dyzk:GetJaggedness().."</jaggedness>\n");		
		file:write("\t\t<weight>"
			..dyzk:GetWeight().."</weight>\n");
		file:write("\t\t<balance>"
			..dyzk:GetBalance().."</balance>\n");
		file:write("\t\t<speed>"
			..dyzk:GetSpeed().."</speed>\n");
		file:write("\t\t<maxangvel>"
			..dyzk:GetMaxAngularVelocity().."</maxangvel>\n");
		
		file:write("\t</dyzk>\n");
	end
	file:write("</dyzxdb>\n");

	file:close();
end


-------------------------------------------------------------------------------
--  DBDyzx:Load : Loads the database from a file
-------------------------------------------------------------------------------
function DBDyzx:Load()	
	local text;
	local ok, file = pcall( io.open(self.filePath .. self.fileName, "r") );	
	
	if ok then		
		ok, text = pcall( file:read("*all") );
	end
	
	if ok then
		self.parser = self.parser or self:_CreateParser();
		self.parser:parse( text );
	end
end





--===========================================================================--
--  Initialization
--===========================================================================--
return DBDyzx