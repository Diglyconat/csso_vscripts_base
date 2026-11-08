
////////////////////////////////
// CUSTOM SERVER CONVAR FUNCS //
////////////////////////////////

::ConvarsList <- {}
local cvarsTable = FileToTable( "csso/server_cvars.nut" )
if( cvarsTable != null )
	ConvarsList = cvarsTable

::AddCvar <- function( szCvarName, szCvarValue, iCvarFlags, szCvarDesc, bCvarClampMin, cvarValueMin, bCvarClampMax, cvarValueMax )
{
	if( !( szCvarName in ConvarsList ) )
		ConvarsList[ szCvarName ] <- szCvarValue
	else szCvarValue = ConvarsList[ szCvarName ]
	
	Convars.Create( szCvarName, szCvarValue, iCvarFlags, szCvarDesc, bCvarClampMin, cvarValueMin, bCvarClampMax, cvarValueMax )
}

CSSOEvent( "server_preshutdown", "CSSO_Convars_OnServerPreShutdown", function()
{
	local cvarData = TableToString( ConvarsList, null, 1 )
	StringToFile( "csso/server_cvars.nut", cvarData )
} )

AddServerThink( "CSSO_ServerThink_Convars", -1, function()
{
	foreach( cvarName,cvarValue in ConvarsList )
	{
		if( !Convars.IsConVarOnAllowList( cvarName ) )
			continue
		
		local newCvarValue = Convars.GetStr( cvarName )
		if( newCvarValue != cvarValue )
		{
			ConvarsList[ cvarName ] = newCvarValue
			Convars.SetValue( cvarName, newCvarValue )
		}
	}
} )