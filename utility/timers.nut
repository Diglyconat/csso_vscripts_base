
////////////
// TIMERS //
////////////

::cm_createTimer <- function( timerName, refireTime, autoStart, timerFunc )
{
	local cmTimer = fbtn( timerName )
	if( cmTimer )
		return cmTimer
	
	cmTimer = Entities.CreateByClassname( "logic_timer" )
	cmTimer.__KeyValueFromString( "targetname", timerName )
	cmTimer.__KeyValueFromString( "classname", "move_rope" )
	cmTimer.__KeyValueFromFloat( "refiretime", refireTime )
	
	cmTimer.ValidateScriptScope()
	local timerScope = cmTimer.GetScriptScope()
	if( !timerScope.rawin( "timerFunc" ) )
		timerScope.timerFunc <- timerFunc
	
	EntFireByHandle( cmTimer, "AddOutput", "OnTimer self:RunScriptCode:timerFunc():0:-1", 0, null, null )
	if( autoStart == true )
		EntFireByHandle( cmTimer, "Enable", "", 0, null, null )
	
	return cmTimer
}

// unlike "cm_createTimer", this function actually removes the existing thinker and adds a new one
// easily overrides "thinkfunction" thanks to that
::cm_createThinker <- function( thinkerName, callback )
{
	local thinker = fbtn( thinkerName )
	if( thinker )
		thinker.Destroy()
	
	local thinker = Entities.CreateByClassname( "info_target" )
	thinker.__KeyValueFromString( "targetname", thinkerName )
	thinker.ValidateScriptScope()
	local thinkerScope = thinker.GetScriptScope()
	thinkerScope.thinkFunc <- callback
	
	Entities.DispatchSpawn( thinker )
	AddThinkToEnt( thinker, "thinkFunc" )
	return thinker
}

// duct-tape to dynamically update thinkfunction of specified entity
::cm_updateThinkFunc <- function( target, thinkFunc )
{
	AddThinkToEnt( target, "null" )
	AddThinkToEnt( target, "" + thinkFunc )
}