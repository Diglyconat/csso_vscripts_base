
/////////////////////////
// ACTION BUTTONS HOOK //
/////////////////////////

/*
	HOW IT WORKS:
	Calls "button_action" event callback function on each player action button PRESS/RELEASE
	
	Each time the "button_action" event is triggered, the following data block is sent to event's callback function:
	eventData = {
		user, 				// usually a player/bot, who triggered the action button(s)
		buttons, 			// action buttons mask (integer)
		buttonsList, 		// which action button(s) is/are triggered (returns as array, each entry is a string name)
		buttonAction, 		// it's either "button_press" or "button_release"
		buttonActionTime 	// at which server time the action button(s) was/were triggered
	}
*/

local playerButtonsCheck = function()
{
	if( !self || !self.IsValid() )
		return
	
	cm_allocateEntityScriptScope( self, { buttonsMask = 0 } )
	if( !self.IsAlive() )
	{
		buttonsMask = 0
		return
	}
	
	local buttons = self.GetButtonsPressed() | self.GetButtonsHeld()
	local changedButtons = buttonsMask ^ buttons
	local pressedButtons = changedButtons & buttons
	local releasedButtons = changedButtons & (~buttons)
	
	if( pressedButtons > 0 )
	{
		local eventData = {
			user = self, 
			buttons = pressedButtons, 
			buttonsList = cm_GetMatchingButtons( pressedButtons ), 
			buttonAction = "button_press"
			buttonActionTime = Time()
		}
		
		CSSO_TriggerGameEvent( "button_action", eventData )
	}
	
	if( releasedButtons > 0 )
	{
		local eventData = {
			user = self, 
			buttons = releasedButtons, 
			buttonsList = cm_GetMatchingButtons( releasedButtons ), 
			buttonAction = "button_release"
			buttonActionTime = Time()
		}
		
		CSSO_TriggerGameEvent( "button_action", eventData )
	}
	
	buttonsMask = buttons
}

CSSO_AddCustomEvent( "button_action", function()
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( !ply || !ply.IsValid() )
			continue
		
		cm_addThinkFuncToPlayer( ply, "playerButtonsCheck", -1, playerButtonsCheck )
	}
})