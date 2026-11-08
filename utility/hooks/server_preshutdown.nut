
//////////////////////////////
// SERVER PRE-SHUTDOWN HOOK //
//////////////////////////////

/*
	HOW IT WORKS:
	Each time the "server_preshutdown" event is triggered, NO data is sent to event's callback function.
*/

CSSO_AddCustomEvent( "server_preshutdown" )
csso_worldspawn_scope.ServerPreShutdown <- function(){ CSSO_TriggerGameEvent( "server_preshutdown" ) }
csso_worldspawn_scope.setdelegate({}.setdelegate({
		parent   = csso_worldspawn_scope.getdelegate()
		id       = csso_worldspawn.GetScriptId()
		index    = csso_worldspawn.entindex()
		callback = csso_worldspawn_scope.ServerPreShutdown
		_get = function( k )
		{
			return parent[ k ]
		}
		_delslot = function( k )
		{
			if( k == id )
			{
				callback.pcall( csso_worldspawn_scope )
			}
			delete parent[ k ]
		}
	})
)
