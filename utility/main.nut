
local path = "utility/"
local modules = [
	"arrays", 
	"debug", 
	"entities", 
	"enums", 
	"eventlist", 
	"events", 
	"generic", 
	"maths", 
	"normals", 
	"overrides", 
	"particles", 
	"player", 
	"tables", 
	"text", 
	"text_team", 
	"timers", 
	"weapons", 
	"hooks/main", 
	"convars", 
	"server_chat"
]

foreach( module in modules )
	cm_includeScript( path + module + ".nut" )