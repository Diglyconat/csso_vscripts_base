
////////////////////////
// BULLET IMPACT HOOK //
////////////////////////

/*
	HOW IT WORKS:
	Calls "bullet_impact" event callback function every time the "bullet_impact" game event is triggered
	
	Each time the "bullet_impact" event is triggered, the following data block is sent to event's callback function:
	eventData = {
		user, 				// usually a player/bot, who fired the weapon to trigger the bullet impact
		userWeapon, 		// the weapon, which has triggered the bullet impact
		hitPos				// bullet impact position vector ( x,y,z )
	}
*/

CSSO_AddCustomEvent( "bullet_impact" )
AddEventCallback( "bullet_impact", "CSSO_OnBulletImpact", function( params ) 
{
	local player = GetPlayerFromUserID( params.userid )
	if( !player || !player.IsValid() )
		return
	
	local wpn = player.GetActiveWeapon()
	if( !wpn || !wpn.IsValid() )
		return
	
	local eventData = {
		user = player, 
		userWeapon = wpn, 
		hitPos = Vector( params.x, params.y, params.z )
	}
	
	CSSO_TriggerGameEvent( "bullet_impact", eventData )
} )
