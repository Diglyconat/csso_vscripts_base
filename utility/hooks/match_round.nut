
//////////////////////
// MATCH ROUND HOOK //
//////////////////////

/*
	HOW IT WORKS:
	Calls "new_round" event callback function on each start of new round
	Each time the "new_round" event is triggered, NO data is sent to event's callback function.
	
	Calls "end_round" event callback function every time the round ends
	Each time the "end_round" event is triggered, NO data is sent to event's callback function.
*/

CSSO_AddCustomEvent( "new_round" )
CSSO_AddCustomEvent( "end_round" )

AddEventCallback( "round_start", "CSSO_MatchRound_OnRoundStart", function( params ) 
{
	CSSO_TriggerGameEvent( "new_round" )
	foreach( _,tScope in cm_includedScripts )
	{
		if( !( "OnNewRound" in tScope ) )
			continue
		
		tScope.OnNewRound()
	}
	
	printl( "[VScripts Base] New Round!" )
})

AddEventCallback( "round_end", "CSSO_MatchRound_OnRoundEnd", function( params ){ CSSO_TriggerGameEvent( "end_round" )} )
