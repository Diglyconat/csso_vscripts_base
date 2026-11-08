
//////////////////
// HOSTAGE HOOK //
//////////////////

/*
	HOW IT WORKS:
	1) Calls "hostage_drop_cancel" event callback function every time player cancels dropping hostage
	2) Calls "hostage_drop_start" event callback function every time player begins dropping hostage
	3) Calls "hostage_drop" event callback function when player successfully drops the hostage
	
	Each time either of those events are triggered, the following data block is sent to event's callback function:
	eventData = {
		user, 				// usually a player/bot, who interacts with hostage
		userHostage 		// hostage entity (can be null!)
	}
*/

local playerHostageDropThink = function()
{
	if( !self || !self.IsValid() )
		return
	
	cm_allocateEntityScriptScope( self, { hostageIsBeingDropped = false } )
	local isDroppingHostage = NetProps.GetPropBool( self, "m_bIsDroppingHostage" )
	if( hostageIsBeingDropped != isDroppingHostage )
	{
		local hostageDropTarget = NetProps.GetPropEntity( self, "m_hCarriedHostage" )
		local eventData = {
			user = self
			userHostage = hostageDropTarget
		}
		
		local eventName = "hostage_drop"
		if( !hostageIsBeingDropped && isDroppingHostage )
			eventName = "hostage_drop_start"
		else if( hostageDropTarget && hostageDropTarget.IsValid() )
			eventName = "hostage_drop_cancel"
		
		CSSO_TriggerGameEvent( eventName, eventData )
	}
	
	hostageIsBeingDropped = isDroppingHostage
}

CSSO_AddCustomEvent( "hostage_drop_cancel" )
CSSO_AddCustomEvent( "hostage_drop_start" )
CSSO_AddCustomEvent( "hostage_drop", function()
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( !ply || !ply.IsValid() )
			continue
		
		cm_addThinkFuncToPlayer( ply, "playerHostageDropThink", -1, playerHostageDropThink )
	}
})
