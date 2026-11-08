
/////////////////////////
// WEAPON LOADOUT HOOK //
/////////////////////////

/*
	HOW IT WORKS:
	Each time the "weapon_switch" event is triggered, the following data block is sent to event's callback function:
	eventData = {
		user, 				// usually a player/bot
		userLastWeapon, 	// weapon, which the user had used before the switch
		userWeapon, 		// weapon, to which the user has switched to
	}
	
	Each time the "weapon_loadout_change" event is triggered, the following data block is sent to event's callback function:
	eventData = {
		user, 				// usually a player/bot
		userWeapon, 		// weapon found in player/bot loadout
		userWeaponAction, 	// weapon action triggered due to player/bot loadout change ("weapon_drop", "weapon_pickup", "weapon_remove")
		userLastLoadout 	// previous player loadout before the action is triggered
	}
*/

CSSO_AddCustomEvent( "weapon_switch" )
local playerLoadoutChange = function()
{
	if( !self || !self.IsValid() )
		return
	
	cm_allocateEntityScriptScope( self, { weaponsList = [] } )
	local currentWpnList = cm_getPlayerWeapons( self )
	foreach( oldWeapon in weaponsList )
	{
		if( !cm_inArray( oldWeapon, currentWpnList ) )
		{
			if( !oldWeapon || !oldWeapon.IsValid() )
				continue
			
			local eventData = {
				user = self, 
				userWeapon = oldWeapon, 
				userWeaponAction = "weapon_drop", 
				userLastLoadout = weaponsList
			}
			
			CSSO_TriggerGameEvent( "weapon_loadout_change", eventData )
			cm_removeFromArray( oldWeapon, weaponsList )
		}
	}
}

CSSO_AddCustomEvent( "weapon_loadout_change", function()
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( !ply || !ply.IsValid() )
			continue
		
		cm_addThinkFuncToPlayer( ply, "playerLoadoutChange", -1, playerLoadoutChange )
	}
})

AddEventCallback( "item_equip", "CSSO_OnItemEquip", function( params )
{
	local player = GetPlayerFromUserID( params.userid )
	if( !player || !player.IsValid() )
		return
	
	local eventData = {
		user = player, 
		userLastWeapon = NetProps.GetPropEntity( player, "m_hLastWeapon" ), 
		userWeapon = player.GetActiveWeapon()
	}
	
	CSSO_TriggerGameEvent( "weapon_switch", eventData )
})

// the "weaponsList" is now a dict instead of array to properly track removed weapon classes!
AddEventCallback( "item_pickup", "CSSO_OnItemPickup", function( params ) 
{
	local player = GetPlayerFromUserID( params.userid )
	if( !player || !player.IsValid() )
		return
	
	local scope = cm_allocateEntityScriptScope( player, { weaponsList = [] } )
	local itemName = "weapon_" + params.item
	local item = cm_getPlayerWeaponByName( player, itemName )
	if( !item || !item.IsValid() )
		return
	
	SetEntityDestroyCallback( item, function( wpn = item, wpnClass = itemName, wpnList = scope.weaponsList, itemOwner = player )
		{
			foreach( wpnItem in wpnList )
			{
				if( !wpnItem || !wpnItem.IsValid() )
					cm_removeFromArray( wpnItem, wpnList )
			}
			
			local eventData = {
				user = itemOwner, 
				userWeapon = wpn, 
				userWeaponClass = wpnClass, 
				userWeaponAction = "weapon_remove", 
				userLastLoadout = wpnList
			}
			
			CSSO_TriggerGameEvent( "weapon_loadout_change", eventData )
		} )
	
	local eventData = {
		user = player, 
		userWeapon = item, 
		userWeaponAction = "weapon_pickup", 
		userLastLoadout = scope.weaponsList
	}
	
	CSSO_TriggerGameEvent( "weapon_loadout_change", eventData )
	scope.weaponsList.append( item )
})

AddEventCallback( "player_death", "CSSO_OnPlayerDeath", function( params ) 
{
	local player = GetPlayerFromUserID( params.userid )
	if( !player || !player.IsValid() )
		return
	
	local scope = cm_allocateEntityScriptScope( player, { weaponsList = [] } )
	if( scope.weaponsList.len() > 0 )
	{
		local eventData = {
			user = player, 
			userWeapon = null, 
			userWeaponAction = "weapon_clear_death"
			userLastLoadout = scope.weaponsList
		}
		
		CSSO_TriggerGameEvent( "weapon_loadout_change", eventData )
	}
	
	scope.weaponsList = []
})
