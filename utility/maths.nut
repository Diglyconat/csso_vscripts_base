
////////////////
// MATEMATIKA //
////////////////

// convert degrees to radians (! PI is somewhere about 3.141 :nerd: !)
::cm_deg2rad <- function( degree )
{
	return degree * PI / 180
}

// convert degree vector to radians vector
::cm_vdeg2rad <- function( vector )
{
	return Vector( 
		cm_deg2rad(vector.x),
		cm_deg2rad(vector.y),
		cm_deg2rad(vector.z)
	)
}

// convert angles to vector
::cm_angToVec <- function( angles )
{
	local da = cm_vdeg2rad( angles )
    
    local x = cos(da.x)*cos(da.y)
    local y = cos(da.x)*sin(da.y)
    local z = -sin(da.x)

	return Vector( x, y, z )
}

// convert angles to vector of a specified type
// either via cm_angToVec (if no type is specified), or as one of the following types:
// 1 - "forward", 2 - "right", 3 - "up"
// ( !!!!! ZAEBIS PIMON SPASEBA !!!!! )
::cm_angleVectors <- function( angles, type = -1 )
{
	local sp = sin( cm_deg2rad( angles.x ) )
    local cp = cos( cm_deg2rad( angles.x ) )
    local sy = sin( cm_deg2rad( angles.y ) )
    local cy = cos( cm_deg2rad( angles.y ) )
    local sr = sin( cm_deg2rad( angles.z ) )
    local cr = cos( cm_deg2rad( angles.z ) )
	
	if( !type || type < 1 || type > 3 )
		return cm_angToVec( angles )
	
	if( type == 1 )		// forward vector
		return Vector( cp * cy, cp * sy, -sp )
	
	if( type == 2 )		// right vector
		return Vector( -1 * sr * sp * cy + ( -1 ) * cr * -sy, -1 * sr * sp * sy + ( -1 ) * cr * -cy , -1 * sr * cp )
	
	if( type == 3 )		// up vector
		return Vector( cr * sp * cy + ( -sr ) * -sy, cr * sp * sy + ( -sr ) * cy , cr * cp )
}

// find minimum value from sequence of arguments
::cm_findMin <- function(...)
{
	if( vargv.len() == 0 )
		return null
	
    local target = vargv[0]
    for( local i = 0; i < vargv.len(); i++ )
	{
        if( vargv[i] < target )
            target = vargv[i]
	}
	
    return target
}

// find maximum value from sequence of arguments
::cm_findMax <- function(...)
{
	if( vargv.len() == 0 )
		return null
	
    local target = vargv[0]
    for( local i = 0; i < vargv.len(); i++ )
	{
        if( vargv[i] > target )
            target = vargv[i]
	}
	
    return target
}

::cm_Wrap <- function( value, min, max )
{
	if( value < min )
		value = max - value + min
	else if( value > max )
		value = value - max + min
	
	return value
}

// clamp the value inside min and max range, so it doesn't exceed those
// deltaMin & deltaMax define the additive range to max & min
::cm_Clamp <- function( value, min = null, max = null, deltaMin = null, deltaMax = null )
{
	if( deltaMin == null )
		deltaMin = 0
	
	if( deltaMax == null )
		deltaMax = 0
	
	if( min != null && value < min + deltaMin )
		value = min
	
	if( max != null && value > max - deltaMax )
		value = max
	
	return value
}

// lerp start value to end value with "t" step
::cm_lerp <- function( start, end, t ){ return start + ( end - start ) * t }

// lerp start vector to end vector with "frac" step
::cm_vlerp <- function( vcurrent, vtarget, frac )
{
    return Vector
    (  
        cm_lerp( vcurrent.x, vtarget.x, frac ),
        cm_lerp( vcurrent.y, vtarget.y, frac ),
        cm_lerp( vcurrent.z, vtarget.z, frac )
    )
}

// lerp start value to end value with specified amount of Delta Time (returns value from 0 to 1)
::cm_lerpDT <- function( start, end, amount )
{
	amount *= FrameTime()
	local flBlend = pow( 0.5, FrameTime() / ( amount * 10 ) )
	local lerpDelta = cm_lerp( start, end, 1.0 - flBlend )
	return cm_Clamp( lerpDelta, 0.0, 1.0 )
}

::cm_lerpValue <- function( start, end, startTime, duration, wrapRange = null )
{
	local timeDif = Time() - startTime
	if( timeDif <= 0.0 )
		return start
	
	if( timeDif > startTime + duration )
		return end
	
	if( wrapRange != null )
	{
		start = cm_Wrap( start, wrapRange[ 0 ], wrapRange[ 1 ] )
		end = cm_Wrap( end, wrapRange[ 0 ], wrapRange[ 1 ] )
	}
	
	return cm_lerp( start, end, timeDif / duration )
}