
//////////////////////
// WEAPON FUNCTIONS //
//////////////////////

::CSSO_GetWeaponData <- function( weapon )
{
	if( !weapon || !weapon.IsValid() )
		return null
	
	local wpnClass = weapon.GetClassname()
	if( wpnClass.len() < 7 || wpnClass.slice( 0,7 ) != "weapon_" || cm_inArray( wpnClass, CSSO_WeaponData_Missing ) )
		return null
	
	if( !( wpnClass in CSSO_WeaponData ) )
	{
		CSSO_WeaponData[ wpnClass ] <- {}
		CSSO_WeaponData[ wpnClass ][ "weaponid" ] <- weapon.GetWeaponID()
		local wpnData = weapon.GetWpnData()
		foreach( k,v in wpnData )
			CSSO_WeaponData[ wpnClass ][ k.tolower() ] <- v
	}
	
	return CSSO_WeaponData[ wpnClass ]
}

::CSSO_GetWeaponClassData <- function( wpnClass )
{
	local wpnClassLen = wpnClass.len()
	if( wpnClassLen < 7 || wpnClass.slice( 0,7 ) != "weapon_" )
	{
		wpnClass = "weapon_" + wpnClass
		wpnClassLen += 7
	}
	
	if( wpnClass.slice( wpnClassLen-4 ) == "_off" )
		wpnClass = wpnClass.slice( 0, wpnClassLen-4 )
	
	if( cm_inArray( wpnClass, CSSO_WeaponData_Missing ) )
	{
		local wpnNamePart1 = wpnClass.slice( 0,7 )
		local wpnNamePart2 = wpnClass.slice( 7 )
		wpnClass = wpnNamePart1 + "knife_" + wpnNamePart2
		if( cm_inArray( wpnClass, CSSO_WeaponData_Missing ) )
			return null
	}
	
	if( !( wpnClass in CSSO_WeaponData ) )
	{
		local weapon = CSSO_CreateWeapon( wpnClass )
		if( !weapon )
		{
			if( !cm_inArray( wpnClass, CSSO_WeaponData_Missing ) )
				CSSO_WeaponData_Missing.append( wpnClass )
			
			return null
		}
		
		cm_purgeStr( weapon )
		Entities.DispatchSpawn( weapon )
		CSSO_WeaponData[ wpnClass ] <- {}
		local wpnData = weapon.GetWpnData()
		CSSO_WeaponData[ wpnClass ][ "weaponid" ] <- weapon.GetWeaponID()
		foreach( k,v in wpnData )
			CSSO_WeaponData[ wpnClass ][ k.tolower() ] <- v
		
		weapon.Destroy()
	}
	
	return CSSO_WeaponData[ wpnClass ]
}

::CSSO_GetWeaponDataParam <- function( weapon, param_name )
{
	if( !weapon || !weapon.IsValid() )
		return null
	
	local wpnData = CSSO_GetWeaponData( weapon )
	if( !wpnData )
		return null
	
	param_name = param_name.tolower()
	if( param_name.len() > 3 && param_name.slice( param_name.len()-3, param_name.len() ) == "alt" && !wpnData.rawin( param_name ) )
		param_name = param_name.slice( 0, param_name.len()-3 )
	
	return wpnData.rawin( param_name ) ? wpnData[ param_name ] : null
}

::CSSO_GetWeaponClassDataParam <- function( wpnClass, param_name )
{
	local wpnData = CSSO_GetWeaponClassData( wpnClass )
	if( !wpnData )
		return null
	
	param_name = param_name.tolower()
	if( param_name.len() > 3 && param_name.slice( param_name.len()-3, param_name.len() ) == "alt" && !wpnData.rawin( param_name ) )
		param_name = param_name.slice( 0, param_name.len()-3 )
	
	return wpnData.rawin( param_name ) ? wpnData[ param_name ] : null
}

// delayed function, which assigns primary ammo for weapon handle (only for use via EntFireByHandle!)
::CSSO_AssignPrimaryAmmo <- function( amount )
{
	local wpn = activator
	if( !wpn || !wpn.IsValid() || wpn.GetPrimaryAmmoType() < 0 )
		return
	
	wpn.SetClip1( amount )
}

// delayed function, which gives specified amount of ammo, given the ammo type number (only for use via EntFireByHandle!)
::CSSO_GiveAmmo <- function( amount, type, snd = true )
{
	local target = activator
	if( !target || !target.IsValid() || !target.IsAlive() )
		return
	
	target.GiveAmmo( amount, type, snd )
}

// delayed function, which forces the particular player [activator] to drop the particular weapon [caller] (only for use via EntFireByHandle!)
::CSSO_DropWeapon <- function()
{
	local target = activator
	if( !target || !target.IsValid() || !target.IsAlive() )
		return
	
	local wpn = caller
	if( !wpn || !wpn.IsValid() )
		return
	
	target.Weapon_Drop( wpn, false, Vector(), false, Vector() )
}

// delayed function, which forces the particular player [activator] to be disarmed from the particular weapon [caller] (only for use via EntFireByHandle!)
// WARNING! This function actually REMOVES weapons entities!
::CSSO_DisarmWeapon <- function()
{
	local target = activator
	if( !target || !target.IsValid() || !target.IsAlive() )
		return
	
	local wpn = caller
	if( !wpn || !wpn.IsValid() )
		return
	
	target.Weapon_Drop( wpn, false, Vector(), false, Vector() )
	wpn.Destroy()
}

// force "wpn" weapon equip for specified "target" ("wpn" and "target" entity handles only!)
// forces "item_pickup" event to be sent, since "player.Weapon_Drop( weapon )" doesn't do so
::CSSO_EquipWeapon <- function( target, wpn )
{
	if( !target || !target.IsValid() || !target.IsAlive() || !wpn || !wpn.IsValid() )
		return
	
	target.Weapon_Equip( wpn )
	if( !wpn || !wpn.IsValid() )
		return
	
	SendGlobalGameEvent( "item_pickup", { userid = GetPlayerUserID( target ), item = wpn.GetClassname().slice( 7 ), silent = false } )
}

// delayed function, which forces the particular player [activator] to equip the particular weapon [caller] (only for use via EntFireByHandle!)
::CSSO_EquipWeapon_Delayed <- function()
{
	local target = activator
	if( !target || !target.IsValid() || !target.IsAlive() )
		return
	
	local wpn = caller
	if( !wpn || !wpn.IsValid() )
		return
	
	target.Weapon_Equip( wpn )
	if( !wpn || !wpn.IsValid() )
		return
	
	SendGlobalGameEvent( "item_pickup", { userid = GetPlayerUserID( target ), item = wpn.GetClassname().slice( 7 ), silent = false } )
}

// delayed function, which forces the particular player [activator] to switch to particular weapon [caller] (only for use via EntFireByHandle!)
::CSSO_SwitchToWeapon <- function()
{
	local target = activator
	if( !target || !target.IsValid() || !target.IsAlive() )
		return
	
	local wpn = caller
	if( !wpn || !wpn.IsValid() )
		return
	
	target.Weapon_Switch( wpn )
}

// assigns "assignedOwner" player entity to a specified weapon "wpnEntity"
::CSSO_AssignWeaponOwner <- function( wpnEntity, assignedOwner = null )
{
	if( !wpnEntity || !wpnEntity.IsValid() )
		return
	
	if( !assignedOwner || !assignedOwner.IsValid() || assignedOwner.GetClassname() != "player" )
	{
		NetProps.SetPropInt( wpnEntity, "m_iOriginalOwner", 0 )
		return
	}
	
	local team = assignedOwner.GetTeam()
	if( team < 2 || team > 3 )
	{
		NetProps.SetPropInt( wpnEntity, "m_iOriginalOwner", GetPlayerUserID( assignedOwner ) << 16 )
		return
	}
	
	NetProps.SetPropInt( wpnEntity, "m_iOriginalOwner", ( GetPlayerUserID( assignedOwner ) << 16 ) | team )
}

// changes "wpnEntity" weapon team based on its' assigned owner player entity handle
::CSSO_ChangeWeaponTeam <- function( wpnEntity, wpnTeam )
{
	if( !wpnEntity || !wpnEntity.IsValid() )
		return
	
	local wpnOwner = wpnEntity.GetMoveParent()
	if( !wpnOwner || !wpnOwner.IsValid() )
		return
	
	if( wpnTeam < 2 || wpnTeam > 3 )
	{
		NetProps.SetPropInt( wpnEntity, "m_iOriginalOwner", GetPlayerUserID( wpnOwner ) << 16 )
		return
	}
	
	NetProps.SetPropInt( wpnEntity, "m_iOriginalOwner", ( GetPlayerUserID( wpnOwner ) << 16 ) | wpnTeam )
}

// returns null if there's no weapon with such class
// only used for entities that have "weapon_" prefix!
// "wpnOwner" parameter is optional and is used to define the player entity to which the weapon will be "assigned"
::CSSO_CreateWeapon <- function( weapon_name, assignedOwner = null )
{
	// adds "weapon_" prefix and tries spawning weapon with specified classname anyway
	// if "weapon_wpnName" failed to spawn, it'll attempt to spawn "weapon_knife_wpnName" instead
	if( weapon_name.len() < 7 || weapon_name.slice( 0,7 ) != "weapon_" )
		weapon_name = "weapon_" + weapon_name
	
	local isGoldWeapon = weapon_name.find( "[gg]" ) != null
	if( isGoldWeapon )
		weapon_name = weapon_name.slice( 0, weapon_name.len() - 4 )
	
	if( cm_inArray( weapon_name, CSSO_WeaponData_Missing ) )
	{
		local wpnNamePart1 = weapon_name.slice( 0,7 )
		local wpnNamePart2 = weapon_name.slice( 7 )
		weapon_name = wpnNamePart1 + "knife_" + wpnNamePart2
		if( cm_inArray( weapon_name, CSSO_WeaponData_Missing ) )
			return null
	}
	
	local newWeapon = Entities.CreateByClassname( weapon_name )
	if( !newWeapon )
	{
		if( !cm_inArray( weapon_name, CSSO_WeaponData_Missing ) )
			CSSO_WeaponData_Missing.append( weapon_name )
		
		local wpnNamePart1 = weapon_name.slice( 0,7 )
		local wpnNamePart2 = weapon_name.slice( 7 )
		weapon_name = wpnNamePart1 + "knife_" + wpnNamePart2
		newWeapon = Entities.CreateByClassname( weapon_name )
		if( !newWeapon )
		{
			if( !cm_inArray( weapon_name, CSSO_WeaponData_Missing ) )
				CSSO_WeaponData_Missing.append( weapon_name )
			
			return null
		}
	}
	
	cm_purgeStr( newWeapon )
	if( isGoldWeapon )
		NetProps.SetPropBool( newWeapon, "m_bIsGoldWeapon", true )
	
	CSSO_AssignWeaponOwner( newWeapon, assignedOwner )
	return newWeapon
}

::CSSO_GetWeaponFromViewmodel <- function( vmEnt, VMDL = null )
{
	if( !vmEnt || !vmEnt.IsValid() )
		return null
	
	local vmWeapon = NetProps.GetPropEntity( vmEnt, "m_hWeapon" )
	if( !vmWeapon || !vmWeapon.IsValid() )
		return null
	
	if( !VMDL || vmWeapon.GetViewModel(0) == VMDL )
		return vmWeapon
	
	return null
}

::CSSO_GetWeaponFromWorldmodel <- function( wmEnt, WMDL = null )
{
	if( !wmEnt || !wmEnt.IsValid() )
		return null
	
	local wmWeapon = NetProps.GetPropEntity( wmEnt, "m_hCombatWeaponParent" )
	if( !wmWeapon || !wmWeapon.IsValid() )
		return null
	
	if( !WMDL || wmWeapon.GetWorldModel() == WMDL )
		return wmWeapon
	
	return null
}

// spawns weapon at the desired origin
// doesn't spawn anything if weapon entity is NOT VALID or no origin/location is specified
::CSSO_SpawnWeaponAtOrigin <- function( weapon_name, origin = null, primaryAmmo = -1, reserveAmmo = -1 )
{
	if( !origin )
		return null
	
	local newWeapon = CSSO_CreateWeapon( weapon_name )
	if( !newWeapon )
		return null
	
	newWeapon.SetAbsOrigin( origin )
	Entities.DispatchSpawn( newWeapon )
	
	local ammoType = newWeapon.GetPrimaryAmmoType()
	if( ammoType >= 0 )
	{
		if( reserveAmmo >= 0 )
			newWeapon.SetExtraAmmoCount( reserveAmmo )
		
		if( primaryAmmo >= 0 )
			newWeapon.SetClip1( cm_Clamp( primaryAmmo, 0, newWeapon.GetMaxClip1() ) )
	}
	
	return newWeapon
}

// spawns weapon for the desired VALID player entity
// doesn't spawn anything if either player or weapon entity is NOT VALID
// "target" only accepts direct player entity handle!
::CSSO_SpawnWeaponForPlayer <- function( weapon_name, target = -1, primaryAmmo = -1, reserveAmmo = -1 )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
	{
		if( tgtIndex > 0 )
			target = GetPlayerFromUserID( tgtIndex )
		else
			target = gpf()
	}
	
	if( !target || !target.IsValid() )
		return null
	
	local newWeapon = CSSO_SpawnWeaponAtOrigin( weapon_name, target.GetCenter(), primaryAmmo, reserveAmmo )
	if( !newWeapon || !newWeapon.IsValid() )
		return null
	
	CSSO_AssignWeaponOwner( newWeapon, target )
	return newWeapon
}

// equips specified weapon for specified VALID player entity
// (only if it has any weight/importance, or if there's no other weapon/item in player's loadout)
// doesn't spawn anything if either player or weapon entity is NOT VALID
// doesn't alter weapons' primary and reserve ammo!
// "target" only accepts direct player entity handle!
::CSSO_EquipWeaponForPlayer <- function( weapon_name, target = -1, primaryAmmo = -1, reserveAmmo = -1, forceEquip = false )
{
	if( !target || !target.IsValid() || !target.IsAlive() )
		return
	
	local newWeapon = CSSO_SpawnWeaponForPlayer( weapon_name, target, primaryAmmo, reserveAmmo )
	if( !newWeapon )
		return null
	
	local newWpnSlot = newWeapon.GetSlot()
	local newWpnSlotPos = newWeapon.GetPosition()
	local oldWpn = cm_getPlayerWeaponBySlot( target, newWpnSlot, newWpnSlotPos )
	if( oldWpn && oldWpn.IsValid() )
	{
		target.Weapon_Drop( oldWpn, false, Vector(), false, Vector() )
		if( !CSSO_CanWeaponBeDropped( oldWpn ) )
			oldWpn.Destroy()
	}
	
	CSSO_EquipWeapon( target, newWeapon )
	if( !newWeapon || !newWeapon.IsValid() )
		return null
	
	local ammoType = newWeapon.GetPrimaryAmmoType()
	local ammoCount = target.GetAmmoCount( ammoType )
	if( newWeapon.UsesClipsForAmmo1() )
	{
		target.RemoveAmmo( ammoCount, ammoType )
		target.GiveAmmo( newWeapon.GetExtraAmmoCount(), ammoType, false )
	}
	
	if( forceEquip )
		target.Weapon_Switch( newWeapon )
	
	return newWeapon
}

// obsolete/legacy variant of "CSSO_EquipWeaponForPlayer", which uses "game_player_equip" entity to give weapons/items to player
// doesn't alter weapons' primary and reserve ammo!
// doesn't spawn custom knives, it's selected based on which knife is in loadout of the specified "target" player!
// doesn't spawn golden weapons!
::CSSO_EquipWeaponForPlayerLegacy <- function( weapon_name, target, clearLoadout = false )
{
	if( !target || !target.IsValid() || !target.IsAlive() )
		return
	
	local wpnList = split( weapon_name, "," )
	local gpeFlags = 3 + ( !clearLoadout ? 2 : 0 )
	local itemGPE = Entities.CreateByClassname( "game_player_equip" )
	itemGPE.__KeyValueFromString( "classname", "info_target" )
	itemGPE.__KeyValueFromInt( "spawnflags", gpeFlags )
	
	foreach( wpn in wpnList )
	{
		local wpnName = strip( wpn ).tolower()
		if( wpnName.len() < 7 || wpnName.slice( 0,7 ) != "weapon_" )
			wpnName = "weapon_" + wpnName
		
		itemGPE.__KeyValueFromInt( wpnName, 0 )
	}
	
	itemGPE.AcceptInput( "Use", "", target, target )
	EntFireByHandle( itemGPE, "Kill", "", 0 )
}

::CSSO_GetWeaponReserveAmmo <- function( wpn )
{
	if( !wpn || !wpn.IsValid() )
		return -1
	
	local ammoType = wpn.GetPrimaryAmmoType()
	if( ammoType < 0 )
		return -1
	
	local wpnOwner = wpn.GetMoveParent()
	if( !wpnOwner || !wpnOwner.IsValid() )
	{
		wpnOwner = wpn.GetOwner()
		if( !wpnOwner || !wpnOwner.IsValid() )
			return -1
	}
	
	return wpnOwner.GetAmmoCount( ammoType )
}

::CSSO_GetWeaponMaxReserveAmmo <- function( wpn )
{
	if( !wpn || !wpn.IsValid() )
		return 0
	
	return CSSO_GetWeaponDataParam( wpn, "ReserveAmmoMax" )
}

::CSSO_CanWeaponBeDropped <- function( wpn )
{
	if( !wpn || !wpn.IsValid() )
		return false
	
	if( wpn.IsMeleeWeapon() )
	{
		if( !Convars.GetBool( "mp_drop_knife_enable" ) )
			return false
	}
	
	if( GetEntProp( wpn, "m_flPinPulledTime" ) != null )
	{
		if( !Convars.GetBool( "mp_drop_grenade_enable" ) )
			return false
	}
	
	if( GetEntProp( wpn, "m_fArmedTime" ) != null )
	{
		if( !Convars.GetBool( "mp_drop_c4_enable" ) )
			return false
	}
	
	if( !Convars.GetBool( "mp_drop_gun_enable" ) )
		return false
	
	return true
}

// as a reference for "give weapon_name" command used as VScript instead, usage:
// script give( weapon ) - gives specified weapon (or list of weapons) to host player
// script give( weapon, target ) - gives specified weapon (or list of weapons) to specified player
// gives specified weapon(s) to specified player
// if no player is specified, host player will be used
// UPDATE: added support for weapon names string, each desired weapon must be separated with comma symbol
// EXAMPLE: give( "ak47,mp5sd,usp,karambit" )
// P.S. it works for "give" function variations too!
::give <- function( weapon_name, target = -1, primaryAmmo = -1, reserveAmmo = -1 )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
	{
		if( tgtIndex > 0 )
			target = GetPlayerFromUserID( tgtIndex )
		else
			target = gpf()
	}
	
	if( !target || !target.IsValid() || !target.IsAlive() )
		return
	
	local wpnList = split( weapon_name, "," )
	foreach( wpn in wpnList )
	{
		wpn = strip( wpn ).tolower()
		CSSO_SpawnWeaponForPlayer( wpn, target, primaryAmmo, reserveAmmo )
	}
}

// gives specified weapon(s) to all PLAYERS
::giveall <- function( weapon_name )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( target && target.IsValid() )
			give( weapon_name, target )
	}
}

// gives specified weapon(s) to PLAYERS of specified team
::giveteam <- function( weapon_name, team )
{
	// don't give weapons to players & bots that aren't on CT or T side!
	if( team < 2 && team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( target && target.IsValid() && target.GetTeam() == team )
			give( weapon_name, target )
	}
}

// equips specified weapon(s) for specified player
// if no player parameter is specified, then the host player is selected
// "primaryAmmo" and "reserveAmmo" is applied for the first weapon in the list, if there are multiple weapons in "weapon_name"
// supports weapon names string list, each desired weapon must be separated with comma symbol
// EXAMPLE: equip( "ak47,mp5sd,usp,karambit" )
// P.S. it works for "equip" function variations too!
::equip <- function( weapon_name, target = -1, primaryAmmo = -1, reserveAmmo = -1, forceEquip = true )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
	{
		if( tgtIndex > 0 )
			target = GetPlayerFromUserID( tgtIndex )
		else
			target = gpf()
	}
	
	if( !target || !target.IsValid() || !target.IsAlive() )
		return
	
	// other weapons are given with full primary & reserve ammo, can't do anything about it!
	local wpnList = split( weapon_name, "," )
	local firstWpn = strip( wpnList[0] )
	cm_removeFromArray( firstWpn, wpnList )
	firstWpn = firstWpn.tolower()
	
	if( CSSO_GetWeaponClassDataParam( firstWpn, "WeaponID" ) != null )
	{
		local curWeapon = target.Weapon_GetSlot( CSSO_GetWeaponClassDataParam( firstWpn, "bucket" ) )
		if( curWeapon && curWeapon.IsValid() )
		{
			if( CSSO_GetWeaponClassDataParam( firstWpn, "bucket_position" ) == curWeapon.GetPosition() && !CSSO_CanWeaponBeDropped( curWeapon ) )
				curWeapon.Destroy()
		}
		
		CSSO_EquipWeaponForPlayer( firstWpn, target, primaryAmmo, reserveAmmo, forceEquip )
	}
	
	if( wpnList.len() < 1 )
		return
	
	foreach( wpn in wpnList )
	{
		wpn = strip( wpn ).tolower()
		if( cm_getPlayerWeaponByName( target, wpn ) != null )
			continue
		
		if( CSSO_GetWeaponClassDataParam( wpn, "WeaponID" ) == null )
			continue
		
		local wpnInst = target.Weapon_GetSlot( CSSO_GetWeaponClassDataParam( wpn, "bucket" ) )
		if( wpnInst && wpnInst.IsValid() )
		{
			if( CSSO_GetWeaponClassDataParam( wpn, "bucket_position" ) == wpnInst.GetPosition() && !CSSO_CanWeaponBeDropped( wpnInst ) )
				wpnInst.Destroy()
		}
		
		CSSO_EquipWeaponForPlayer( wpn, target )
	}
}

// equips specified weapon(s) to all PLAYERS
::equipall <- function( weapon_name )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( target && target.IsValid() )
			equip( weapon_name, target )
	}
}

// equips specified weapon(s) to PLAYERS of specified team
::equipteam <- function( weapon_name, team )
{
	// don't give weapons to players & bots that aren't on CT or T side!
	if( team < 2 && team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( target && target.IsValid() && target.GetTeam() == team )
			equip( weapon_name, target )
	}
}

// forces specified player to drop specified weapon (or list of weapons)
// if no weapon parameter is specified, then the currently held weapon will be used
// if weapon param is passed as "*", the target player will be forced to drop all weapons
// if weapon param is passed as weapons list (each weapon name is separated with ',')
// -	then all weapons of specified list will be dropped
// if no player parameter is specified, then the host player is selected
::drop <- function( weaponToDrop = null, target = -1 )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
	{
		if( tgtIndex > 0 )
			target = GetPlayerFromUserID( tgtIndex )
		else
			target = gpf()
	}
	
	if( !target || !target.IsValid() || !target.IsAlive() )
		return
	
	local weapons = cm_getPlayerWeapons( target )
	if( weapons.len() < 1 )
		return
	
	if( weaponToDrop == null )
	{
		local activeWpn = target.GetActiveWeapon()
		if( activeWpn == null )
			return
		
		target.Weapon_Drop( activeWpn, false, Vector(), false, Vector() )
		return
	}
	
	if( weaponToDrop == "*" )
	{
		foreach( wpn in weapons )
			target.Weapon_Drop( wpn, false, Vector(), false, Vector() )
		
		return
	}
	
	local wpnDropList = split( weaponToDrop, "," )
	foreach( wpn in wpnDropList )
	{
		wpn = strip( wpn ).tolower()
		local curWeapon = cm_getPlayerWeaponByName( target, wpn )
		if( !curWeapon )
			continue
		
		target.Weapon_Drop( wpn, false, Vector(), false, Vector() )
	}
}

// forces all PLAYERS to drop their specified weapon if they have one
// if no weapon parameter is specified, then the currently held weapon will be used
// if weapon param is passed as "*", the target player will be forced to drop all weapons
// if weapon param is passed as weapons list (each weapon name is separated with ',')
// -	then all weapons of specified list will be dropped
::dropall <- function( weaponToDrop = null )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( target && target.IsValid() )
			drop( weaponToDrop, target )
	}
}

// forces all PLAYERS of specified team to drop their specified weapon if they have one
// if no second parameter is specified, then the currently held weapon will be used
// if second param is passed as "*", the target player will be forced to drop all weapons
// if second param is passed as weapons list (each weapon name is separated with ',')
// -	then all weapons of specified list will be dropped
::dropteam <- function( team, weaponToDrop = null )
{
	// don't give weapons to players & bots that aren't on CT or T side!
	if( team < 2 && team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( target && target.IsValid() && target.GetTeam() == team )
			drop( weaponToDrop, target )
	}
}

// forces specified player to drop weapons of specified loadout slot (or list of loadout slots)
// if no slot parameter is specified, then the currently held weapon will be used
// if slot param is passed as "*", the target player will be forced to drop all weapons from all slots
// if slot param is passed as a list of slots (each slot is separated with ',')
// 		- the target player will be forced to drop all weapons from the list of slots
// if slot pos param is passed as "*", the target player will be forced to drop all weapons from all positions in specified slot(s)
// if slot pos param is passed as a list of positions (each position is separated with ',')
// 		- the target player will be forced to drop all weapons from the list of positions in specified slot(s)
::dropslot <- function( weaponSlot = null, weaponPos = null, target = -1 )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
	{
		if( tgtIndex > 0 )
			target = GetPlayerFromUserID( tgtIndex )
		else
			target = gpf()
	}
	
	if( !target || !target.IsValid() || !target.IsAlive() )
		return
	
	local weapons = cm_getPlayerWeapons( target )
	if( weapons.len() < 1 )
		return
	
	if( !weaponSlot )
	{
		local activeWpn = target.GetActiveWeapon()
		if( !activeWpn )
			return
		
		target.Weapon_Drop( activeWpn, false, Vector(), false, Vector() )
		return
	}
	
	if( weaponSlot == "*" )
	{
		if( !weaponPos )
		{
			foreach( wpn in weapons )
				target.Weapon_Drop( wpn, false, Vector(), false, Vector() )
			
			return
		}
		
		weaponPos = "" + weaponPos
		local wpnDropPosList = split( weaponPos, "," )
		foreach( pos in wpnDropPosList )
		{
			pos = strip( pos )
			foreach( weapon in weapons )
			{
				if( weapon.GetPosition() == pos.tointeger() )
					target.Weapon_Drop( weapon, false, Vector(), false, Vector() )
			}
		}
		return
	}
	
	weaponSlot = "" + weaponSlot
	local wpnDropList = split( weaponSlot, "," )
	if( !weaponPos )
	{
		foreach( wpn in wpnDropList )
		{
			wpn = strip( wpn )
			foreach( weapon in weapons )
			{
				if( weapon.GetSlot() == wpn.tointeger() )
					target.Weapon_Drop( weapon, false, Vector(), false, Vector() )
			}
		}
		
		return
	}
	
	weaponPos = "" + weaponPos
	local wpnDropPosList = split( weaponPos, "," )
	foreach( pos in wpnDropPosList )
	{
		pos = strip( pos )
		foreach( wpn in wpnDropList )
		{
			wpn = strip( wpn )
			foreach( weapon in weapons )
			{
				if( weapon.GetSlot() == wpn.tointeger() && weapon.GetPosition() == pos.tointeger() )
					target.Weapon_Drop( weapon, false, Vector(), false, Vector() )
			}
		}
		
		return
	}
}

// forces all PLAYERS to drop their weapons of specified loadout slots
::dropslotall <- function( weaponSlot = null, weaponPos = null )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( target && target.IsValid() )
			dropslot( weaponSlot, weaponPos, target )
	}
}

// forces all PLAYERS of specified team to drop their weapons of specified loadout slots
::dropslotteam <- function( team, weaponSlot = null, weaponPos = null )
{
	// don't give weapons to players & bots that aren't on CT or T side!
	if( team < 2 && team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( target && target.IsValid() && target.GetTeam() == team )
			dropslot( weaponSlot, weaponPos, target )
	}
}

// separate function to add a thinkfunction for the weapon to automatically refill PRIMARY ammo
::cm_assignInfAmmoForWeapon <- function( weapon )
{
	if( !weapon || !weapon.IsValid() || weapon.GetPrimaryAmmoType() < 0 )
		return
	
	local scope = cm_allocateEntityScriptScope( weapon, 
		{
			infAmmoEnabled = false, 
			maxAmmo = weapon.GetMaxClip1(), 
		}
		function( wpn = weapon )
		{
			cm_addThinkFuncToEnt( wpn, "CSSO_Weapons_InfiniteAmmoThink", -1, function()
			{
				if( !self || !self.IsValid() || infAmmoEnabled == false )
					return -1
				
				self.SetClip1( maxAmmo )
				return -1
			} )
		} )
	
	scope.infAmmoEnabled = !scope.infAmmoEnabled
	if( scope.infAmmoEnabled == true )
		printl( "infinite ammo ON for \"" + weapon.GetClassname() + "\" [ owner: " + cm_getPlayerName( weapon.GetMoveParent() ) + " ] " )
	else
		printl( "infinite ammo OFF for \"" + weapon.GetClassname() + "\" [ owner: " + cm_getPlayerName( weapon.GetMoveParent() ) + " ] " )
}

// toggles infinite PRIMARY ammo for specified weapon of specified player
// if no weapon parameter is specified, then the currently held weapon will have infinite PRIMARY ammo
// if weapon param is passed as "*", the target player will have infinite PRIMARY ammo for all weapons
// if weapon param is passed as a list of weapons (each weapon name is separated with ',')
// 		- the target player will have infinite PRIMARY ammo for all weapons from the list
// if no player parameter is specified, then the host player is selected
::setinfammo <- function( weaponToSet = null, target = -1 )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
	{
		if( tgtIndex > 0 )
			target = GetPlayerFromUserID( tgtIndex )
		else
			target = gpf()
	}
	
	if( !target || !target.IsValid() || !target.IsAlive() )
		return
	
	if( !weaponToSet )
		cm_assignInfAmmoForWeapon( target.GetActiveWeapon() )
	else
	{
		if( weaponToSet == "*" )
		{
			local weapons = cm_getPlayerWeapons( target )
			foreach( wpn in weapons )
				cm_assignInfAmmoForWeapon( wpn )
			
			return
		}
		
		local wpnList = split( weaponToSet, "," )
		foreach( wpn in wpnList )
		{
			local curWeapon = cm_getPlayerWeaponByName( target, strip( wpn ).tolower() )
			cm_assignInfAmmoForWeapon( curWeapon )
		}
	}
}

// toggles infinite PRIMARY ammo for specified weapon(s) of ALL players
::setinfammoall <- function( weaponToSet = null )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( target && target.IsValid() )
			setinfammo( weaponToSet, target )
	}
}

// toggles infinite PRIMARY ammo for specified weapon(s) of ALL players of the specified team
::setinfammoteam <- function( team, weaponToSet = null )
{
	// don't give weapons to players & bots that aren't on CT or T side!
	if( team < 2 && team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( target && target.IsValid() && target.GetTeam() == team )
			setinfammo( weaponToSet, target )
	}
}

////////////////////////////
// WEAPON STRIP FUNCTIONS //
////////////////////////////

// strip/disarm specified weapon (or list of weapons) from specified player
// if no weapon parameter is specified, then the currently held weapon will be stripped off
// if weapon param is passed as "*", the target player will be disarmed completely
// if weapon param is passed as weapons list (each weapon name is separated with ',')
// -	then all weapons of specified list will be disarmed from player
// if no player parameter is specified, then the host player is selected
// WARNING! This function actually REMOVES weapons entities!
::disarm <- function( wpnToDisarm = null, target = -1 )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
	{
		if( tgtIndex > 0 )
			target = GetPlayerFromUserID( tgtIndex )
		else
			target = gpf()
	}
	
	if( !target || !target.IsValid() )
		return
	
	local weapons = cm_getPlayerWeapons( target )
	if( weapons.len() < 1 )
		return
	
	if( !wpnToDisarm )
	{
		local activeWpn = target.GetActiveWeapon()
		if( !activeWpn )
			return
		
		target.Weapon_Drop( activeWpn, false, Vector(), false, Vector() )
		activeWpn.Destroy()
		return
	}
	
	if( wpnToDisarm == "*" )
	{
		foreach( wpn in weapons )
		{
			if( !wpn || !wpn.IsValid() )
				continue
			
			target.Weapon_Drop( wpn, false, Vector(), false, Vector() )
			wpn.Destroy()
		}
		
		return
	}
	
	local wpnDropList = split( wpnToDisarm, "," )
	foreach( wpn in wpnDropList )
	{
		wpn = strip( wpn ).tolower()
		local curWeapon = cm_getPlayerWeaponByName( target, wpn )
		if( !curWeapon || !curWeapon.IsValid() )
			continue
		
		target.Weapon_Drop( curWeapon, false, Vector(), false, Vector() )
		curWeapon.Destroy()
	}
}

// strip/disarm specified weapon (or list of weapons) from all players
::disarmall <- function( wpnToDisarm = null )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( target && target.IsValid() )
			disarm( wpnToDisarm, target )
	}
}

// strip/disarm specified weapon (or list of weapons) from players of specified team
::disarmteam <- function( team, wpnToDisarm = null )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( target && target.IsValid() && target.GetTeam() == team )
			disarm( wpnToDisarm, target )
	}
}

// force a certain viewmodel sequence to be played on specified viewmodel
// "target" can be either a direct reference to "predicted_viewmodel" entity, or player entity, based on which the "predicted_viewmodel" entity will be selected
// "seq" - animation sequence NUMBER
// "speedMult" - animation playback rate modifier
// "loop" - should the animation loop or not
// "timeOffset" - extra time to be set for sequence duration (useful when it's required to keep the last frame of the animation for some time)
::CSSO_ForceViewmodelSequence <- function( target, seq, speedMult = 1.0, loop = false, timeOffset = 0.0 )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
	{
		if( tgtIndex > 0 )
			target = GetPlayerFromUserID( tgtIndex )
		
		if( !target || !target.IsValid() )
			target = EntIndexToHScript( tgtIndex )
	}
	
	if( !target || !target.IsValid() )
		return
	
	local tgtClass = target.GetClassname()
	if( !( target.GetClassname() == "player" || target.GetClassname() == "predicted_viewmodel" ) )
		return
	
	local wpn = null
	if( tgtClass == "player" )
		wpn = target.GetActiveWeapon()
	else if( tgtClass == "predicted_viewmodel" )
		wpn = CSSO_GetWeaponFromViewmodel( target )
	
	if( !wpn || !wpn.IsValid() )
		return
	
	local vm = target
	if( vm.GetClassname() != "predicted_viewmodel" )
		vm = cm_getPlayerViewmodel( target )
	
	if( !vm || !vm.IsValid() || vm.GetSequenceName( seq ) == "Not Found!" )
		return
	
	NetProps.SetPropFloat( wpn, "m_flTimeWeaponIdle", Time() )
	local eventParity = NetProps.GetPropInt( vm, "m_nResetEventsParity" )
	eventParity = ( eventParity + 1 ) & ( ( 1 << 3 ) - 1 )
	NetProps.SetPropInt( vm, "m_nResetEventsParity", eventParity )
	NetProps.SetPropInt( wpn, "m_nIdealSequence", seq )
	
	local seqDuration = vm.GetSequenceDuration( seq )
	local curSequence = vm.GetSequence()
	if( seq == curSequence )
	{
		local animParity = NetProps.GetPropInt( vm, "m_nAnimationParity" )
		local seqParity = NetProps.GetPropInt( vm, "m_nNewSequenceParity" )
		animParity = ( animParity + 1 ) & ( ( 1 << 3 ) - 1 )
		seqParity = ( seqParity + 1 ) & ( ( 1 << 3 ) - 1 )
		NetProps.SetPropInt( vm, "m_nNewSequenceParity", seqParity )
		NetProps.SetPropInt( vm, "m_nAnimationParity", animParity )
		EntFireByHandle( vm, "RunScriptCode", "self.ResetSequence( " + seq + " )", 0.02 )
		EntFireByHandle( wpn, "RunScriptCode", "self.ResetSequence( " + seq + " )", 0.02 )
		EntFireByHandle( vm, "RunScriptCode", "self.SetPlaybackRate( " + speedMult + " )", 0.02 )
		EntFireByHandle( wpn, "RunScriptCode", "self.SetPlaybackRate( " + speedMult + " )", 0.02 )
		EntFireByHandle( vm, "RunScriptCode", "NetProps.SetPropFloat( self, \"m_flTimeWeaponIdle\", " + ( loop ? 1e308 : Time() + seqDuration * ( 1.0 / speedMult ) + cm_Clamp( timeOffset, 0.0 ) ) + " )", 0.02 )
		EntFireByHandle( wpn, "RunScriptCode", "NetProps.SetPropFloat( self, \"m_flTimeWeaponIdle\", " + ( loop ? 1e308 : Time() + seqDuration * ( 1.0 / speedMult ) + cm_Clamp( timeOffset, 0.0 ) ) + " )", 0.02 )
		return
	}
	
	NetProps.SetPropBool( vm, "m_bSequenceLoops", loop )
	NetProps.SetPropBool( wpn, "m_bSequenceLoops", loop )
	NetProps.SetPropFloat( vm, "m_flTimeWeaponIdle", loop ? 1e308 : Time() + seqDuration * ( 1.0 / speedMult ) + cm_Clamp( timeOffset, 0.0 ) )
	NetProps.SetPropFloat( wpn, "m_flTimeWeaponIdle", loop ? 1e308 : Time() + seqDuration * ( 1.0 / speedMult ) + cm_Clamp( timeOffset, 0.0 ) )
	vm.ResetSequence( seq )
	vm.SetPlaybackRate( speedMult )
}
