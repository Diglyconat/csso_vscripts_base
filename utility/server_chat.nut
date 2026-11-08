
///////////////////////////////
//       FORMATTED CHAT      //
///////////////////////////////

/*
	HOW IT WORKS:
	
	Displays custom formatted text in chat for everyone OR specified player by "userid" value ([userid] value can be found via "status" console command).
	To specify the player/bot, for which the message should be sent, make sure the message has the following format:
	"[userid]<MESSAGE>"
	This will send the specified message for specified player/bot ONLY.
	
	To send the message via specified player/bot to EVERYONE, make sure the message has the following format:
	"[*userid]<MESSAGE>"
	The "*" symbol before "userid" marks that this message will be sent to EVERYONE in the chat.
	
	To send the message to specified player/bot's TEAM, make sure the message has the following format:
	"[!userid]<MESSAGE>"
	The "!" symbol before "userid" marks that this message will be sent to player/bot's TEAM instead of everyone.
	
	For proper text display with custom colors use "" brackets! EXAMPLE:
	"[2][team]{FF0000}BAN!"
	
	To send the message via EVERYONE, make sure the message has the following format:
	"[.]<MESSAGE>"
	The "." symbol inside [ ] marks that this message will be sent via EVERYONE.
	Symbols "!" and "*" before "." can also be used to send the message to their TEAM or EVERYONE in the chat!
	
	To send the message via players/bots of desired TEAM (either CT or T), make sure the message has the following format:
	FOR TERRORISTS: "[-]<MESSAGE>"
	FOR COUNTER-TERRORISTS: "[+]<MESSAGE>"
	Symbols "!" and "*" before "+" or "-" can also be used to send the message to their TEAM or EVERYONE in the chat!
*/

::CSSO_PlayerDisconnectReasons <- {
	kick = "CSSO_ServerLeaveReason_Kick", 
	ban = "CSSO_ServerLeaveReason_Ban", 
	cheat = "CSSO_ServerLeaveReason_Cheat", 
	error = "CSSO_ServerLeaveReason_Error"
}

AddEventCallback( "player_spawn", "CSSO_ServerChat_OnPlayerSpawn", function( params )
{
	local player = GetPlayerFromUserID( params.userid )
	if( !player || !player.IsValid() || IsPlayerABot( player ) || player.GetTeam() != TEAM_UNASSIGNED )
		return
	
	printfchatall( "CSSO_ServerIntroMessage", cm_getPlayerName( player ) )
	printfchat( "CSSO_ServerIntro_cmdlist", player )
	printfchat( "CSSO_ServerIntro_cmdlist_full", player )
	printfchat( "CSSO_ServerIntro_cmdhelp", player )
})

AddEventCallback( "player_disconnect", "CSSO_ServerChat_OnPlayerDisconnect", function( params )
{
	if( params.bot > 0 )
		return
	
	local disconnectName = params.name
	local disconnectReason = params.reason
	if( disconnectReason == "self" )
	{
		printfchatall( "CSSO_ServerLeaveMessage", disconnectName )
		return
	}
	
	printfchatall( "CSSO_ServerLeaveMessageReason", disconnectName, ( disconnectReason in CSSO_PlayerDisconnectReasons ) ? CSSO_PlayerDisconnectReasons[ disconnectReason ] : ( "{darksalmon}" + disconnectReason ) )
})

AddEventCallback( "player_team", "CSSO_ServerChat_OnPlayerChangeTeam", function( params )
{
	local player = GetPlayerFromUserID( params.userid )
	if( !player || !player.IsValid() || IsPlayerABot( player ) )
		return
	
	local team = params.team
	local teamChangeStr = "CSSO_ServerJoinTeam"
	if( params.oldteam != team )
		teamChangeStr = "CSSO_ServerChangeTeam"
	
	local teamPlayerName = params.name
	switch( team )
	{
		case 1:
			printfchatall( teamChangeStr, teamPlayerName, "CSSO_ServerChangeTeam_Spectators" )
			break
		
		case 2:
			printfchatall( teamChangeStr, teamPlayerName, "CSSO_ServerChangeTeam_Terrorists" )
			break
		
		case 3:
			printfchatall( teamChangeStr, teamPlayerName, "CSSO_ServerChangeTeam_CounterTerrorists" )
			break
		
		default:
			break
	}
})

AddHookCallback( "CheckChatText", "CSSO_ServerChat_OnPlayerSay", function( params )
{
	local player = params.const_entity
	if( !player || !player.IsValid() )
		return
	
	local isTeamChat = params.const_is_team
	local userText = params.const_chat_text
	local userValue = null
	local chatVal = split( userText, " " )
	if( !( chatVal[ 0 ] in CSSO_ChatCommands ) )
	{
		// ensure the formatted text print function works only if "[userid]" is first in the string
		local userSym1 = userText.find( "[" )
		if( userSym1 == null || userSym1 > 0 )
		{
			if( isTeamChat )
				sayt2( userText, player )
			else
				say2( userText, player, true )
			
			params.early_out = true
			return
		}
		
		local userSym2 = userText.find( "]", userSym1 )
		if( userSym2 == null || userSym2 - userSym1 < 2 )
		{
			if( isTeamChat )
				sayt2( userText, player )
			else
				say2( userText, player, true )
			params.early_out = true
			return
		}
		
		local everyoneSym = userText.find( "*", userSym1 )
		local teamSym = userText.find( "!", userSym1 )
		
		local chatTarget = null
		local chatTargetIndexStart = userSym1 + 1
		if( everyoneSym != null )
			chatTargetIndexStart = everyoneSym + 1
		else if( teamSym != null )
			chatTargetIndexStart = teamSym + 1
		
		// host-only chat features
		if( player == gpf() )
		{
			local chatTargetStr = userText.slice( chatTargetIndexStart, userSym2 ).tolower()
			if( chatTargetStr == "." )
			{
				if( everyoneSym != null )
				{
					if( isTeamChat )
						sayt2all( userText.slice( userSym2 + 1 ) )
					else
						say2all( userText.slice( userSym2 + 1 ), true )
				}
				else if( teamSym != null )
				{
					if( isTeamChat )
						sayt3all( userText.slice( userSym2 + 1 ) )
					else
						say3all( userText.slice( userSym2 + 1 ), true )
				}
				else
				{
					if( isTeamChat )
						sayt1all( userText.slice( userSym2 + 1 ) )
					else
						say1all( userText.slice( userSym2 + 1 ), true )
				}
				
				params.early_out = true
				return
			}
			
			if( chatTargetStr == "-" )
			{
				if( everyoneSym != null )
				{
					if( isTeamChat )
						sayt2team( userText.slice( userSym2 + 1 ), 2 )
					else
						say2team( userText.slice( userSym2 + 1 ), 2, true )
				}
				else if( teamSym != null )
				{
					if( isTeamChat )
						sayt3team( userText.slice( userSym2 + 1 ), 2 )
					else
						say3team( userText.slice( userSym2 + 1 ), 2, true )
				}
				else
				{
					if( isTeamChat )
						sayt1team( userText.slice( userSym2 + 1 ), 2 )
					else
						say1team( userText.slice( userSym2 + 1 ), 2, true )
				}
				
				params.early_out = true
				return
			}
			
			if( chatTargetStr == "+" )
			{
				if( everyoneSym != null )
				{
					if( isTeamChat )
						sayt2team( userText.slice( userSym2 + 1 ), 3 )
					else
						say2team( userText.slice( userSym2 + 1 ), 3, true )
				}
				else if( teamSym != null )
				{
					if( isTeamChat )
						sayt3team( userText.slice( userSym2 + 1 ), 3 )
					else
						say3team( userText.slice( userSym2 + 1 ), 3, true )
				}
				else
				{
					if( isTeamChat )
						sayt1team( userText.slice( userSym2 + 1 ), 3 )
					else
						say1team( userText.slice( userSym2 + 1 ), 3, true )
				}
				
				params.early_out = true
				return
			}
			
			try
			{
				local chatTargetIndex = chatTargetStr.tointeger()
				chatTarget = GetPlayerFromUserID( chatTargetIndex )
			}
			catch(e)
			{
				params.early_out = true
				return
			}
			
			if( !chatTarget || !chatTarget.IsValid() )
			{
				params.early_out = true
				return
			}
			
			if( everyoneSym != null )
			{
				if( isTeamChat )
					sayt2( userText.slice( userSym2 + 1 ), chatTarget )
				else
					say2( userText.slice( userSym2 + 1 ), chatTarget, true )
				
				params.early_out = true
				return
			}
			
			if( teamSym != null )
			{
				if( isTeamChat )
					sayt3( userText.slice( userSym2 + 1 ), chatTarget )
				else
					say3( userText.slice( userSym2 + 1 ), chatTarget, true )
				
				params.early_out = true
				return
			}
		}
		
		try
		{
			local chatTargetStr = userText.slice( chatTargetIndexStart, userSym2 ).tolower()
			local chatTargetIndex = chatTargetStr.tointeger()
			chatTarget = GetPlayerFromUserID( chatTargetIndex )
		}
		catch(e)
		{
			params.early_out = true
			return
		}
		
		if( isTeamChat )
			saytdm( userText.slice( userSym2 + 1 ), chatTarget, player )
		else
			saydm( userText.slice( userSym2 + 1 ), chatTarget, player, true )
		
		params.early_out = true
		return
	}
	
	if( chatVal.len() > 1 )
	{
		userValue = ""
		for( local i = 1; i < chatVal.len(); i++ )
			userValue += chatVal[ i ] + " "
		
		userValue = userValue.slice( 0, userValue.len()-1 )
	}
	
	try
	{
		CSSO_ChatCommands[ chatVal[ 0 ] ][ "callback" ]( player, userValue )
		params.early_out = true
	}
	catch(e){}
})

AddChatCommand( "!cmdlist", function( target, value = null )
{
	if( !target || !target.IsValid() )
		return
	
	local plyLanguage = cm_getPlayerLanguage( target )
	local hasDesc = false
	local fullDesc = value == "full"
	foreach( k,v in CSSO_ChatCommands )
	{
		if( !( "desc" in v ) )
			continue
		
		if( !hasDesc )
		{
			hasDesc = true
			printfchat( "CSSO_ServerIntroCommands", target )
		}
		
		local cmdDesc = v[ "desc" ]
		if( !cmdDesc )
			continue
		
		if( !fullDesc )
		{
			printchat( "{yellowgreen}" + k, target )
			continue
		}
		
		local cmdStr = gls( cmdDesc, plyLanguage )
		printchat( "{yellowgreen}" + k + "{white} - " + ( cmdStr != null ? cmdStr : cmdDesc ), target )
	}
}, "CSSO_ChatCommand_cmdlist" )

AddChatCommand( "!cmdhelp", function( target, value = null )
{
	if( !target || !target.IsValid() || !value )
		return
	
	local plyLanguage = cm_getPlayerLanguage( target )
	local hasDesc = false
	local strValue = "!" + CSSO_ReplaceStr( value, "!", "" )
	if( !( strValue in CSSO_ChatCommands ) )
		return
	
	local cmdDesc = CSSO_ChatCommands[ strValue ]
	if( !( "desc" in cmdDesc ) )
		return
	
	local cmdDescStr = cmdDesc[ "desc" ]
	local cmdStr = gls( cmdDescStr, plyLanguage )
	printchat( "\n{yellowgreen}" + strValue + "{white} - " + ( cmdStr != null ? cmdStr : cmdDescStr ), target )
}, "CSSO_ChatCommand_cmdhelp" )

AddChatCommand( "!chathelp", function( target, value = null )
{
	if( !target || !target.IsValid() )
		return
	
	printfchat( "CSSO_ChatCommand_chathelp", target )
	if( target != gpf() )
		return
	
	local plyChatMessages = [
		"CSSO_AdminChatHelp_everyone", 
		"CSSO_AdminChatHelp_team", 
		"CSSO_AdminChatHelp_team2", 
		"CSSO_AdminChatHelp_all", 
	]
	foreach( pcm in plyChatMessages )
		printfchat( pcm, target )
	
}, "CSSO_ChatCommand_chathelp" )

CSSOEvent( "new_round", "CSSO_ServerChat_OnNewRound", function()
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( !ply || !ply.IsValid() || IsPlayerABot( ply ) )
			continue
		
		printfchat( "CSSO_ServerIntro_cmdlist", ply )
		printfchat( "CSSO_ServerIntro_cmdlist_full", ply )
		printfchat( "CSSO_ServerIntro_cmdhelp", ply )
	}
} )
