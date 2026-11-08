
///////////////////////
// GENERIC FUNCTIONS //
///////////////////////

// adds a custom chat command which calls a function that accepts 2 arguments: the player triggering chat command and value coming after the chat command name
// if "cmdDesc" is specified and is not null, the chat command will be added to the list of commands displayed in chat on every player respawn with the specified description
::AddChatCommand <- function( cmdName, cmdFunc, cmdDesc = null ){ CSSO_ChatCommands[ cmdName ] <- { callback = cmdFunc, desc = cmdDesc } }

// separate function for adding chat command description
::AddChatCmdDesc <- function( cmdName, cmdDesc )
{
	if( !( cmdName in CSSO_ChatCommands ) )
		return
	
	CSSO_ChatCommands[ cmdName ][ "desc" ] <- cmdDesc
}

// function which calls a specified "func" function to be called after specified "delay" (MUST be second parameter of the "CallFuncDelayed" function!)
::CallFuncDelayed <- function( func, ... )
{
	if( vargv.len() < 2 || ( typeof( vargv[ 0 ] ) != "float" && typeof( vargv[ 0 ] ) != "integer" ) || typeof( vargv[ 1 ] ) != "integer" )
		return false
	
	local func_counter = 0
	local func_counterMax = vargv[ 1 ]
	cm_removeFromArray( vargv[ 1 ], vargv )
	local func_name = UniqueString()
	csso_worldspawn_scope[ func_name ] <- function[ this ]()
	{
		func_counter++
		if( func_counter >= func_counterMax )
			delete csso_worldspawn_scope[ func_name ]
		
		func.acall( vargv )
	}
	
	for( local i = 0; i < func_counterMax; i++ )
		EntFireByHandle( csso_worldspawn, "CallScriptFunction", func_name, vargv[ 0 ] * ( i + 1 ) )
	
	return true
}

// return Frame Rate based on FrameTime() value
::FrameRate <- function(){ return 1.0/FrameTime() }

// check if entity is on ground
::cm_isEntityOnGround <- function( target )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() )
		return false
	
	// FL_ONGROUND == 1
	return ( target.GetFlags() & FL_ONGROUND ) == FL_ONGROUND
}

// call server command
::cm_serverCMD <- function( command, delay = -1 )
{
	if( delay < 0.0 )
		cm_server.AcceptInput( "Command", command, null, null )
	else
		EntFireByHandle( cm_server, "Command", command, delay, null, null )
}

// call client command on certain client
::cm_clientCMD <- function( command, target, delay = -1 )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() )
		return
	
	if( delay < 0.0 )
		cm_client.AcceptInput( "Command", command, target, target )
	else
		EntFireByHandle( cm_client, "Command", command, delay, target, target )
}

// find first matching entity by classname
::fbcn <- function( cn ){ return Entities.FindByClassname( null, cn ) }

// find first matching entity by targetname
::fbtn <- function( tn ){ return Entities.FindByName( null, tn ) }

// get first matching player
::gpf <- function(){ return PlayerInstanceFromIndex(1) }

// returns an array of alive entities (if ent.IsAlive() == true, entity gets added in the array)
::cm_getAliveEntities <- function( team = 0, entity_classes = null )
{
	if( entity_classes == null )
		return [null]
	
	local foundEnts = []
	foreach( c in entity_classes )
	{
		local ent = null
		while( ent = Entities.FindByClassname( ent, c ) )
		{
			if( ( team == 0 || ent.GetTeam() == team ) && ent.IsAlive() )
				foundEnts.append( ent )
		}
	}
	
	return foundEnts	
}

// invincibility for entities via "filter_damage_type"
// fake god mode
::cm_NoDMGFilter <- fbtn( "cm_NoDMGFilter" )
if( !cm_NoDMGFilter )
{
	cm_NoDMGFilter = Entities.CreateByClassname( "filter_damage_type" )
	cm_NoDMGFilter.__KeyValueFromString( "targetname", "cm_NoDMGFilter" )
	cm_NoDMGFilter.__KeyValueFromString( "classname", "move_rope" )
	cm_NoDMGFilter.__KeyValueFromInt( "negated", 1 )
}

/////////////////////////////////////
// PLAYER ACTION BUTTONS FUNCTIONS //
/////////////////////////////////////

// has player (second parameter) PRESSED the button of specified action (first parameter) at current frame?
// returns true, if bit mask of specified action button matches itself; returns false otherwise
::cm_isButtonPressed <- function( actionName, target )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() || !( actionName in csso_buttons ) )
		return false
	
	local iButtonValue = csso_buttons[ actionName ]
	return ( target.GetButtonsPressed() & iButtonValue ) == iButtonValue
}

// has player (second parameter) RELEASED the button of specified action (first parameter) at current frame?
// returns true, if bit mask of specified action button matches itself; returns false otherwise
::cm_isButtonReleased <- function( actionName, target )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() || !( actionName in csso_buttons ) )
		return false
	
	local iButtonValue = csso_buttons[ actionName ]
	return ( target.GetButtonsReleased() & iButtonValue ) == iButtonValue
}

// is player (second parameter) HOLDING the button of specified action (first parameter)?
// returns true, if bit mask of specified action button matches itself; returns false otherwise
::cm_isButtonHeld <- function( actionName, target )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() || !( actionName in csso_buttons ) )
		return false
	
	local iButtonValue = csso_buttons[ actionName ]
	return ( target.GetButtonsHeld() & iButtonValue ) == iButtonValue
}

// is player (second parameter) HOLDING the button (OR HAS PLAYER PRESSED IT) of specified action (first parameter)?
// returns true, if bit mask of specified action button matches itself; returns false otherwise
::cm_isButtonPressedOrHeld <- function( actionName, target )
{
	return ( cm_isButtonPressed( actionName, target ) || cm_isButtonHeld( actionName, target ) )
}

// returns array with action buttons based on buttons int mask
::cm_GetMatchingButton <- function( buttonMask )
{
	foreach( sActionName,iButtonValue in csso_buttons )
	{
		if( (buttonMask & iButtonValue) )
			return sActionName
	}
	
	return null
}

// returns array with action buttons based on buttons int mask
::cm_GetMatchingButtons <- function( buttonMask )
{
	local matchList = []
	foreach( sActionName,iButtonValue in csso_buttons )
	{
		if( !(buttonMask & iButtonValue) )
			continue
		
		matchList.append( sActionName )
	}
	
	return matchList
}

// returns list of PRESSED buttons of specified player
::cm_GetButtonsPressed <- function( target, showList = false )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	local buttonsList = []
	if( !target || !target.IsValid() )
		return buttonsList
	
	buttonsList = cm_GetMatchingButtons( target.GetButtonsPressed() )
	if( showList == false )
		return buttonsList
	
	if( buttonsList.len() > 0 )
	{
		printl( cm_getPlayerName( target ), "pressed buttons:" )
		foreach( actionButton in buttonsList )
			printl( "	" + actionButton )
	}
	
	return buttonsList
}

// returns list of RELEASED buttons of specified player
::cm_GetButtonsReleased <- function( target, showList = false )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	local buttonsList = []
	if( !target || !target.IsValid() )
		return buttonsList
	
	buttonsList = cm_GetMatchingButtons( target.GetButtonsReleased() )
	if( showList == false )
		return buttonsList
	
	if( buttonsList.len() > 0 )
	{
		printl( cm_getPlayerName( target ), "pressed buttons:" )
		foreach( actionButton in buttonsList )
			printl( "	" + actionButton )
	}
	
	return buttonsList
}

// returns list of HELD buttons of specified player
::cm_GetButtonsHeld <- function( target, showList = false )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	local buttonsList = []
	if( !target || !target.IsValid() )
		return buttonsList
	
	buttonsList = cm_GetMatchingButtons( target.GetButtonsHeld() )
	if( showList == false )
		return buttonsList
	
	if( buttonsList.len() > 0 )
	{
		printl( cm_getPlayerName( target ), "pressed buttons:" )
		foreach( actionButton in buttonsList )
			printl( "	" + actionButton )
	}
	
	return buttonsList
}

// returns list of PRESSED and/or HELD buttons of specified player
::cm_GetButtonsPressedOrHeld <- function( target, showList = false )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	local buttonsList = []
	if( !target || !target.IsValid() )
		return buttonsList
	
	buttonsList = cm_addArray( cm_GetMatchingButtons( target.GetButtonsPressed() ), cm_GetMatchingButtons( target.GetButtonsHeld() ) )
	if( showList == false )
		return buttonsList
	
	if( buttonsList.len() > 0 )
	{
		printl( cm_getPlayerName( target ), "pressed/held buttons:" )
		foreach( actionButton in buttonsList )
			printl( "	" + actionButton )
	}
	
	return buttonsList
}

// forces the specified action button name to be enabled for specified player
::cm_EnableButton <- function( actionName, target )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() || !( actionName in csso_buttons ) )
		return
	
	local iButtonValue = csso_buttons[ actionName ]
	target.ForceButtons( iButtonValue )
}

// forces the specified action button name to be disabled for specified player
::cm_DisableButton <- function( actionName, target )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() || !( actionName in csso_buttons ) )
		return
	
	local iButtonValue = csso_buttons[ actionName ]
	target.UnforceButtons( iButtonValue )
}

::cm_DelayedButtonRelease <- function( actionName )
{
	local ply = activator
	if( !ply || !ply.IsValid() || !( actionName in csso_buttons ) )
		return
	
	local iButtonValue = csso_buttons[ actionName ]
	ply.UnforceButtons( iButtonValue )
}

// forces player to have specified action button to be pressed on current frame, then released on the next frame
::cm_ForcePressButton <- function( actionName, target )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() || !( actionName in csso_buttons ) )
		return
	
	cm_EnableButton( actionName, target )
	EntFireByHandle( csso_worldspawn, "RunScriptCode", "cm_DelayedButtonRelease(\"" + actionName + "\")", 0, target )
}

// forces the specified action button name to be UNLOCKED for any time usage for specified player
::cm_UnlockButton <- function( actionName, target )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() || !( actionName in csso_buttons ) )
		return
	
	target.ValidateScriptScope()
	local scope = target.GetScriptScope()
	if( !scope.rawin( "BlockedButtons" ) )
		scope.BlockedButtons <- []
	
	local iButtonValue = csso_buttons[ actionName ]
	target.EnableButtons( iButtonValue )
	if( cm_inArray( actionName, scope.BlockedButtons ) )
		cm_removeFromArray( actionName, scope.BlockedButtons )
}

// forces the specified action button name to be LOCKED/DISABLED at all times for specified player
::cm_LockButton <- function( actionName, target )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() || !( actionName in csso_buttons ) )
		return
	
	target.ValidateScriptScope()
	local scope = target.GetScriptScope()
	if( !scope.rawin( "BlockedButtons" ) )
		scope.BlockedButtons <- []
	
	local iButtonValue = csso_buttons[ actionName ]
	target.DisableButtons( iButtonValue )
	if( !cm_inArray( actionName, scope.BlockedButtons ) )
		scope.BlockedButtons.append( actionName )
}

// checks if specified action button is locked/unlocked for specified player
::cm_isButtonUnlocked <- function( actionName, target )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() || !( actionName in csso_buttons ) )
		return
	
	target.ValidateScriptScope()
	local scope = target.GetScriptScope()
	if( !scope.rawin( "BlockedButtons" ) )
		scope.BlockedButtons <- []
	
	return !cm_inArray( actionName, scope.BlockedButtons )
}