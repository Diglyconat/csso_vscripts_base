
//////////////////////
// PLAYER FUNCTIONS //
//////////////////////

// returns player's nickname based on player entity handle
// or player's "userid" value (check via "status" console command)
// "target" parameter can accept integers!
::cm_getPlayerName <- function( target )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
    if( !target || !target.IsValid() )
        return null
	
	return Convars.GetClientConVarValue( "name", target.entindex() )
}

// returns player's entity handle based on player's username
::GetPlayerFromUserName <- function( userName )
{
	local foundUsers = []
	if( !userName || userName.len() < 1 )
		return foundUsers
	
	local plyFunc = function( ply, target_name = userName, usersList = foundUsers )
	{
		if( cm_getPlayerName( ply ).find( target_name ) != null )
			usersList.append( ply )
	}
	
	triggerPlayersFunc( plyFunc )
	return foundUsers
}

// returns player's entity handle based on player's username
// "userid" field gets overridden on "player_activate" event
::GetPlayerUserID <- function( target )
{
	if( !target || !target.IsValid() )
		return -1
	
	local scope = cm_allocateEntityScriptScope( target, { userid = -1 } )
	return scope.userid
}

// returns player's network ID based on player's entity handle
::GetPlayerNetworkName <- function( target )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
    if( !target || !target.IsValid() )
        return null
	
	local networkName = cm_getPlayerName( target )
	if( !IsPlayerABot( target ) )
	{
		local networkNameStr = NetProps.GetPropString( target, "m_szNetworkIDString" )
		if( !networkNameStr || networkNameStr.len() < 1 )
			return networkName
		
		networkName = networkNameStr.slice( 5, networkNameStr.len()-1 )
	}
	
	return networkName
}

// overrides specified bot's name
// last parameter defines whether the name change message should be hidden from chat or not
::SetCustomBotName <- function( botEnt, newName, isSilent = false )
{
	local userIndex = botEnt
    if( typeof( userIndex ) == "integer" )
        botEnt = GetPlayerFromUserID( userIndex )
	
    if( !botEnt || !botEnt.IsValid() || !IsPlayerABot( botEnt ) )
        return null
	
	if( isSilent )
		NetProps.SetPropString( botEnt, "m_szNetname", newName )
	
	SetFakeClientConVarValue( botEnt, "name", newName )
}

// returns player's used language (always returns "english" for bots!)
::cm_getPlayerLanguage <- function( target )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
    if( !target || !target.IsValid() )
        return null
	
	if( IsPlayerABot( target ) )
		return "english"
	
	local plyLanguage = Convars.GetClientConVarValue( "cl_language", target.entindex() )
	if( !cm_inArray( plyLanguage, CSSO_ServerLanguages ) )
		plyLanguage = "english"
	
	return plyLanguage
}

::showplayers <- function( excludeBots = false )
{
	local plyCount = 0
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( !ply || !ply.IsValid() || ( excludeBots && IsPlayerABot( ply ) ) )
			continue
		
		local userPrint = "[" + plyCount + "] " + cm_getPlayerName( ply )
		if( isBot )
			userPrint += " [BOT]"
		
		printl( userPrint )
	}
}

// retrieves player's viewmodel entity
::cm_getPlayerViewmodel <- function( target )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
    if( !target || !target.IsValid() )
        return null
	
	return NetProps.GetPropEntityArray( target, "m_hViewModel", 0 )
}

// retrieves player's weapon worldmodel entity by weapon classname
::cm_getPlayerWorldmodel <- function( target, wpnClass )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
    if( !target || !target.IsValid() )
        return null
	
	local wpn = cm_getPlayerWeaponByName( target, wpnClass )
	if( !wpn || !wpn.IsValid() )
		return null
	
	local wpnWM = NetProps.GetPropEntity( wpn, "m_hWeaponWorldModel" )
	return wpnWM
}

// retrieves player's currently equipped weapons array
// sorts all weapons by slots & positions
// "excludeList" parameter can be used to exclude specified weapon classes from search
::cm_getPlayerWeapons <- function( target, excludeList = null )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( excludeList == null || typeof( excludeList ) != "array" )
		excludeList = []
	
	//if( !cm_inArray( "weapon_cs_worldmodel", excludeList ) )
	//	excludeList.append( "weapon_cs_worldmodel" )
	
	local weapons = []
	if( !target || !target.IsValid() || !target.IsAlive() )
		return weapons
	
	for( local i = 0; i < 64; i++ )
	{
		local wpn = NetProps.GetPropEntityArray( target, "m_hMyWeapons", i )
		if( !wpn || !wpn.IsValid() || cm_inArray( wpn.GetClassname(), excludeList ) )
			continue
		
		weapons.append( wpn )
	}
	
	return weapons
}

// check if player is a bot (true - bot/false - player)
::cm_isPlayerBot <- function( ply )
{
	return IsPlayerABot( ply )
}

// retrieves weapon from player's loadout by name
// easily done in CS:SO due to custom classname usage!
::cm_getPlayerWeaponByName <- function( target, wpnName )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( !target || !target.IsValid() || !target.IsAlive() )
		return null
	
	local weapons = cm_getPlayerWeapons( target )
	if( weapons.len() < 1 )
		return null
	
	local knifeName = wpnName
	if( wpnName.len() < 7 || wpnName.slice( 0,7 ) != "weapon_" )
	{
		wpnName = "weapon_" + wpnName
		knifeName = "weapon_knife_" + knifeName
	}
	
	local resultWeapon = target.Weapon_OwnsThisType( wpnName )
	if( !resultWeapon || !resultWeapon.IsValid() )
		resultWeapon = target.Weapon_OwnsThisType( knifeName )
	
	return resultWeapon
}

// retrieves weapon from player's loadout by slot & position
::cm_getPlayerWeaponBySlot <- function( target, wpnSlot, wpnPos = 0 )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( !target || !target.IsValid() || !target.IsAlive() )
		return null
	
	if( wpnPos < 1 )
		return target.Weapon_GetSlot( wpnSlot )
	
	local weapons = cm_getPlayerWeapons( target )
	if( weapons.len() < 1 )
		return null
	
	foreach( weapon in weapons )
	{
		if( weapon.GetSlot() == wpnSlot && weapon.GetPosition() == wpnPos )
			return weapon
	}
	
	return null
}

// retrieves weapon from player's loadout by viewmodel MDL name
::cm_getPlayerWeaponByVMDL <- function( target, VMDL )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( !target || !target.IsValid() || !target.IsAlive() )
		return null
	
	local weapons = cm_getPlayerWeapons( target )
	if( weapons.len() < 1 )
		return null
	
	foreach( weapon in weapons )
	{
		if( weapon.GetViewModel(0) == VMDL )
			return weapon
	}
	
	return null
}

// retrieves weapon from player's loadout by worldmodel MDL name
::cm_getPlayerWeaponByWMDL <- function( target, WMDL )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( !target || !target.IsValid() || !target.IsAlive() )
		return null
	
	local weapons = cm_getPlayerWeapons( target )
	if( weapons.len() < 1 )
		return null
	
	foreach( weapon in weapons )
	{
		if( weapon.GetWorldModel() == WMDL )
			return weapon
	}
	
	return null
}

// returns vector representing at which position the specified player is looking at
// set second parameter to 0 or below to get player's "lookat" forward vector
::cm_getPlayerLookatPoint <- function( target, maxLookatDist = 16384 )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( !target || !target.IsValid() || !target.IsAlive() )
		return null
	
	local dir = target.EyeAngles().Forward()
	if( maxLookatDist <= 0.0 )
		return dir
	
	local startOrg = target.EyePosition()
	local traceOrg = startOrg + dir * maxLookatDist
	local trFrac = TraceLinePlayersIncluded( startOrg + dir, traceOrg, target )
	local newOrigin = startOrg + ( traceOrg - startOrg ) * trFrac
	return newOrigin
}

// check if player is crouched or not
// returns false if target is not valid/not alive
::cm_isPlayerCrouched <- function( target )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( !target || !target.IsValid() || !target.IsAlive() )
		return false
	
	// FL_DUCKING == 2
	return ( target.GetFlags() & FL_DUCKING ) == FL_DUCKING
}

// check if player is crouching or not
// returns false if target is not valid/not alive
::cm_isPlayerCrouching <- function( target )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( !target || !target.IsValid() || !target.IsAlive() )
		return false
	
	// FL_ANIMDUCKING == 4
	return ( target.GetFlags() & FL_ANIMDUCKING ) == FL_ANIMDUCKING
}

// check if player is on ground or not
// returns false if target is not valid/not alive
::cm_isPlayerOnGround <- function( target )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( !target || !target.IsValid() || !target.IsAlive() )
		return false
	
	// FL_ONGROUND == 1
	return ( target.GetFlags() & FL_ONGROUND ) == FL_ONGROUND
}

// check if player is on ladder or not
// returns false if target is not valid/not alive
::cm_isPlayerOnLadder <- function( target )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( !target || !target.IsValid() || !target.IsAlive() )
		return false
	
	// MOVETYPE_LADDER == 9
	return target.GetMoveType() == MOVETYPE_LADDER
}

// check if player is spectating or not
// returns false if target is not valid or is alive or is not in spectators team
::cm_isPlayerSpectating <- function( target )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( !target || !target.IsValid() || target.GetTeam() != 1 || target.IsAlive() )
		return false
	
	// MOVETYPE_OBSERVER == 10
	return target.GetMoveType() == MOVETYPE_OBSERVER
}

////////////////////////////
// OTHER PLAYER FUNCTIONS //
////////////////////////////

// switch god mode for specified player
// if no player param specified, the local player will be selected
::god <- function( target = null )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( target == null )
		target = gpf()
	
	if( !target || !target.IsValid() || !target.IsAlive() )
		return
	
	// no reason to enable god mode for dead player!
	local scope = cm_allocateEntityScriptScope( target, { isGodMode = false } )
	if( !target.IsAlive() )
	{
		scope.isGodMode = false
		return
	}
	
	if( scope.isGodMode == false )
	{
		scope.isGodMode = true
		AcceptInput( target, "SetDamageFilter", "cm_NoDMGFilter" )
		printl( "god mode ON [ " + cm_getPlayerName( target ) + " ]" )
	}
	else
	{
		scope.isGodMode = false
		AcceptInput( target, "SetDamageFilter", "" )
		printl( "god mode OFF [ " + cm_getPlayerName( target ) + " ]" )
	}
}

// switch god mode for all players
::gods <- function()
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() )
			god( ply )
	}
}

// switch god mode for players of specified team
::godteam <- function( team )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() && ply.GetTeam() == team )
			god( ply )
	}
}

// switch noclip mode for specified player
// if no player param specified, the local player will be selected
::noclip <- function( target = null )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( target == null )
		target = gpf()
	
	// doesn't switch noclip for players that are: not valid/not alive/climbing ladders/spectating
	if( !target || !target.IsValid() || !target.IsAlive() || target.GetTeam() < 2 || target.GetTeam() > 3 || cm_isPlayerOnLadder( target ) || cm_isPlayerSpectating( target ) )
		return
	
	if( !target.IsNoclipping() )
	{
		target.SetMoveType( 8, 0 )
		printl( "noclip ON [ " + cm_getPlayerName( target ) + " ]" )
	}
	else
	{
		target.SetMoveType( 2, 0 )
		printl( "noclip OFF [ " + cm_getPlayerName( target ) + " ]" )
	}
}

// switch noclip mode for all players
::noclipall <- function()
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() )
			noclip( ply )
	}
}

// switch noclip mode for players of specified team
::noclipteam <- function( team )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() && ply.GetTeam() == team )
			noclip( ply )
	}
}

// respawn player of specified player entity handle
// doesn't respawn invalid or already alive players
::cm_respawnPlayer <- function( target )
{
	if( !target || !target.IsValid() || target.IsAlive() )
		return
	
	local progressBarStartTime = NetProps.GetPropFloat( target, "m_flProgressBarStartTime" )
	if( progressBarStartTime <= 0.0 )
		return
	
	local deadRagdoll = NetProps.GetPropEntity( target, "m_hRagdoll" )
	if( deadRagdoll && deadRagdoll.IsValid() )
		deadRagdoll.Destroy()
	
	NetProps.SetPropInt( target, "m_iPlayerState", 0 )
	NetProps.SetPropFloat( target, "m_flProgressBarStartTime", -1.0 )
	NetProps.SetPropInt( target, "m_iProgressBarDuration", 0 )
	Entities.DispatchSpawn( target )
}

::cm_respawnPlayerDelayed <- function()
{
	local target = activator
	if( !target || !target.IsValid() || target.IsAlive() )
		return
	
	cm_respawnPlayer( target )
}

// respawn specified player
// if no player param specified, the local player will be selected
// use 0 for "delay" value to instantly respawn specified player
// use negative "delay" values to cancel player respawn
// EXAMPLE:
// respawn( 2, 0, false ) - instantly respawn player with "userid" value of 2
// respawn( 2, -1, false ) - cancels player respawn for player with "userid" value of 2
::respawn <- function( target = null, delay = 0.0, progressBar = false )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( target == null )
		target = gpf()
	
	if( !target || !target.IsValid() || target.IsAlive() )
		return
	
	if( delay < 0.0 )
	{
		NetProps.SetPropFloat( target, "m_flProgressBarStartTime", -1.0 )
		NetProps.SetPropInt( target, "m_iProgressBarDuration", 0 )
	}
	else
	{
		if( delay == 0.0 )
		{
			NetProps.SetPropFloat( target, "m_flProgressBarStartTime", Time() )
			NetProps.SetPropInt( target, "m_iProgressBarDuration", 0 )
			cm_respawnPlayer( target )
			return
		}
		
		if( progressBar )
		{
			NetProps.SetPropFloat( target, "m_flProgressBarStartTime", Time() )
			NetProps.SetPropInt( target, "m_iProgressBarDuration", ceil( delay ) )
		}
		
		EntFireByHandle( csso_worldspawn, "RunScriptCode", "cm_respawnPlayerDelayed()", delay, target )
	}
}

// respawn all players
::respawnall <- function( delay = 0.0 )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() )
			respawn( ply, delay )
	}
}

// respawn players of specified team
::respawnteam <- function( team, delay = 0.0 )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() && ply.GetTeam() == team )
			respawn( ply, delay )
	}
}

///////////////////////////////////
// PLAYER MONEY REFILL FUNCTIONS //
///////////////////////////////////

// sets specified amount of money for specified player
// if no player param specified, the local player will be selected
// if no money param specified, the "mp_maxmoney" value will be used
// if money param is negative, the "mp_startmoney" value will be used
::setmoney <- function( target = null, money = -1 )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( target == null )
		target = gpf()
	
	if( !target || !target.IsValid() )
		return
	
	if( money > 0 )
		target.InitializeAccount( money.tointeger() )
	else
		target.InitializeAccount( Convars.GetInt( "mp_startmoney" ) )
}

// set specified amount of money for all players
::setmoneyall <- function( money = -1 )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() )
			setmoney( ply, money )
	}
}

// set specified amount of money for all players based on team number
::setmoneyteam <- function( team, money = -1 )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() && ply.GetTeam() == team )
			setmoney( ply, money )
	}
}

// refill money for specified player based on "mp_maxmoney" convar value
// if no player param specified, the local player will be selected
::refillmoney <- function( target = null )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( target == null )
		target = gpf()
	
	if( !target || !target.IsValid() )
		return
	
	target.InitializeAccount( Convars.GetInt( "mp_maxmoney") )
}

// refill money for all players based on "mp_maxmoney" convar value
::refillmoneyall <- function()
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() )
			refillmoney( ply )
	}
}

// refill money for all players based on team number and "mp_maxmoney" convar value
::refillmoneyteam <- function( team )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() && ply.GetTeam() == team )
			refillmoney( ply )
	}
}

////////////////////////////////////
// PLAYER HEALTH REFILL FUNCTIONS //
////////////////////////////////////

// refill health for specified player (doesn't exceed local player's maximum health value!)
// if no player param specified, the local player will be selected
::refillHP <- function( target = null )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( target == null )
		target = gpf()
	
	if( !target || !target.IsValid() )
		return
	
	local maxHP = target.GetMaxHealth()
	target.SetHealth( maxHP )
}

// refill health for all players (doesn't exceed players' maximum health value!)
::refillHPall <- function()
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() )
			refillHP( ply )
	}
}

// refill health for players of specified team (doesn't exceed players' maximum health value!)
::refillHPteam <- function( team )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() && ply.GetTeam() == team )
			refillHP( ply )
	}
}

///////////////////////////////////
// PRIMARY AMMO REFILL FUNCTIONS //
///////////////////////////////////

// refill primary ammo for specified player's weapons (doesn't exceed primary ammo limits!)
// if no player param specified, the local player will be selected
::refillmag <- function( target = null )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( target == null )
		target = gpf()
	
	local weapons = cm_getPlayerWeapons( target )
	if( weapons.len() < 1 )
		return
	
	foreach( wpn in weapons )
	{
		if( wpn.GetPrimaryAmmoType() < 0 )
			continue
		
		local clipSize = wpn.GetMaxClip1()
		if( clipSize >= 0 )
			wpn.SetClip1( clipSize )
	}
}

// refill primary ammo for all players' weapons (doesn't exceed primary ammo limits!)
::refillmagall <- function()
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() )
			refillmag( ply )
	}
}

// refill primary ammo for players' weapons of specified team (doesn't exceed primary ammo limits!)
::refillmagteam <- function( team )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() && ply.GetTeam() == team )
			refillmag( ply )
	}
}

///////////////////////////////////
// RESERVE AMMO REFILL FUNCTIONS //
///////////////////////////////////

// refill ammo for specified player's weapons (doesn't exceed reserve ammo limits!)
// if no player param specified, the local player will be selected
::refillammo <- function( target = null )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( target == null )
		target = gpf()
	
	target.RemoveAllAmmo()
	local weapons = cm_getPlayerWeapons( target )
	foreach( wpn in weapons )
	{
		local ammoType = wpn.GetPrimaryAmmoType()
		if( ammoType < 0 )
			continue
		
		local maxAmmo = CSSO_GetWeaponMaxReserveAmmo( wpn )
		target.GiveAmmo( maxAmmo, ammoType, false )
	}
}

// refill ammo for all players' active weapons (doesn't exceed reserve ammo limits!)
::refillammoall <- function()
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() )
			refillammo( ply )
	}
}

// refill health for players' active weapons of specified team (doesn't exceed reserve ammo limits!)
::refillammoteam <- function( team )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() && ply.GetTeam() == team )
			refillammo( ply )
	}
}

//////////////////////////////////////
// PLAYER OVERRIDE HEALTH FUNCTIONS //
//////////////////////////////////////

// set new health value for specified player
// if no player param specified, the local player will be selected
::setHP <- function( newHP, target = null )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( target == null )
		target = gpf()
	
	if( newHP < 1 || !target || !target.IsValid() )
		return
	
	target.SetHealth( newHP )
}

// refill health for all players (doesn't exceed players' maximum health value!)
::setHPall <- function( newHP )
{
	if( newHP < 1 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() )
			setHP( newHP, ply )
	}
}

// refill health for players of specified team (doesn't exceed players' maximum health value!)
::setHPteam <- function( newHP, team )
{
	if( newHP < 1 || team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() && ply.GetTeam() == team )
			setHP( newHP, ply )
	}
}

////////////////////////////////////
// PLAYER OVERRIDE TEAM FUNCTIONS //
////////////////////////////////////

// set new health value for specified player
// if no player param specified, the local player will be selected
::setteam <- function( newTeam, target = null )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	if( target == null )
		target = gpf()
	
	if( !target || !target.IsValid() || newTeam < 1 )
		return
	
	target.KeyValueFromInt( "pendingteamnumber", newTeam )
	target.KeyValueFromInt( "teamnumber", newTeam )
}

// refill health for all players (doesn't exceed players' maximum health value!)
::setteamall <- function( newTeam )
{
	if( newTeam < 1 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() )
			setteam( newTeam, ply )
	}
}

// swaps player teams (affects all players!)
::swapteams <- function()
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() )
		{
			local team = ply.GetTeam()
			if( team < 2 || team > 3 )
				continue
			
			setteam( team < 3 ? 3 : 2, ply )
		}
	}
}

//////////////////
// PLAYER COUNT //
//////////////////

// returns amount of players of specified team
// if first param is not specified, then all teams are counted
// if second param:
// - is set to true (set by default), then bots will be included in player count
// - is set to false, then bots will NOT be included in player count
::CSSO_CountTeamPlayers <- function( team = -1, incBots = true )
{
	local plyCount = 0
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( !ply || !ply.IsValid() || ( !incBots && IsPlayerABot( ply ) ) )
			continue
		
		local plyTeam = ply.GetTeam()
		if( plyTeam < 2 || plyTeam > 3 )
			continue
		
		if( team == -1 || plyTeam == team )
			plyCount++
	}
	
	return plyCount
}

// returns amount of ALIVE players of specified team
// if first param is not specified, then all teams are counted
// if second param:
// - is set to true (set by default), then bots will be included in player count
// - is set to false, then bots will NOT be included in player count
::CSSO_CountTeamPlayersAlive <- function( team = -1, incBots = true )
{
	local plyCount = 0
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( !ply || !ply.IsValid() || !ply.IsAlive() || ( !incBots && IsPlayerABot( ply ) ) )
			continue
		
		local plyTeam = ply.GetTeam()
		if( plyTeam < 2 || plyTeam > 3 )
			continue
		
		if( team == -1 || plyTeam == team )
			plyCount++
	}
	
	return plyCount
}
