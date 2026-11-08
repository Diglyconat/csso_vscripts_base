
ent_thinkfuncs <- {}
ent_thinkdelays <- {}

function Init()
{
	AddThinkToEnt( self, "Think" )
}

function Think()
{
	foreach( thinkName,thinkFunc in ent_thinkfuncs )
	{
		if( Time() - ent_thinkdelays[ thinkName ][ "trigger_time" ] < ent_thinkdelays[ thinkName ][ "delay" ] )
			continue
		
		thinkFunc()
		if( thinkName in ent_thinkdelays )
			ent_thinkdelays[ thinkName ][ "trigger_time" ] = Time()
	}
	
	return -1
}
