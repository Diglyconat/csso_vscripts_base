
// if #SERVER == false then leave
if( !( "SendToConsole" in this ) )
	return

// global script scope be like
::cssoScript <- this

// function to initialize server-side scripts
::csso_vscripts_init <- function()
{	
	if( !Entities.FindByName( null, "cm_server" ) )
	{
		::cm_server <- Entities.CreateByClassname( "point_servercommand" )
		::cm_server.__KeyValueFromString( "targetname", "cm_server" )
		::cm_server.__KeyValueFromString( "classname", "move_rope" )
	}
	
	if( !Entities.FindByName( null, "cm_client" ) )
	{
		::cm_client <- Entities.CreateByClassname( "point_clientcommand" )
		::cm_client.__KeyValueFromString( "targetname", "cm_client" )
		::cm_client.__KeyValueFromString( "classname", "move_rope" )
	}
	
	::mapname <- split( GetMapName(), "/" )
	mapname = mapname[ mapname.len()-1 ]
	
	cm_includeScriptOnce( "csso/includes.nut" )
}

// Override Me!
::OnNewRound <- function(){}

::cm_includeScript <- function( script )
{
	try
	{
		local b = DoIncludeScript( script, this )
		printl( "[VScripts Base] "+script+" is loaded! [" + this + "]" )
		return b
	}
	catch(e){}
	return false
}

::cm_includedScripts <- {}
::cm_includeScriptOnce <- function( script )
{
	if( script in ::cm_includedScripts )
		return
	
	if( cm_includeScript( script ) )
		::cm_includedScripts[ script ] <- this
}

::cm_allocateEntityScope <- function( script )
{
	local ent = Entities.CreateByClassname( "info_target" )
	local targetname = "csso.nut_" + script.slice( 5,script.len() )
	ent.__KeyValueFromString( "targetname", targetname )
	ent.ValidateScriptScope()
	local scope = ent.GetScriptScope()
	scope.cm_include <- cm_includeScript
	scope.cm_include( script )
	cm_includedScripts[ script ] <- scope
	ent.Destroy()
}

// loads VScript file
::addscript <- function( script ){ cm_allocateEntityScope( script ) }

if( !( ::rawin( "VScriptRestartFrame" ) ) )
	::VScriptRestartFrame <- GetFrameCount()

::csso_worldspawn <- Entities.First()
csso_worldspawn.ValidateScriptScope()
::csso_worldspawn_scope <- csso_worldspawn.GetScriptScope()
if( !csso_worldspawn_scope.rawin( "ent_thinkfuncs" ) )
{
	csso_worldspawn.KeyValueFromString( "vscripts", "utility/entity_core.nut" )
	csso_worldspawn.AcceptInput( "RunScriptFile", "utility/entity_core", null, null )
	csso_worldspawn.AcceptInput( "CallScriptFunction", "Init", null, null )
}
else
{
	delete csso_worldspawn_scope[ "ent_thinkdelays" ]
	delete csso_worldspawn_scope[ "ent_thinkfuncs" ]
	
	csso_worldspawn.AcceptInput( "RunScriptFile", "utility/entity_core", null, null )
	csso_worldspawn.AcceptInput( "CallScriptFunction", "Init", null, null )
}

cm_includeScriptOnce( "utility/localization.nut" )
cm_includeScriptOnce( "localization/core.nut" )
cm_includeScriptOnce( "utility/main.nut" )

EntFireByHandle( csso_worldspawn, "RunScriptCode", "csso_vscripts_init()", 0, null, null )
