
////////////////////////
// FUNCTION OVERRIDES //
////////////////////////

if (!(::rawin("EntFireByHandle_obsolete")))
	::EntFireByHandle_obsolete <- EntFireByHandle

// "EntFireByHandle" function with added default values
::EntFireByHandle <- function( target, action, value = "", delay = 0, activator = null, caller = null )
{ EntFireByHandle_obsolete( target, action, value, delay, activator, caller ) }

// global "AcceptInput" function with "target" param accepting entity handle
::AcceptInput <- function( target, action, value = "", activator = null, caller = null )
{ target.AcceptInput( action, value, activator, caller ) }

// "print" functions override
if( !(::rawin("print_obsolete")) )
	::print_obsolete <- print

// print to console with multiple arguments
::print <- function(...)
{
	local str = ""
	for( local i = 0; i < vargv.len(); i++ )
	{
		str += vargv[ i ]
		if( i + 1 < vargv.len() )
			str += " "
	}
	
	print_obsolete( str )
}

if( !(::rawin("printl_obsolete")) )
	::printl_obsolete <- printl

// print to console from newline with multiple arguments
::printl <- function(...)
{
	local str = ""
	for( local i = 0; i < vargv.len(); i++ )
	{
		str += vargv[ i ]
		if( i + 1 < vargv.len() )
			str += " "
	}
	
	printl_obsolete( str )
}

// wrapper for "TraceHull" function for usage with multiple parameters instead of single table
::ScriptTraceHull <- function( traceStart, traceEnd, traceHullMin, traceHullMax, traceMask = 33579137, traceIgnoreEnts = null )
{
	local traceData = {
		start = traceStart, 
		end = traceEnd, 
		hullmin = traceHullMin, 
		hullmax = traceHullMax, 
		mask = traceMask, 
		ignore = traceIgnoreEnts
	}
	
	TraceHull( traceData )
}

////////////////////////////////////////
//       MESSAGE PRINT FUNCTIONS      //
// (re-implemented via "ClientPrint") //
////////////////////////////////////////

// prints message to specified player at specified hud part
// "target" param supports players' "userid" index (check via "status" console command!)
// "destination" param supports following values:
// 1 - HUD_PRINTNOTIFY (does nothing, but prints in console?)
// 2 - HUD_PRINTCONSOLE (prints in console)
// 3 - HUD_PRINTTALK (print in chat)
// 4 - HUD_PRINTCENTER (print at center of the screen)
// "param1", "param2", "param3", "param4" - used for parsing formatted text
::ScriptPrintMessage <- function( target, destination, text, param1 = "", param2 = "", param3 = "", param4 = "" )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() )
		return
	
	if( destination == 3 )
		EmitSoundOnClient( "HudChat.Message", target )
	
	ClientPrint( target, destination, text, param1, param2, param3, param4 )
}

// prints message to everyone at specified hud part
::ScriptPrintMessageAll <- function( destination, text, param1 = "", param2 = "", param3 = "", param4 = "" )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( !ply || !ply.IsValid() )
			continue
		
		if( destination == 3 )
			EmitSoundOnClient( "HudChat.Message", ply )
		
		ClientPrint( ply, destination, text, param1, param2, param3, param4 )
	}
}

// prints message to specified team at specified hud part
::ScriptPrintMessageTeam <- function( team, destination, text, param1 = "", param2 = "", param3 = "", param4 = "" )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( !ply || !ply.IsValid() || ply.GetTeam() != team )
			continue
		
		if( destination == 3 )
			EmitSoundOnClient( "HudChat.Message", ply )
		
		ClientPrint( ply, destination, text, param1, param2, param3, param4 )
	}
}

// legacy functions support for older scripts
// prints message to everyone in the chat
::ScriptPrintMessageChatAll <- function( text, param1 = "", param2 = "", param3 = "", param4 = "" )
{ ScriptPrintMessageAll( 3, text, param1, param2, param3, param4 ) }

// prints message to specified team in the chat
::ScriptPrintMessageChatTeam <- function( team, text, param1 = "", param2 = "", param3 = "", param4 = "" )
{ ScriptPrintMessageTeam( team, 3, text, param1, param2, param3, param4 ) }

// prints message to everyone in the center of the screen
::ScriptPrintMessageCenterAll <- function( text, param1 = "", param2 = "", param3 = "", param4 = "" )
{ ScriptPrintMessageAll( 4, text, param1, param2, param3, param4 ) }

// prints message to specified team in the center of the screen
::ScriptPrintMessageCenterTeam <- function( team, text, param1 = "", param2 = "", param3 = "", param4 = "" )
{ ScriptPrintMessageTeam( team, 4, text, param1, param2, param3, param4 ) }

///////////////////////////////
// SCRIPT SCOPE DUMP WRAPPER //
///////////////////////////////

::DumpScope <- function( table ){ __DumpScope( 0, table ) }