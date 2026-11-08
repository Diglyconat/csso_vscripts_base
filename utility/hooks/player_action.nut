
////////////////////////
// PLAYER ACTION HOOK //
////////////////////////

/*
	HOW IT WORKS:
	1) Calls "player_respawn" event callback function on each player respawn
	(player/bot respawn)
	
	2) Calls "player_jump" event callback function on each player jump
	(player/bot jump)
	
	3) Calls "player_fall" event callback function every time player lifts off the ground without jumping
	(player/bot falling)
	
	4) Calls "armor_change" event callback function on every armor value change
	5) Calls "ladder_interact" event callback function on every player interaction with ladders (mount/dismount ladder)
	6) Calls "hand_change" event callback function on every player hand change (enable/disable left hand and/or switching non-dominant hand on/off)
	
	Each time the "player_respawn" event is triggered, the following data block is sent to event's callback function:
	eventData = {
		user, 				// usually a player/bot, who respawned
		respawnTime 		// time of user's respawn (in seconds + milliseconds, server's runtime duration)
	}
	
	Each time the "player_jump" event is triggered, the following data block is sent to event's callback function:
	eventData = {
		user, 				// usually a player/bot, who jumped
		userPressedJump, 	// did the user trigger the "+jump" action before jumping? (true/false)
		userHeldJump, 		// did the user hold the "+jump" action button before jumping? (true/false)
		userLastGrounded, 	// was the player on ground before jumping? (true/false)
		jumpTime 			// time of user's last jump action trigger (in seconds + milliseconds, server's runtime duration)
	}
	
	Each time the "player_fall" event is triggered, the following data block is sent to event's callback function:
	eventData = {
		user, 				// usually a player/bot, who fell off
		fallTime 			// time of user's last falling (in seconds + milliseconds, server's runtime duration)
	}
	
	Each time the "armor_change" event is triggered, the following data block is sent to event's callback function:
	eventData = {
		user, 				// usually a player/bot
		lastArmor, 			// previous armor value count
		newArmor, 			// current armor value count
		lastHelmet, 		// did player/bot have helmet during armor value change? (true/false)
		hasHelmet 			// does player/bot have helmet during armor value change? (true/false)
	}
	
	Each time the "ladder_interact" event is triggered, the following data block is sent to event's callback function:
	eventData = {
		user, 				// usually a player/bot, who interacted with ladder
		userLastLadder, 	// was player/bot previously on ladder? (true/false)
		userIsOnLadder, 	// is player/bot currently on ladder? (true/false)
		userLadderTime 		// time of user's last ladder interaction (in seconds + milliseconds, server's runtime duration)
	}
	
	Each time the "hand_change" event is triggered, the following data block is sent to event's callback function:
	eventData = {
		user, 				// usually a player/bot, who has triggered hand change
		userLastLeftHand, 	// was player/bot using left hand previously? (true/false)
		userLeftHand, 		// is player/bot currently using left hand? (true/false)
		userLastHandHidden, // was player/bot having left hand hidden previously? (true/false)
		userHandHidden 		// is player/bot currently having left hand hidden? (true/false)
	}
*/

// register player's "userid" value upon activating
CSSO_AddCustomEvent( "player_respawn" )
AddEventCallback( "player_activate", "CSSO_PlayerAction_OnPlayerActivate", function( params )
{
	local player = GetPlayerFromUserID( params.userid )
	if( !player || !player.IsValid() )
		return
	
	cm_allocateEntityScriptScope( player, { userid = params.userid } )
})

AddEventCallback( "player_spawn", "CSSO_PlayerAction_OnPlayerRespawn", function( params ) 
{
	local player = GetPlayerFromUserID( params.userid )
	if( !player || !player.IsValid() )
		return
	
	local scope = cm_allocateEntityScriptScope( player, { lastAccount = 0 } )
	if( player.GetTeam() == TEAM_UNASSIGNED )
		SendGlobalGameEvent( "player_activate", { userid = params.userid })
	else
		scope.lastAccount = player.GetAccount()
	
	local eventData = {
		user = player, 
		respawnTime = Time()
	}
	
	CSSO_TriggerGameEvent( "player_respawn", eventData )
})

CSSO_AddCustomEvent( "player_fall" )
local playerJumpBeforeLanding = function()
{
	if( !self || !self.IsValid() )
		return
	
	local isPlayerGrounded = cm_isPlayerOnGround( self )
	cm_allocateEntityScriptScope( self, { previousGround = isPlayerGrounded } )
	if( !self.IsAlive() || self.IsNoclipping() )
	{
		previousGround = isPlayerGrounded
		return
	}
	
	local pressedButtons = self.GetButtonsPressed()
	local heldButtons = self.GetButtonsHeld()
	if( previousGround == false && isPlayerGrounded == true )
	{
		local eventData = {
			user = self, 
			userPressedJump = ( pressedButtons & IN_JUMP ) == IN_JUMP, 
			userHeldJump = ( heldButtons & IN_JUMP ) == IN_JUMP, 
			userLastGrounded = false, 
			jumpTime = Time()
		}
		
		CSSO_TriggerGameEvent( "player_jump", eventData )
	}
	
	if( previousGround == true && isPlayerGrounded == false && !( ((pressedButtons | heldButtons) & IN_JUMP) == IN_JUMP ) && !cm_isPlayerOnLadder( self ) )
	{
		local eventData = {
			user = self, 
			fallTime = Time()
		}
		
		CSSO_TriggerGameEvent( "player_fall", eventData )
	}
	
	previousGround = isPlayerGrounded
}

// extension for "player_jump" event, triggered on each landing (player was in air -> player is on ground)
CSSO_AddCustomEvent( "player_jump", function()
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( !ply || !ply.IsValid() )
			continue
		
		cm_addThinkFuncToPlayer( ply, "playerJumpBeforeLanding", -1, playerJumpBeforeLanding )
	}
})

AddEventCallback( "player_jump", "CSSO_PlayerAction_OnPlayerJump", function( params ) 
{
	local player = GetPlayerFromUserID( params.userid )
	if( !player || !player.IsValid() || !player.IsAlive() )
		return
	
	local scope = cm_allocateEntityScriptScope( player, { previousGround = true } )
	local eventData = {
		user = player, 
		userPressedJump = ( player.GetButtonsPressed() & IN_JUMP ) == IN_JUMP, 
		userHeldJump = ( player.GetButtonsHeld() & IN_JUMP ) == IN_JUMP, 
		userLastGrounded = true, 
		jumpTime = Time()
	}
	
	CSSO_TriggerGameEvent( "player_jump", eventData )
	scope.previousGround = true
})

local playerArmorChange = function()
{
	if( !self || !self.IsValid() )
		return
	
	cm_allocateEntityScriptScope( self, { previousHelmet = self.HasHelmet(), previousArmor = self.ArmorValue() } )
	if( !self.IsAlive() )
	{
		previousArmor = 0
		previousHelmet = false
		return
	}
	
	local newArmor = self.ArmorValue()
	local newHelmet = self.HasHelmet()
	if( previousArmor != newArmor || previousHelmet != newHelmet )
	{
		local eventData = {
			user = self, 
			lastArmor = previousArmor, 
			newArmor = newArmor, 
			lastHelmet = previousArmor, 
			hasHelmet = newHelmet
		}
		
		CSSO_TriggerGameEvent( "armor_change", eventData )
	}
	
	previousArmor = newArmor
	previousHelmet = newHelmet
}

CSSO_AddCustomEvent( "armor_change", function()
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( !ply || !ply.IsValid() )
			continue
		
		cm_addThinkFuncToPlayer( ply, "playerArmorChange", -1, playerArmorChange )
	}
})

local playerLadderInteract = function()
{
	if( !self || !self.IsValid() )
		return
	
	cm_allocateEntityScriptScope( self, { previousLadder = false } )
	if( !self.IsAlive() || self.IsNoclipping() )
	{
		previousLadder = false
		return
	}
	
	local isPlayerOnLadder = cm_isPlayerOnLadder( self )
	if( previousLadder != isPlayerOnLadder )
	{
		local eventData = {
			user = self, 
			userLastLadder = previousLadder, 
			userIsOnLadder = isPlayerOnLadder, 
			userLadderTime = Time()
		}
		
		CSSO_TriggerGameEvent( "ladder_interact", eventData )
	}
	
	previousLadder = isPlayerOnLadder
}

CSSO_AddCustomEvent( "ladder_interact", function()
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( !ply || !ply.IsValid() )
			continue
		
		cm_addThinkFuncToPlayer( ply, "playerLadderInteract", -1, playerLadderInteract )
	}
})

local playerHandChangeThink = function()
{
	if( !self || !self.IsValid() )
		return
	
	local curWeapon = self.GetActiveWeapon()
	cm_allocateEntityScriptScope( self, { previousLeftHand = false, previousHideHand = false, previousWeapon = curWeapon } )
	local isLeftHanded = NetProps.GetPropBool( self, "m_bIsLeftHand" )
	local isLeftHandHidden = NetProps.GetPropBool( self, "m_bHideLeftHand" )
	if( previousLeftHand != isLeftHanded || previousHideHand != isLeftHandHidden )
	{
		if( previousLeftHand != isLeftHanded && previousWeapon == curWeapon && Convars.GetInt( "sv_hand_switch_animation" ) > 0 )
		{
			local eventData = {
				user = self, 
				userLastWeapon = curWeapon, 
				userWeapon = curWeapon
			}
			
			CSSO_TriggerGameEvent( "weapon_switch", eventData )
		}
		
		local eventData = {
			user = self, 
			userLastLeftHand = previousLeftHand, 
			userLeftHand = isLeftHanded, 
			userLastHandHidden = previousHideHand, 
			userHandHidden = isLeftHandHidden
		}
		
		CSSO_TriggerGameEvent( "hand_change", eventData )
	}
	
	previousLeftHand = isLeftHanded
	previousHideHand = isLeftHandHidden
	previousWeapon = curWeapon
}

CSSO_AddCustomEvent( "hand_change", function()
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( !ply || !ply.IsValid() )
			continue
		
		cm_addThinkFuncToPlayer( ply, "playerHandChangeThink", -1, playerHandChangeThink )
	}
})

//////////////////////
// PLAYER KILL HOOK //
//////////////////////

/*
	HOW IT WORKS:
	Calls "game_playerkill" event callback function every time "player_death" event is triggered
	(player/bot killed some other player/bot)
	
	Each time the "game_playerkill" event is triggered, the following data block is sent to event's callback function:
	eventData = {
		user, 				// usually a player/bot, who died
		killTime 			// time when user killed another user
	}
*/

CSSO_AddCustomEvent( "game_playerkill" )
///////////////////////
// PLAYER DEATH HOOK //
///////////////////////

/*
	HOW IT WORKS:
	Calls "game_playerdie" event callback function every time "player_death" event is triggered
	(player/bot death)
	
	Each time the "game_playerdie" event is triggered, the following data block is sent to event's callback function:
	eventData = {
		user, 				// usually a player/bot, who died
		deathTime 			// time of user's death (in seconds + milliseconds, server's runtime duration)
	}
*/

CSSO_AddCustomEvent( "game_playerdie" )
AddEventCallback( "player_death", "CSSO_PlayerAction_OnPlayerDeath", function( params ) 
{
	local player = GetPlayerFromUserID( params.userid )
	if( !player || !player.IsValid() )
		return
	
	local eventData = {
		user = player, 
		deathTime = Time()
	}
	
	CSSO_TriggerGameEvent( "game_playerdie", eventData )
	
	local attacker = GetPlayerFromUserID( params.attacker )
	if( !attacker || !attacker.IsValid() || attacker == player )
		return
	
	local eventData = {
		user = attacker, 
		killTime = Time()
	}
	
	CSSO_TriggerGameEvent( "game_playerkill", eventData )
})
