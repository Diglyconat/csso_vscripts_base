
// a dict that stores game events callback functions
// custom game events can be added via adding a thinker with a thinkfunction callback
::CSSOEventCallbacks <- {}

// a dict that stores game events callback functions
::CSSOEventData <- {}
Convars.Create( "sv_csso_events_debug_mode", "0", 0, "Should the custom events be displayed in console every time they're triggered?", true, 0, true, 1 )
Convars.Create( "sv_csso_events_debug_filter", "", 0, "Specifies which events should be displayed in console every time they're triggered:" + 
	"\n\t- leave blank to display ALL events;\n\t- separate with \",\" to check the specified events only.", false, 0, false, 1 )
Convars.Create( "sv_csso_events_debug_filter_mode", "0", 0, "Event filter behavior:\n\t0 - default (only specified events are displayed in console);" + 
	"\n\t1 - exclude mode (specified events will NOT be displayed in console)", true, 0, true, 1 )

local path = "utility/hooks/"
::CSSO_customGameEvents <- [
	"bullet_impact", 
	"button_action", 
	"hostage_action", 
	"match_round", 
	"player_action", 
	"server_preshutdown", 
	"vscript_restart", 
	"weapon_action", 
	"weapon_switch"
]

::CSSO_DispatchGameEvent <- function( eventName )
{
	if( !( eventName in CSSOEventCallbacks ) )
		return
	
	local eventData = CSSOEventData[ eventName ]
	if( eventData == null )
	{
		foreach( func in CSSOEventCallbacks[ eventName ] )
			func()
	}
	else foreach( func in CSSOEventCallbacks[ eventName ] )
		func( eventData )
}

// UPDATE: "eventData" parameter is allowed to be null
::CSSO_TriggerGameEvent <- function( eventName, eventData = null, eventDelay = -1.0 )
{
	if( !( eventName in CSSOEventCallbacks ) )
		return
	
	CSSOEventData[ eventName ] <- eventData
	if( eventDelay < 0.0 )
		CSSO_DispatchGameEvent( eventName )
	else
		EntFireByHandle( csso_worldspawn, "RunScriptCode", "CSSO_DispatchGameEvent( \"" + eventName + "\" )", eventDelay )
	
	if( !Convars.GetBool( "sv_csso_events_debug_mode" ) )
		return
	
	local filterEventsList = []
	foreach( filterEventName in split( Convars.GetStr( "sv_csso_events_debug_filter" ), "," ) )
	{
		filterEventName = strip( filterEventName ).tolower()
		filterEventsList.append( filterEventName )
	}
	
	if( filterEventsList.len() > 0 )
	{
		local filterMode = Convars.GetBool( "sv_csso_events_debug_filter_mode" )
		local isEventPassed = cm_inArray( eventName, filterEventsList )
		isEventPassed = filterMode ? !isEventPassed : isEventPassed
		if( !isEventPassed )
			return
	}
	
	printl( "Game Event Triggered: " + eventName )
	if( eventData != null )
		PrintTableString( eventData, 2 )
	
	printl()
}

::CSSOEvent <- function( eventName, name, callback )
{
	if( !( eventName in CSSOEventCallbacks ) )
		return
	
	CSSOEventCallbacks[ eventName ][ name ] <- callback
}

::CSSO_AddCustomEvent <- function( eventName, thinkFunc = null )
{
	if( !( eventName in CSSOEventCallbacks ) )
		CSSOEventCallbacks[ eventName ] <- {}
	
	if( thinkFunc != null && typeof( thinkFunc ) == "function" )
		AddServerThink( "csso_customevent_" + eventName, -1, thinkFunc )
}

foreach( cge in CSSO_customGameEvents )
	cm_includeScript( path + cge + ".nut" )