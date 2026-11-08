
if( !( ::rawin( "EventsInstance" ) ) )
{
	::EventsInstance <- csso_worldspawn
	::EventsID <- UniqueString()
}

::EventsTable <- {}
::EventCallbacks <- {}
::HooksTable <- {}
::HookCallbacks <- {}

function CollectEventsInScope( events )
{
	getroottable()[ EventsID ] <- events
	local events_table = getroottable()[ EventsID ]
	local Instance = EventsInstance
	foreach( name,callback in events ) 
	{
		local callback_binded = callback.bindenv( this ) 
		events_table[ name ] = @( params ) Instance.IsValid() ? callback_binded( params ) : delete getroottable()[ EventsID ]
	}
	__CollectGameEventCallbacks( events_table )
}

::AddEventCallback <- function( event_name, event_func_name, event_callback )
{
	if( event_callback == null || typeof( event_callback ) != "function" )
		return
	
	if( !( event_name in EventCallbacks ) )
		EventCallbacks[ event_name ] <- {}
	
	local newEventStr = "OnGameEvent_" + event_name
	if( !( newEventStr in EventsTable ) )
	{
		EventsTable[ newEventStr ] <- function( params, callbacks = EventCallbacks[ event_name ] )
		{
			foreach( k,v in callbacks )
				v( params )
		}
		
		CollectEventsInScope( EventsTable )
	}
	
	EventCallbacks[ event_name ][ event_func_name ] <- event_callback
}

::AddHookCallback <- function( hook_name, hook_func_name, hook_callback )
{
	if( !cm_inArray( hook_name, CSSO_HooksList ) || hook_callback == null || typeof( hook_callback ) != "function" )
		return
	
	if( !( hook_name in HookCallbacks ) )
		HookCallbacks[ hook_name ] <- {}
	
	local newHookStr = "OnScriptHook_" + hook_name
	if( !( newHookStr in HooksTable ) )
	{
		HooksTable[ newHookStr ] <- function( params, callbacks = HookCallbacks[ hook_name ] )
		{
			foreach( k,v in callbacks )
				v( params )
		}
		
		CollectEventsInScope( HooksTable )
	}
	
	HookCallbacks[ hook_name ][ hook_func_name ] <- hook_callback
}