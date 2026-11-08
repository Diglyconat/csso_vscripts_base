
////////////////////////
// PARTICLE FUNCTIONS //
////////////////////////

// spawn "info_particle_system" entity with specified particle name
// EXAMPLES OF USAGE:
// local myParticle = cm_spawnParticle( "weapon_molotov_fp_fire3" )
// myParticle.SetAbsOrigin( gpf().EyePosition() )
// myParticle.AcceptInput( "Start", "", null, null )
// EntFireByHandle( myParticle, "Stop", "", 0.1, null, null )
// ^ this will force the "weapon_molotov_fp_fire3" particle to be spawned at host player's eyes;
//   then start dispatching particle instantly, after 0.1s it stops dispatching the particle
::cm_spawnParticle <- function( effectName, effectOrigin, effectAngles, isActive = false )
{
    return SpawnEntityFromTable( "info_particle_system", {
			effect_name = effectName, 
			origin = effectOrigin, 
			angles = effectAngles, 
			start_active = isActive
		}
	)
}

// custom wrapper for "DispatchParticleEffect" with particle precache
::cm_dispatchParticleEffect <- function( particleName, particleOrigin, particleAngles )
{
	if( !PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = particleName }) )
	{
		printl( "[VScripts Base] Unable to dispatch particle \"" + particleName + "\"!" )
		return
	}
	
	DispatchParticleEffect( particleName, particleOrigin, particleAngles )
}

// spawn "env_shake" entity with specified origin, frequency, radius, duration and amplitude
// gets removed after specified "duration" time value!
::cm_spawnShakeEffect <- function( origin, frequency, radius, duration, amplitude )
{
	local shake = Entities.CreateByClassname( "env_shake" )
	cm_purgeStr( shake )
	shake.__KeyValueFromFloat( "frequency", frequency )
	shake.__KeyValueFromFloat( "radius", radius )
	shake.__KeyValueFromFloat( "duration", duration )
	shake.__KeyValueFromFloat( "amplitude", amplitude )
	shake.__KeyValueFromInt( "spawnflags", 4 )
	shake.SetAbsOrigin( origin )
	shake.AcceptInput( "StartShake", "", null, null )
	EntFireByHandle( shake, "Kill", "", duration, null, null )
}

// spawn "env_physexplosion" entity with specified origin, frequency, radius, duration and amplitude
// gets removed instantly!
::cm_spawnPhysExplosionEffect <- function( origin, magnitude )
{
	local exp = Entities.CreateByClassname( "env_physexplosion" )
	cm_purgeStr( exp )
	exp.SetAbsOrigin( origin )
	exp.__KeyValueFromFloat( "magnitude", magnitude )
	exp.__KeyValueFromInt( "spawnflags", 1+8 )
	exp.AcceptInput( "ExplodeAndRemove", "", null, null )
}
