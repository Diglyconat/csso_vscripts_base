
// Constants for direct access in VScripts, instead of referring to Constants.SubSection.Value every time
// EXAMPLE: VScript creators can use CONTENTS_SOLID instead of Constants.FContents.CONTENTS_SOLID
::CONST <- getconsttable()
::ROOT <- getroottable()
if( !("ConstantNamingConvention" in ROOT) )
{
	foreach( enum_table in Constants )
	{
		foreach( name,value in enum_table )
		{
			if( value == null )
				value = 0

			CONST[ name ] <- value
			ROOT[ name ] <- value
		}
	}
}

// Button bits
::csso_buttons <- {}
csso_buttons[ "+attack" ] <- ( 1 << 0 )
csso_buttons[ "+jump" ] <- ( 1 << 1 )
csso_buttons[ "+duck" ] <- ( 1 << 2 )
csso_buttons[ "+forward" ] <- ( 1 << 3 )
csso_buttons[ "+back" ] <- ( 1 << 4 )
csso_buttons[ "+use" ] <- ( 1 << 5 )
csso_buttons[ "+cancel" ] <- ( 1 << 6 )
csso_buttons[ "+left" ] <- ( 1 << 7 )
csso_buttons[ "+right" ] <- ( 1 << 8 )
csso_buttons[ "+moveleft" ] <- ( 1 << 9 )
csso_buttons[ "+moveright" ] <- ( 1 << 10 )
csso_buttons[ "+attack2" ] <- ( 1 << 11 )
csso_buttons[ "+run" ] <- ( 1 << 12 )
csso_buttons[ "+reload" ] <- ( 1 << 13 )
csso_buttons[ "+alt1" ] <- ( 1 << 14 )
csso_buttons[ "+alt2" ] <- ( 1 << 15 )
csso_buttons[ "+score" ] <- ( 1 << 16 )
csso_buttons[ "+speed" ] <- ( 1 << 17 )
csso_buttons[ "+walk" ] <- ( 1 << 18 )
csso_buttons[ "+zoom" ] <- ( 1 << 19 )
csso_buttons[ "+weapon1" ] <- ( 1 << 20 )
csso_buttons[ "+weapon2" ] <- ( 1 << 21 )
csso_buttons[ "+bullrush" ] <- ( 1 << 22 )
csso_buttons[ "+grenade1" ] <- ( 1 << 23 )
csso_buttons[ "+grenade2" ] <- ( 1 << 24 )
csso_buttons[ "+attack3" ] <- ( 1 << 25 )
csso_buttons[ "+lookatweapon" ] <- ( 1 << 26 )
csso_buttons[ "+switchhands" ] <- ( 1 << 27 )

// ConVar flags
::FCVAR_NONE <- 0
::FCVAR_UNREGISTERED <- ( 1 << 0 )
::FCVAR_DEVELOPMENTONLY <- ( 1 << 1 )
::FCVAR_GAMEDLL <- ( 1 << 2 )
::FCVAR_CLIENTDLL <- ( 1 << 3 )
::FCVAR_MATERIAL_SYSTEM <- ( 1 << 4 )
::FCVAR_PROTECTED <- ( 1 << 5 )
::FCVAR_SPONLY <- ( 1 << 6 )
::FCVAR_ARCHIVE <- ( 1 << 7 )
::FCVAR_NOTIFY <- ( 1 << 8 )
::FCVAR_USERINFO <- ( 1 << 9 )
::FCVAR_PRINTABLEONLY <- ( 1 << 10 )
::FCVAR_UNLOGGED <- ( 1 << 11 )
::FCVAR_NEVER_AS_STRING <- ( 1 << 12 )
::FCVAR_REPLICATED <- ( 1 << 13 )
::FCVAR_CHEAT <- ( 1 << 14 )
::FCVAR_SS <- ( 1 << 15 )
::FCVAR_DEMO <- ( 1 << 16 )
::FCVAR_DONTRECORD <- ( 1 << 17 )
::FCVAR_SS_ADDED <- ( 1 << 18 )
::FCVAR_RELEASE <- ( 1 << 19 )
::FCVAR_RELOAD_MATERIALS <- ( 1 << 20 )
::FCVAR_RELOAD_TEXTURES <- ( 1 << 21 )
::FCVAR_NOT_CONNECTED <- ( 1 << 22 )
::FCVAR_MATERIAL_SYSTEM_THREAD <- ( 1 << 23 )
::FCVAR_ARCHIVE_XBOX <- ( 1 << 24 )
::FCVAR_ACCESSIBLE_FROM_THREADS <- ( 1 << 25 )
::FCVAR_NETWORKSYSTEM <- ( 1 << 26 )
::FCVAR_VPHYSICS <- ( 1 << 27 )
::FCVAR_SERVER_CAN_EXECUTE <- ( 1 << 28 )
::FCVAR_SERVER_CANNOT_QUERY <- ( 1 << 29 )
::FCVAR_CLIENTCMD_CAN_EXECUTE <- ( 1 << 30 )

// CS:SO 2.0 Ammo Types
enum CSSO_AmmoTypes {
	AMMO_TYPE_INVALID, 
	BULLET_PLAYER_50AE, 
	BULLET_PLAYER_762MM, 
	BULLET_PLAYER_556MM, 
	BULLET_PLAYER_556MM_BOX, 
	BULLET_PLAYER_338MAG, 
	BULLET_PLAYER_9MM, 
	BULLET_PLAYER_BUCKSHOT, 
	BULLET_PLAYER_45ACP, 
	BULLET_PLAYER_357SIG, 
	BULLET_PLAYER_57MM, 
	AMMO_TYPE_HEGRENADE, 
	AMMO_TYPE_FLASHBANG, 
	AMMO_TYPE_SMOKEGRENADE, 
	AMMO_TYPE_DECOY, 
	AMMO_TYPE_TASERCHARGE, 
	AMMO_TYPE_MOLOTOV, 
	AMMO_TYPE_HEALTHSHOT, 
	AMMO_TYPE_MAXAMMOTYPES
}