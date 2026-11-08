
////////////////////////////
// VSCRIPTS DEV FUNCTIONS //
////////////////////////////

// reload VScript by name (or by part of the name)
::rs <- function( scrName )
{	
	local pathName = null
	foreach( k,v in cm_includedScripts )
	{
		if( k.find( scrName ) )
		{
			pathName = k
			break
		}
	}
	
	if( !pathName )
	{
		printl( "[VScripts Base] Couldn't find any loaded script corresponding to your query." )
		return
	}
	
	local scope = cm_includedScripts[ pathName ]
	/*local parent = scope.getdelegate()
	if( parent )
		EntFireByHandle( parent, "RunScriptCode", "DoIncludeScript(\""+pathName+"\",this)" )
	else*/
		DoIncludeScript( pathName, scope )
	
	printl( "[VScripts Base] "+pathName+" перезапущен! [" + this + "]" )
}

// reload all VScripts at once
::rsa <- function()
{
	local frameCount = GetFrameCount()
	if( VScriptRestartFrame >= frameCount )
		return
	
	DoIncludeScript( "main/server.nut", null )
	VScriptRestartFrame = frameCount
}

// dump currently loaded VScripts
::dcs <- function( entity = false )
{
	foreach( k,v in cm_includedScripts )
	{
		if( entity && !( "self" in v ) )
			continue
		
		local scope = ( v == cssoScript ) ? v+" - ( cssoScript )" : v
		
		printl( ". " + k.toupper() + "    scope:  " + scope )
		if ( "self" in v ) printl( "    - Entity:    " + v.self )
	}
	
	printl()
}

// Dump Scope contents
::ds <- function( scope )
{
	printl()
	__DumpScope( 1, scope )
	printl()
}

// load VScript file (automatically gets added to VScripts list)
::ls <- function( script ){ cm_includeScript( script ) }

// load VScript file once (automatically gets added to VScripts list)
::lso <- function( script ){ cm_includeScriptOnce( script ) }

// restart game session on current map
::restart <- function(){ cm_serverCMD( "changelevel " + mapname ) }