
//////////////////////////
// VSCRIPT RESTART HOOK //
//////////////////////////

/*
	HOW IT WORKS:
	Each time the "vscript_restart" event is triggered, NO data is sent to event's callback function.
	Re-initializes entities script scopes if they have custom thinkfuncs set.
*/

CSSO_AddCustomEvent( "vscript_restart" )
if( !( ::rawin( "VScriptInit" ) ) )
	::VScriptInit <- true
else
	CSSO_TriggerGameEvent( "vscript_restart" )