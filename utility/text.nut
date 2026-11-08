
///////////////////////////////
// COLO(U)RED TEXT FUNCTIONS //
///////////////////////////////

// custom split string function
::CSSO_SplitStr <- function( str, delimiter )
{
	local index = str.find( delimiter )
	if( index == null )
		return [ str ]

	return [ str.slice( 0, index ), str.slice( index + delimiter.len(), str.len() ) ]
}

// replace "oldSubstring" matches with "newSubstring" in "str" text
::CSSO_ReplaceStr <- function( str, oldSubstring, newSubstring )
{
	if( oldSubstring == "" )
		return str

	local result = ""
	local lastIndex = 0
	local index = str.find( oldSubstring )
	while( index != null )
	{
		result += str.slice( lastIndex, index ) + newSubstring
		lastIndex = index + oldSubstring.len()
		index = str.find( oldSubstring, lastIndex )
	}

	result += str.slice( lastIndex )
	return result
}

// check if specified string represents a hex-code (true/false)
::CSSO_IsFormatHexCode <- function( str )
{
	if( str.len() < 6 )
		return false
	
	for( local i = 0; i < 6; i++ )
	{
		local symbToCheck = str.slice( i,i+1 ).tolower()
		if( symbToCheck < "0" || symbToCheck > "f" )
			return false
	}
	
	return true
}

::CSSO_GenerateRandomHexCode <- function()
{
	local hexDigits = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f" ]
	local hexStr = ""
	for( local i = 0; i < 6; i++ )
		hexStr += hexDigits[ RandomInt( 0, hexDigits.len()-1 ) ]
	
	return hexStr
}

::CSSO_SelectRandomHexCode <- function()
{
	local hexIndex = RandomInt( 0, CSSO_ChatColors.len() )
	local hexCurIndex = 0
	foreach( k,v in CSSO_ChatColors )
	{
		if( hexCurIndex == hexIndex )
			return v
		
		hexCurIndex++
	}
	
	return "FFFFFF"
}

::CSSO_ConvertDecToHex <- function( num )
{
	local hexDigits = [ "a", "b", "c", "d", "e", "f" ]
	local resultStr = []
	local val = num
	local valLen = num.tostring().len()
	while( val > 0 )
	{
		local valRem = val % 16
		resultStr.append( valRem > 9 ? hexDigits[ valRem - 10 ] : valRem )
		val /= 16
	}
	
	local resultVar = ""
	foreach( x in resultStr.reverse() )
		resultVar += x
	
	return resultVar
}

::CSSO_ConvertHexToDec <- function( num )
{
	local hexDigits = [ "a", "b", "c", "d", "e", "f" ]
	local resultStr = []
	local val = num
	local valLen = num.tostring().len()
	while( val > 0 )
	{
		local valRem = val % 16
		resultStr.append( valRem > 9 ? hexDigits[ valRem - 10 ] : valRem )
		val /= 16
	}
	
	local resultVar = ""
	foreach( x in resultStr.reverse() )
		resultVar += x
	
	return resultVar
}

::CSSO_ConvertToUnicode <- function( str )
{
	local strSym = []
	foreach( x in str )
		strSym.append( x.tointeger() )
	
	local symCurCount = 0
	local symCount = 0
	local symForm = []
	local resultStr = ""
	foreach( x in strSym )
	{
		if( x > 0 )
		{
			resultStr += format( "\\u%04x", x )
			continue
		}
		
		symCount++
		if( symCount < 2 )
		{
			symForm.append( ( x & 0xFF ) )
			continue
		}
		
		local symAdd = symForm[ symCurCount ]
		symForm[ symCurCount ] = symAdd + (0x2B0) + ( x & 0xFF ) + ( symAdd > 0xD0 ? 63 : 0 )
		symCount = 0
		resultStr += format( "\\u%04s", CSSO_ConvertDecToHex( symForm[ symCurCount ] ) )
		symCurCount++
	}
	
	return resultStr
}

// return formatted string with custom chat colors applied
::CSSO_FormattedString <- function( str )
{
    local formatted = ""
    local index = str.find( "{" )
	if( index == null )
		return str
	
	formatted += format( "\x07%s%s", "FFFFFF", str.slice( 0,index ) )
	local lastIndex = 0
    while( index != null )
	{
		local nextIndex = str.find( "}", index )
		if( nextIndex == null )
			break
		
		local index2 = str.find( "{", nextIndex )
		if( index2 == null )
		{
			local colorStr = str.slice( index + 1, nextIndex ).tolower()
			local nextStrLen = str.slice( nextIndex + 1 ).len()
			if( colorStr in CSSO_ChatColors )
				formatted += format( "\x07%s%s", CSSO_ChatColors[ colorStr ], str.slice( nextIndex + 1 ) )
			else if( CSSO_IsFormatHexCode( colorStr ) == true )
				formatted += format( "\x07%s%s", colorStr, str.slice( nextIndex + 1 ) )
			else if( colorStr == "rnd" )
				formatted += format( "\x07%s%s", CSSO_SelectRandomHexCode(), str.slice( nextIndex + 1 ) )
			else if( colorStr == "random" )
				formatted += format( "\x07%s%s", CSSO_GenerateRandomHexCode(), str.slice( nextIndex + 1 ) )
			else
				formatted += str.slice( index, nextIndex + 1 )
			
			lastIndex = nextIndex + nextStrLen + 1
			index = str.find( "{", lastIndex )
			continue
		}
		
		local colorStr = str.slice( index + 1, nextIndex ).tolower()
		if( colorStr in CSSO_ChatColors )
			formatted += format( "\x07%s%s", CSSO_ChatColors[ colorStr ], str.slice( nextIndex + 1, index2 ) )
		else if( CSSO_IsFormatHexCode( colorStr ) == true )
			formatted += format( "\x07%s%s", colorStr, str.slice( nextIndex + 1, index2 ) )
		else if( colorStr == "rnd" )
			formatted += format( "\x07%s%s", CSSO_SelectRandomHexCode(), str.slice( nextIndex + 1, index2 ) )
		else if( colorStr == "random" )
			formatted += format( "\x07%s%s", CSSO_GenerateRandomHexCode(), str.slice( nextIndex + 1, index2 ) )
		else
			formatted += str.slice( index, nextIndex + 1 )
		
		lastIndex = index
		index = index2
    }
	
	formatted += str.slice( lastIndex )
	return formatted
}

// print formatted text in console for specified player
// "target" parameter supports integer numbers (userid of player, check via "status" console command)
::printconsole <- function( printText, target, param1 = "", param2 = "", param3 = "", param4 = "" )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() )
		return
	
    // print formatted string
    ScriptPrintMessage( target, 2, printText, param1, param2, param3, param4 )
}

// print formatted text in chat for specified player
// "target" parameter supports integer numbers (userid of player, check via "status" console command)
::printchat <- function( printText, target, param1 = "", param2 = "", param3 = "", param4 = "" )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() )
		return
	
    // print formatted string
    ScriptPrintMessage( target, 3, CSSO_FormattedString( printText ), param1, param2, param3, param4 )
}

// print formatted text in center of the screen for specified player
// "target" parameter supports integer numbers (userid of player, check via "status" console command)
::printcenter <- function( printText, target, param1 = "", param2 = "", param3 = "", param4 = "" )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() )
		return
	
    // print formatted string
    ScriptPrintMessage( target, 4, printText, param1, param2, param3, param4 )
}

// print formatted text in chat for ALL PLAYERS
::printchatall <- function( printText, param1 = "", param2 = "", param3 = "", param4 = "" )
{
	ScriptPrintMessageChatAll( CSSO_FormattedString( printText ), param1, param2, param3, param4 )
}

// print formatted text in chat for all players of specified TEAM
::printchatteam <- function( printText, team = -1, param1 = "", param2 = "", param3 = "", param4 = "" )
{
	if( team < 2 || team > 3 )
		return
	
	ScriptPrintMessageChatTeam( team, CSSO_FormattedString( printText ), param1, param2, param3, param4 )
}

// print formatted text in chat for ALL PLAYERS
::printcenterall <- function( printText, param1 = "", param2 = "", param3 = "", param4 = "" )
{
	ScriptPrintMessageCenterAll( CSSO_FormattedString( printText ), param1, param2, param3, param4 )
}

// print formatted text in chat for all players of specified TEAM
::printcenterteam <- function( printText, team = -1, param1 = "", param2 = "", param3 = "", param4 = "" )
{
	if( team < 2 || team > 3 )
		return
	
	ScriptPrintMessageCenterTeam( team, CSSO_FormattedString( printText ), param1, param2, param3, param4 )
}

// force formatted text to be sent in chat FOR specified player
::say1 <- function( printText, target, showName = false )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() )
		return
	
	local team = target.GetTeam()
	if( showName == true )
	{
		local textToAdd = ( target.IsAlive() ? "" : gls( "CSSO_PlayerDead", cm_getPlayerLanguage( target ) ) ) + "{" + CSSO_ChatTeamColors[ team ] + "}" + cm_getPlayerName( target ) + "{FFFFFF} : "
		printText = textToAdd + printText
	}
	
    // send formatted string to everyone in the chat
	printchat( printText, target )
}

// force formatted text to be sent in chat FOR specified player FROM other player
::saydm <- function( printText, target, sender, showName = false )
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
	
	local team = sender.GetTeam()
	if( showName == true )
	{
		local textToAdd = ( sender.IsAlive() ? "" : gls( "CSSO_PlayerDead", cm_getPlayerLanguage( target ) ) ) + "{" + CSSO_ChatTeamColors[ team ] + "}" + cm_getPlayerName( sender ) + "{FFFFFF} : "
		printText = textToAdd + printText
	}
	
    // send formatted string to everyone in the chat
	printchat( gls( "CSSO_ClientMSG_Private", cm_getPlayerLanguage( target ) ) + printText, target )
}

// force formatted text to be sent in chat FOR ALL players
::say1all <- function( printText, showName = false )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( !target || !target.IsValid() )
			continue
		
		say1( printText, target, showName )
	}
}

// force formatted text to be sent in chat FOR ALL players OF SPECIFIED TEAM
::say1team <- function( printText, team, showName = false )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() && ply.GetTeam() == team )
			say1( printText, ply, showName )
	}
}

// force formatted text to be sent in chat by specified player to everyone
::say2 <- function( printText, target, showName = false )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() )
		return
	
	local team = target.GetTeam()
	if( showName == true )
	{
		local textToAdd = ( target.IsAlive() ? "" : gls( "CSSO_PlayerDead", cm_getPlayerLanguage( target ) ) ) + "{" + CSSO_ChatTeamColors[ team ] + "}" + cm_getPlayerName( target ) + "{FFFFFF} : "
		printText = textToAdd + printText
	}
	
    // send formatted string to everyone in the chat
	printchatall( printText )
}

// force formatted text to be sent in chat to everyone
::say2all <- function( printText, showName = false )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( !target || !target.IsValid() )
			continue
		
		say2( printText, target, showName )
	}
}

// force formatted text to be sent in chat to everyone of specified team
::say2team <- function( printText, team, showName = false )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() && ply.GetTeam() == team )
			say2( printText, ply, showName )
	}
}

// force formatted text to be sent in chat by specified player to team chat
::say3 <- function( printText, target, showName = false )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() )
		return
	
	local team = target.GetTeam()
	if( showName == true )
	{
		local textToAdd = ( target.IsAlive() ? "" : gls( "CSSO_PlayerDead", cm_getPlayerLanguage( target ) ) ) + "{" + CSSO_ChatTeamColors[ team ] + "}" + cm_getPlayerName( target ) + "{FFFFFF} : "
		printText = textToAdd + printText
	}
	
    // send formatted string to everyone in the chat
	printchatteam( printText, team )
}

// force formatted text to be sent in chat by everyone to team chat
::say3all <- function( printText, showName = false )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( !target || !target.IsValid() )
			continue
		
		say3( printText, target, showName )
	}
}

// force formatted text to be sent in chat by everyone of specified team to team chat
::say3team <- function( printText, team, showName = false )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() && ply.GetTeam() == team )
			say3( printText, ply, showName )
	}
}

// print formatted text FROM CUSTOM LOCALIZATION STRING in chat for specified player
// "target" parameter supports integer numbers (userid of player, check via "status" console command)
::printfconsole <- function( printText, target, ... )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() )
		return
	
	local plyLanguage = cm_getPlayerLanguage( target )
	local formattedText = gls( printText, plyLanguage )
	if( formattedText )
	{
		local formattedArgs = []
		foreach( textArg in vargv )
		{
			local textArgStr = gls( textArg, plyLanguage )
			if( textArgStr )
				formattedArgs.append( textArgStr )
			else
				formattedArgs.append( textArg )
		}
		
		local strParams = [ this, formattedText ].extend( formattedArgs )
		formattedText = format.acall( strParams )
	}
	else
		formattedText = printText
	
    // print formatted string
    ScriptPrintMessage( target, 2, formattedText )
}

// print formatted text FROM CUSTOM LOCALIZATION STRING in chat for specified player
// "target" parameter supports integer numbers (userid of player, check via "status" console command)
::printfchat <- function( printText, target, ... )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() )
		return
	
	local plyLanguage = cm_getPlayerLanguage( target )
	local formattedText = gls( printText, plyLanguage )
	if( formattedText )
	{
		local formattedArgs = []
		foreach( textArg in vargv )
		{
			local textArgStr = gls( textArg, plyLanguage )
			if( textArgStr )
				formattedArgs.append( textArgStr )
			else
				formattedArgs.append( textArg )
		}
		
		local strParams = [ this, formattedText ].extend( formattedArgs )
		formattedText = CSSO_FormattedString( format.acall( strParams ) )
	}
	else
		formattedText = printText
	
    // print formatted string
    ScriptPrintMessage( target, 3, formattedText )
}

// print formatted text FROM CUSTOM LOCALIZATION STRING in center of the screen for specified player
// "target" parameter supports integer numbers (userid of player, check via "status" console command)
::printfcenter <- function( printText, target, ... )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() )
		return
	
	local plyLanguage = cm_getPlayerLanguage( target )
	local formattedText = gls( printText, plyLanguage )
	if( formattedText )
	{
		local formattedArgs = []
		foreach( textArg in vargv )
		{
			local textArgStr = gls( textArg, plyLanguage )
			if( textArgStr )
				formattedArgs.append( textArgStr )
			else
				formattedArgs.append( textArg )
		}
		
		local strParams = [ this, formattedText ].extend( formattedArgs )
		formattedText = format.acall( strParams )
	}
	else
		formattedText = printText
	
    // print formatted string
    ScriptPrintMessage( target, 4, formattedText )
}

// print formatted text FROM CUSTOM LOCALIZATION STRING in chat for ALL PLAYERS
::printfchatall <- function( printText, ... )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( !ply || !ply.IsValid() )
			continue
		
		local plyLanguage = cm_getPlayerLanguage( ply )
		local formattedText = gls( printText, plyLanguage )
		if( formattedText )
		{
			local formattedArgs = []
			foreach( textArg in vargv )
			{
				local textArgStr = gls( textArg, plyLanguage )
				if( textArgStr )
					formattedArgs.append( textArgStr )
				else
					formattedArgs.append( textArg )
			}
			
			local strParams = [ this, formattedText ].extend( formattedArgs )
			formattedText = CSSO_FormattedString( format.acall( strParams ) )
		}
		else
			formattedText = printText
		
		ScriptPrintMessage( ply, 3, formattedText )
	}
}

// print formatted text FROM CUSTOM LOCALIZATION STRING in chat for all players of specified TEAM
::printfchatteam <- function( printText, team, ... )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( !ply || !ply.IsValid() || ply.GetTeam() != team )
			continue
		
		local plyLanguage = cm_getPlayerLanguage( ply )
		local formattedText = gls( printText, plyLanguage )
		if( formattedText )
		{
			local formattedArgs = []
			foreach( textArg in vargv )
			{
				local textArgStr = gls( textArg, plyLanguage )
				if( textArgStr )
					formattedArgs.append( textArgStr )
				else
					formattedArgs.append( textArg )
			}
			
			local strParams = [ this, formattedText ].extend( formattedArgs )
			formattedText = CSSO_FormattedString( format.acall( strParams ) )
		}
		else
			formattedText = printText
		
		ScriptPrintMessage( ply, 3, formattedText )
	}
}

// print formatted text FROM CUSTOM LOCALIZATION STRING in center of the screen for ALL PLAYERS
::printfcenterall <- function( printText, ... )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( !ply || !ply.IsValid() )
			continue
		
		local plyLanguage = cm_getPlayerLanguage( ply )
		local formattedText = gls( printText, plyLanguage )
		if( formattedText )
		{
			local formattedArgs = []
			foreach( textArg in vargv )
			{
				local textArgStr = gls( textArg, plyLanguage )
				if( textArgStr )
					formattedArgs.append( textArgStr )
				else
					formattedArgs.append( textArg )
			}
			
			local strParams = [ this, formattedText ].extend( formattedArgs )
			formattedText = format.acall( strParams )
		}
		else
			formattedText = printText
		
		ScriptPrintMessage( ply, 4, formattedText )
	}
}

// print formatted text FROM CUSTOM LOCALIZATION STRING in chat for all players of specified TEAM
::printfcenterteam <- function( printText, team, ... )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( !ply || !ply.IsValid() || ply.GetTeam() != team )
			continue
		
		local plyLanguage = cm_getPlayerLanguage( ply )
		local formattedText = gls( printText, plyLanguage )
		if( formattedText )
		{
			local formattedArgs = []
			foreach( textArg in vargv )
			{
				local textArgStr = gls( textArg, plyLanguage )
				if( textArgStr )
					formattedArgs.append( textArgStr )
				else
					formattedArgs.append( textArg )
			}
			
			local strParams = [ this, formattedText ].extend( formattedArgs )
			formattedText = format.acall( strParams )
		}
		else
			formattedText = printText
		
		ScriptPrintMessage( ply, 4, formattedText )
	}
}

// force formatted text to be sent in chat FOR specified player
::sayf1 <- function( printText, target, showName, ... )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() )
		return
	
	local team = target.GetTeam()
	if( showName == true )
	{
		local textToAdd = cm_getPlayerName( target )
		textToAdd = ( target.IsAlive() ? "" : gls( "CSSO_PlayerDead", cm_getPlayerLanguage( target ) ) ) + CSSO_FormattedString( "{" + CSSO_ChatTeamColors[ team ] + "}" + textToAdd + "{FFFFFF} : " )
		printText = textToAdd + printText
	}
	
    // send formatted string to everyone in the chat
	printfchat( printText, target, vargv )
}

// force formatted text to be sent in chat FOR ALL players
::sayf1all <- function( printText, showName, ... )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( !target || !target.IsValid() )
			continue
		
		sayf1( printText, target, showName )
	}
}

// force formatted text to be sent in chat FOR ALL players OF SPECIFIED TEAM
::sayf1team <- function( printText, team, showName, ... )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() && ply.GetTeam() == team )
			sayf1( printText, ply, showName )
	}
}

// force formatted text to be sent in chat by specified player to everyone
::sayf2 <- function( printText, target, showName, ... )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() )
		return
	
	local team = target.GetTeam()
	if( showName == true )
	{
		local textToAdd = cm_getPlayerName( target )
		textToAdd = ( target.IsAlive() ? "" : gls( "CSSO_PlayerDead", cm_getPlayerLanguage( target ) ) ) + CSSO_FormattedString( "{" + CSSO_ChatTeamColors[ team ] + "}" + textToAdd + "{FFFFFF} : " )
		printText = textToAdd + printText
	}
	
    // send formatted string to everyone in the chat
	printfchatall( printText, vargv )
}

// force formatted text to be sent in chat to everyone
::sayf2all <- function( printText, showName, ... )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( !target || !target.IsValid() )
			continue
		
		sayf2( printText, target, showName )
	}
}

// force formatted text to be sent in chat to everyone of specified team
::sayf2team <- function( printText, team, showName, ... )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() && ply.GetTeam() == team )
			sayf2( printText, ply, showName )
	}
}

// force formatted text to be sent in chat by specified player to team chat
::sayf3 <- function( printText, target, showName, ... )
{
	local tgtIndex = target
	if( typeof( tgtIndex ) == "integer" )
		target = GetPlayerFromUserID( tgtIndex )
	
	if( !target || !target.IsValid() )
		return
	
	local team = target.GetTeam()
	if( showName == true )
	{
		local textToAdd = cm_getPlayerName( target )
		textToAdd = ( target.IsAlive() ? "" : gls( "CSSO_PlayerDead", cm_getPlayerLanguage( target ) ) ) + CSSO_FormattedString( "{" + CSSO_ChatTeamColors[ team ] + "}" + textToAdd + "{FFFFFF} : " )
		printText = textToAdd + printText
	}
	
    // send formatted string to everyone in the chat
	printfchatteam( printText, team, vargv )
}

// force formatted text to be sent in chat by everyone to team chat
::sayf3all <- function( printText, showName, ... )
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local target = PlayerInstanceFromIndex( i )
		if( !target || !target.IsValid() )
			continue
		
		sayf3( printText, target, showName )
	}
}

// force formatted text to be sent in chat by everyone of specified team to team chat
::sayf3team <- function( printText, team, showName, ... )
{
	if( team < 2 || team > 3 )
		return
	
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( ply && ply.IsValid() && ply.GetTeam() == team )
			sayf3( printText, ply, showName )
	}
}
