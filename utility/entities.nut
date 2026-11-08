
//////////////////////
// ENTITY FUNCTIONS //
//////////////////////

// removes all values from entity's script scope
::cm_clearScriptScope <- function( scope, target = null )
{
	foreach( k,v in scope )
	{
		if( k == "__vname" || k == "__vrefs" || k == "self" || k == "parent" )
			continue
		
		// destroy script scope entities if found
		if( typeof( v ) == "instance" && v != null && v.IsValid() && v.GetMoveParent() != target )
		{
			printl( v )
			v.Destroy()
		}
		
		delete scope[ k ]
	}
}

// creates new script scope for entity (if previously it didn't exist)
::cm_resetEntityScriptScope <- function( target )
{
	if( !target || !target.IsValid() )
		return
	
	target.ValidateScriptScope()
	cm_clearScriptScope( target.GetScriptScope(), target )
}

// validates script scope for entity, creates new script scope if previously it didn't exist
// allocates specified key values table for entity's script scope
// "initFunc" is used for internal script scope init call, no external parameters can pass
// function returns validated entity's script scope
::cm_allocateEntityScriptScope <- function( target, scopeTable = null, initFunc = null )
{
	if( !target || !target.IsValid() )
		return
	
	target.ValidateScriptScope()
	local scope = target.GetScriptScope()
	if( scopeTable == null || scopeTable.len() < 1 )
		return scope
	
	local initRequired = true
	foreach( k,v in scopeTable )
	{
		if( !scope.rawin( k ) )
			scope[ k ] <- v
		else
			initRequired = false
	}
	
	if( initFunc != null && initRequired )
		initFunc()
	
	return scope
}

// returns vector representing at which position the specified entity is "looking" at
::cm_getEntityLookatPoint <- function( target, maxLookatDist = 16384 )
{
	if( !target || !target.IsValid() || !target.IsAlive() )
		return null
	
	local dir = target.GetAbsAngles().Forward()
	if( maxLookatDist <= 0.0 )
		return dir
	
	local startOrg = target.EyePosition()
	local traceOrg = startOrg + dir * maxLookatDist
	local trFrac = TraceLinePlayersIncluded( startOrg + dir, traceOrg, target )
	local newOrigin = startOrg + ( traceOrg - startOrg ) * trFrac
	return newOrigin
}

::cm_purgeStr <- function( target )
{
	if( !target || !target.IsValid() )
		return
	
	cm_allocateEntityScriptScope( target,
		{ m_bForcePurgeFixedupStrings = true },
		function( ent = target ){ NetProps.SetPropBool( target, "m_bForcePurgeFixedupStrings", true ) } )
}

local PostInputFunc = null
::SetInputHook <- function( entity, input, pre_func, post_func )
{
	entity.ValidateScriptScope()
	local scope = entity.GetScriptScope()
	if( post_func )
	{
		post_func = post_func.bindenv( scope )
		local wrapper_func
		if( pre_func )
		{
			pre_func = pre_func.bindenv( scope )
			wrapper_func = function()
			{
				PostInputFunc = post_func
				return pre_func()
			}
		}
		else
		{
			wrapper_func = function()
			{
				PostInputFunc = post_func
				return true
			}
		}

		scope[ "Input" + input ] <- wrapper_func
		scope[ "Input" + input.tolower() ] <- wrapper_func
	}
	else if( pre_func )
	{
		scope[ "Input" + input ] <- pre_func
		scope[ "Input" + input.tolower() ] <- pre_func
	}
}

getroottable().setdelegate(
{
	_delslot = function( key )
	{
		if( !( key in this ) )
			throw format( "the index '%s' does not exist", key )

		if( PostInputFunc && key == "activator" )
		{
			PostInputFunc()
			PostInputFunc = null
		}

		return rawdelete( key )
	}
})

::SetEntityDestroyCallback <- function( entity, callback )
{
	entity.ValidateScriptScope()
	local scope = entity.GetScriptScope()
	scope.setdelegate({}.setdelegate({
			parent   = scope.getdelegate()
			id       = entity.GetScriptId()
			index    = entity.entindex()
			callback = callback
			_get = function( k )
			{
				return parent[ k ]
			}
			_delslot = function( k )
			{
				if( k == id )
				{
					entity = EntIndexToHScript( index )
					local scope = entity.GetScriptScope()
					if( scope )
					{
						scope.self <- entity
						callback.pcall( scope )
					}
				}
				delete parent[ k ]
			}
		})
	)
}

if( !( ::rawin( "CSSO_AnimationData" ) ) )
	::CSSO_AnimationData <- {}

::GetEntAnimationData <- function( ent )
{
	if( !ent || !ent.IsValid() )
		return null
	
	local entMDL = ent.GetModelName()
	if( !( entMDL in CSSO_AnimationData ) )
	{
		local ent_animData = {}
		ent_animData[ "sequences" ] <- []
		local bMissingAnim = false
		local nSequenceNum = 0
		while( !bMissingAnim )
		{
			local seq = ent.GetSequenceName( nSequenceNum )
			if( seq == "Not Found!" || seq == "Unknown" || seq == "No model!" )
			{
				bMissingAnim = true
				break
			}
			
			local seqActName = ent.GetSequenceActivityName( nSequenceNum )
			if( seqActName.len() <= 0 )
				seqActName = null
			
			ent_animData[ "sequences" ].append( { name = seq, activity = seqActName, sequence = nSequenceNum } )
			nSequenceNum++
		}
		
		CSSO_AnimationData[ entMDL ] <- ent_animData
	}
	
	return CSSO_AnimationData[ entMDL ]
}

::cm_addThinkFuncToEnt <- function( target, thinkFuncName, thinkDelay = -1, thinkFunc = null )
{
    if( !target || !target.IsValid() )
        return
	
	local scope = cm_allocateEntityScriptScope( target, { ent_thinkfuncs = null, ent_thinkdelays = null }, function( ent = target )
		{
			ent.KeyValueFromString( "vscripts", "utility/entity_core.nut" )
			ent.AcceptInput( "RunScriptFile", "utility/entity_core", null, null )
			ent.AcceptInput( "CallScriptFunction", "Init", null, null )
		} )
	
	if( thinkFunc != null && typeof( thinkFunc ) == "function" )
	{
		scope.ent_thinkfuncs[ thinkFuncName ] <- thinkFunc
		scope.ent_thinkdelays[ thinkFuncName ] <- { trigger_time = Time() + thinkDelay, delay = thinkDelay }
	}
}

::cm_addThinkFuncToPlayer <- function( target, thinkFuncName, thinkDelay = -1, thinkFunc = null )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	cm_addThinkFuncToEnt( target, thinkFuncName, thinkDelay, thinkFunc )
}

::cm_removeThinkFuncFromEnt <- function( target, thinkFuncName )
{
	if( !target || !target.IsValid() )
        return
	
	local scope = cm_allocateEntityScriptScope( target, { ent_thinkfuncs = null }, function( ent = target )
		{
			ent.KeyValueFromString( "vscripts", "utility/entity_core.nut" )
			ent.AcceptInput( "RunScriptFile", "utility/entity_core", null, null )
			ent.AcceptInput( "CallScriptFunction", "Init", null, null )
		} )
	
	if( !scope.rawin( "ent_thinkfuncs" ) || !( thinkFuncName in scope.ent_thinkfuncs ) )
		return
	
	delete scope.ent_thinkfuncs[ thinkFuncName ]
	delete scope.ent_thinkdelays[ thinkFuncName ]
}

::cm_removeThinkFuncFromPlayer <- function( target, thinkFuncName )
{
	local userIndex = target
    if( typeof( userIndex ) == "integer" )
        target = GetPlayerFromUserID( userIndex )
	
	cm_removeThinkFuncFromEnt( target, thinkFuncName )
}

::cm_addInputCallback <- function( ent, inputName, callbackFunc ){ SetInputHook( ent, inputName, callbackFunc, null ) }

::cm_convertNetPropData <- function( table )
{
    if( type( table ) == "array" )
	{
		foreach( elem in table )
		{
			local npType = type( elem )
			if( !npType )
				npType = instance
			
			switch( npType )
			{
				case "table":
					cm_convertNetPropData( elem )
					break
				
				case "array":
					cm_convertNetPropData( elem )
					break
				
				default:
					table[ key ] = npType
					break
			}
		}
	}
	
	foreach( key,value in table )
    {
        local npType = type( value )
		if( !npType )
			npType = instance
		
		switch( npType )
        {
            case "table":
				cm_convertNetPropData( value )
                break
			
            case "array":
				cm_convertNetPropData( value )
                break
			
            default:
				table[ key ] = npType
                break
        }
	}
	
	return table
}

::cm_dumpEntityNetProps <- function( target, saveToFile = false )
{
	if( !target || !target.IsValid() )
		return
	
	cm_purgeStr( target )
	local netPropData = {}
	NetProps.GetTable( target, 0, netPropData )
	
	local convertedTable = cm_convertNetPropData( netPropData )
	if( saveToFile )
	{
		local entClass = target.GetClassname()
		StringToFile( "csso/entity_netprops/" + entClass + ".txt", TableToString( convertedTable, null, 1 ) )
		printl( "Entity \"" + entClass + "\" NetProps have been printed to: \"csso/entity_netprops/" + entClass + ".txt\"" )
	}
	else
	{
		printl( "Entity \"" + target.GetClassname() + "\" NetProps:" )
		PrintTableString( convertedTable, 1 )
	}
}

::cm_dumpEntityDataMaps <- function( target, saveToFile = false )
{
	if( !target || !target.IsValid() )
		return
	
	cm_purgeStr( target )
	local netPropData = {}
	NetProps.GetTable( target, 1, netPropData )
	
	local convertedTable = cm_convertNetPropData( netPropData )
	if( saveToFile )
	{
		local entClass = target.GetClassname()
		StringToFile( "csso/entity_datamaps/" + entClass + ".txt", TableToString( convertedTable, null, 1 ) )
		printl( "Entity \"" + entClass + "\" Data Maps have been printed to: \"csso/entity_datamaps/" + entClass + ".txt\"" )
	}
	else
	{
		printl( "Entity \"" + target.GetClassname() + "\" Data Maps:" )
		PrintTableString( convertedTable, 1 )
	}
}

::AddServerThink <- function( thinkFuncName, thinkDelay = -1, thinkFunc = null )
{
	if( !csso_worldspawn_scope.rawin( "ent_thinkfuncs" ) )
	{
		csso_worldspawn.KeyValueFromString( "vscripts", "utility/entity_core.nut" )
		csso_worldspawn.AcceptInput( "RunScriptFile", "utility/entity_core", null, null )
		csso_worldspawn.AcceptInput( "CallScriptFunction", "Init", null, null )
	}
	
	if( thinkFunc != null && typeof( thinkFunc ) == "function" )
	{
		csso_worldspawn_scope.ent_thinkfuncs[ thinkFuncName ] <- thinkFunc
		csso_worldspawn_scope.ent_thinkdelays[ thinkFuncName ] <- { trigger_time = Time() + thinkDelay, delay = thinkDelay }
	}
}

::RemoveServerThink <- function( thinkFuncName )
{
	if( !csso_worldspawn_scope.rawin( "ent_thinkfuncs" ) || !( thinkFuncName in csso_worldspawn_scope.ent_thinkfuncs ) )
		return
	
	delete csso_worldspawn_scope.ent_thinkfuncs[ thinkFuncName ]
	if( thinkFuncName in csso_worldspawn_scope.ent_thinkdelays )
		delete csso_worldspawn_scope.ent_thinkdelays[ thinkFuncName ]
}

::GetEntProp <- function( ent, netpropName )
{
	if( !NetProps.HasProp( ent, netpropName ) )
		return null
	
	local netpropType = NetProps.GetPropType( ent, netpropName )
	if( netpropType != null )
		netpropType = netpropType.tolower()
	
	local npSize = NetProps.GetPropArraySize( ent, netpropName )
	if( npSize > 1 )
	{
		local npArray = []
		switch( netpropType )
		{
			case "bool":
				for( local i = 0; i < npSize; i++ )
					npArray.append( NetProps.GetPropBoolArray( ent, netpropName, i ) )
				
				return npArray
				break
			
			case "integer":
				for( local i = 0; i < npSize; i++ )
					npArray.append( NetProps.GetPropIntArray( ent, netpropName, i ) )
				
				return npArray
				break
			
			case "float":
				for( local i = 0; i < npSize; i++ )
					npArray.append( NetProps.GetPropFloatArray( ent, netpropName, i ) )
				
				return npArray
				break
			
			case "string":
				for( local i = 0; i < npSize; i++ )
					npArray.append( NetProps.GetPropStringArray( ent, netpropName, i ) )
				
				return npArray
				break
			
			case "vector":
				for( local i = 0; i < npSize; i++ )
					npArray.append( NetProps.GetPropVectorArray( ent, netpropName, i ) )
				
				return npArray
				break
			
			case "instance":
				for( local i = 0; i < npSize; i++ )
					npArray.append( NetProps.GetPropEntityArray( ent, netpropName, i ) )
				
				return npArray
				break
		}
		
		return
	}
	
	switch( netpropType )
	{
		case "bool":
			return NetProps.GetPropBool( ent, netpropName )
			break
		
		case "integer":
			return NetProps.GetPropInt( ent, netpropName )
			break
		
		case "float":
			return NetProps.GetPropFloat( ent, netpropName )
			break
		
		case "string":
			return NetProps.GetPropString( ent, netpropName )
			break
		
		case "vector":
			return NetProps.GetPropVector( ent, netpropName )
			break
		
		case "instance":
			return NetProps.GetPropEntity( ent, netpropName )
			break
	}
}

::SetEntProp <- function( ent, netpropName, netpropValue, netpropIndex = 0 )
{
	if( !NetProps.HasProp( ent, netpropName ) )
		return
	
	local netpropType = NetProps.GetPropType( ent, netpropName )
	if( netpropType != null )
		netpropType = netpropType.tolower()
	
	if( netpropValue != null && typeof( netpropValue ) != netpropType )
		return
	
	local npSize = NetProps.GetPropArraySize( ent, netpropName )
	if( npSize > 1 )
	{
		switch( netpropType )
		{
			case "bool":
				NetProps.SetPropBoolArray( ent, netpropName, netpropValue, netpropIndex )
				break
			
			case "integer":
				NetProps.SetPropIntArray( ent, netpropName, netpropValue, netpropIndex )
				break
			
			case "float":
				NetProps.SetPropFloatArray( ent, netpropName, netpropValue, netpropIndex )
				break
			
			case "string":
				NetProps.SetPropStringArray( ent, netpropName, netpropValue, netpropIndex )
				break
			
			case "vector":
				NetProps.SetPropStringArray( ent, netpropName, netpropValue, netpropIndex )
				break
			
			case "instance":
				NetProps.SetPropEntityArray( ent, netpropName, netpropValue, netpropIndex )
				break
		}
		
		return
	}
	
	switch( netpropType )
	{
		case "bool":
			NetProps.SetPropBool( ent, netpropName, netpropValue )
			break
		
		case "integer":
			NetProps.SetPropInt( ent, netpropName, netpropValue )
			break
		
		case "float":
			NetProps.SetPropFloat( ent, netpropName, netpropValue )
			break
		
		case "string":
			NetProps.SetPropString( ent, netpropName, netpropValue )
			break
		
		case "vector":
			NetProps.SetPropVector( ent, netpropName, netpropValue )
			break
		
		case "instance":
			NetProps.SetPropEntity( ent, netpropName, netpropValue )
			break
	}
}

::SetKeyValue <- function( ent, kvData )
{
	local kvEntIndex = ent
    if( typeof( kvEntIndex ) == "integer" )
        ent = EntIndexToHScript( kvEntIndex )
	
	if( !ent || !ent.IsValid() || !kvData )
		return
	
	local kvDataType = typeof( kvData )
	if( !cm_inArray( kvDataType, [ "string", "table" ] ) )
		return
	
	if( kvDataType == "string" )
	{
		local kvList = split( kvData, "," )
		if( !kvList || kvList.len() < 1 )
			return
		
		foreach( x in kvList )
		{
			try
			{
				//local kvStr = CSSO_ReplaceStr( strip( x ), " ", "" ).tolower()
				local kvStr = strip( x ).tolower()
				local kvArr = split( kvStr, "=" )
				if( !kvArr || kvArr.len() < 1 )
					continue
				
				local kvNewKey = CSSO_ReplaceStr( kvArr[ 0 ], " ", "" ).tolower()
				local kvValArr = split( kvArr[ 1 ], " " )
				local kvCleanArr = kvValArr.filter( function( index, value ){ return ( value != "" ) } )
				local kvNewVal = ""
				if( kvCleanArr.len() > 1 )
				{
					kvNewVal = "("
					foreach( y in kvCleanArr )
						kvNewVal += CSSO_ReplaceStr( y, " ", "" ).tolower() + " "
					
					kvNewVal = kvNewVal.slice( 0,kvNewVal.len()-1 ) + ")"
				}
				else kvNewVal = CSSO_ReplaceStr( kvArr[ 1 ], " ", "" ).tolower()
				ent.KeyValueFromString( kvNewKey, kvNewVal )
			}
			catch(e){ continue }
		}
		
		return
	}
	
	if( kvDataType == "table" )
	{
		foreach( k,v in kvData )
		{
			local kvValType = typeof( v )
			if( !cm_inArray( kvValType, [ "integer", "float", "string", "vector" ] ) )
				continue
			
			ent.KeyValueFromString( k,v.tostring() )
		}
	}
}
