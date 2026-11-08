
::CSSO_ChatTeamStrings <- [
	"CSSO_PlayerTeam_Unassigned", 
	"CSSO_PlayerTeam_Spectator", 
	"CSSO_PlayerTeam_Terrorist", 
	"CSSO_PlayerTeam_CounterTerrorist"
]

// force formatted text to be sent in chat FOR specified player IN TEAM CHAT
::sayt1 <- function( printText, target )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() )
		return
	
	local plyLanguage = cm_getPlayerLanguage( target )
	local team = target.GetTeam()
	local playerStateText = "\x01"
	if( !target.IsAlive() )
		playerStateText += gls( "CSSO_PlayerDead", plyLanguage )
	
	local msgColor = "\x07" + CSSO_ChatTeamColors[ team ]
	local teamText = gls( CSSO_ChatTeamStrings[ team ], plyLanguage )
	local playerText = cm_getPlayerName( target )
	local locationText = NetProps.GetPropString( target, "m_szLastPlaceName" )
	
	local newUserText = playerStateText + "\x01(%s1)" + msgColor + " %s2 @ \x04%s3 \x01: %s4"
	printchat( newUserText, target, teamText, playerText, locationText, CSSO_FormattedString( printText ) )
}

// force formatted text to be sent in chat FOR specified player FROM other player IN TEAM CHAT
::saytdm <- function( printText, target, sender )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() )
		return
	
	local senderIndex = sender
	if( typeof( senderIndex ) == "integer" )
		sender = GetPlayerFromUserID( senderIndex )
	
	if( !sender || !sender.IsValid() )
		return
	
	local plyLanguage = cm_getPlayerLanguage( target )
	local team = sender.GetTeam()
	local playerStateText = "\x01"
	if( !sender.IsAlive() )
		playerStateText += gls( "CSSO_PlayerDead", plyLanguage )
	
	local msgColor = "\x07" + CSSO_ChatTeamColors[ team ]
	local teamText = gls( CSSO_ChatTeamStrings[ team ], plyLanguage )
	local playerText = cm_getPlayerName( sender )
	local locationText = NetProps.GetPropString( sender, "m_szLastPlaceName" )
	
	local PMtext = gls( "CSSO_ClientMSG_Private", plyLanguage )
	local newUserText = playerStateText + "\x01(%s1)" + msgColor + " %s2 @ \x04%s3 \x01" + PMtext + ": %s4"
	printchat( newUserText, target, teamText, playerText, locationText, CSSO_FormattedString( printText ) )
}

// force formatted text to be sent in chat FOR ALL players IN TEAM CHAT
::sayt1all <- function( printText )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( !target || !target.IsValid() )
			continue
		
		sayt1( printText, target )
	}
}

// force formatted text to be sent in chat FOR ALL players OF SPECIFIED TEAM IN TEAM CHAT
::sayt1team <- function( printText, team )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() && ply.GetTeam() == team )
			sayt1( printText, ply )
	}
}

// force formatted text to be sent in chat by specified player to everyone IN TEAM CHAT
::sayt2 <- function( printText, target )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() )
		return
	
	local plyLanguage = cm_getPlayerLanguage( target )
	local team = target.GetTeam()
	local playerStateText = "\x01"
	if( !target.IsAlive() )
		playerStateText += gls( "CSSO_PlayerDead", plyLanguage )
	
	local msgColor = "\x07" + CSSO_ChatTeamColors[ team ]
	local teamText = gls( CSSO_ChatTeamStrings[ team ], plyLanguage )
	local playerText = cm_getPlayerName( target )
	local locationText = NetProps.GetPropString( target, "m_szLastPlaceName" )
	
	local newUserText = playerStateText + "\x01(%s1)" + msgColor + " %s2 @ \x04%s3 \x01: %s4"
	printchatall( newUserText, teamText, playerText, locationText, CSSO_FormattedString( printText ) )
}

// force formatted text to be sent in chat to everyone IN TEAM CHAT
::sayt2all <- function( printText )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( !target || !target.IsValid() )
			continue
		
		sayt2( printText, target )
	}
}

// force formatted text to be sent in chat to everyone of specified team IN TEAM CHAT
::sayt2team <- function( printText, team )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() && ply.GetTeam() == team )
			sayt2( printText, ply )
	}
}

// force formatted text to be sent in chat by specified player to team chat
::sayt3 <- function( printText, target )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() )
		return
	
	local plyLanguage = cm_getPlayerLanguage( target )
	local team = target.GetTeam()
	local playerStateText = "\x01"
	if( !target.IsAlive() )
		playerStateText += gls( "CSSO_PlayerDead", plyLanguage )
	
	local msgColor = "\x07" + CSSO_ChatTeamColors[ team ]
	local teamText = gls( CSSO_ChatTeamStrings[ team ], plyLanguage )
	local playerText = cm_getPlayerName( target )
	local locationText = NetProps.GetPropString( target, "m_szLastPlaceName" )
	
	local newUserText = playerStateText + "\x01(%s1)" + msgColor + " %s2 @ \x04%s3 \x01: %s4"
	printchatteam( newUserText, team, teamText, playerText, locationText, CSSO_FormattedString( printText ) )
}

// force formatted text to be sent in chat by everyone to team chat
::sayt3all <- function( printText )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( !target || !target.IsValid() )
			continue
		
		sayt3( printText, target )
	}
}

// force formatted text to be sent in chat by everyone of specified team to team chat
::sayt3team <- function( printText, team )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() && ply.GetTeam() == team )
			sayt3( printText, ply )
	}
}
