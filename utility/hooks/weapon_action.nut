
////////////////////////
// WEAPON ACTION HOOK //
////////////////////////

/*
	HOW IT WORKS:
	It checks the current sequence activity of a "predicted_viewmodel" entity (on each tick)
	and compares with previously found activity (previously found activity is overriden on each tick)
	If the next found activity is in the list of specified activities, then the matching event is triggered
	EXAMPLES:
	- whenever the viewmodel triggers "ACT_VM_RELOAD" activity, the "weapon_reload" event will be triggered
	- whenever the viewmodel triggers "ACT_VM_RELOAD_EMPTY" activity, the "weapon_reload_empty" event will be triggered
	- whenever the viewmodel triggers "ACT_SHOTGUN_RELOAD_START" activity, the "weapon_reload_start_shotgun" event will be triggered
	
	Each time the weapon action event is triggered, the following data block is sent to event's callback function:
	eventData = {
		user, 				// the weapon's owner, usually a player/bot
		userWeapon, 		// the weapon handle itself
		userVM, 			// weapon owner's viewmodel handle
		userVM_activity, 	// last triggered activity on weapon's viewmodel
		userVM_sequence, 	// last triggered sequence on weapon's viewmodel
		userVM_seqCycle, 	// last sequence cycle (from 0 to 1) on weapon's viewmodel
		userVM_seqLength, 	// last sequence's duration 
		userVM_prevData, 	// previous weapon action table
		weapon_action 		// which weapon action is triggered (available actions are listed in CSSO_WeaponAction_Activities)
	}
	
	Previously found weapon action data contains the following:
	eventData.userVM_prevData = {
		lastActivity		// last triggered activity on weapon's viewmodel
		lastSequence		// last triggered sequence on weapon's viewmodel
		lastSeqCycle		// last sequence cycle (from 0 to 1) on weapon's viewmodel
		lastSeqLength		// last sequence's duration
		lastAction			// last weapon action triggered (available actions are listed in CSSO_WeaponAction_Activities)
	}
*/

// "weapon_zoom_in", "weapon_toidle" and "weapon_reload_refill" are duct-taped "activities", they do NOT exist for weapons' viewmodels!
::CSSO_WeaponAction_Activities <- {
	ACT_SHOTGUN_RELOAD_START = "weapon_reload_start_shotgun", 
	ACT_SHOTGUN_RELOAD_FINISH = "weapon_reload_end_shotgun", 
	ACT_VM_FIDGET = "weapon_zoom_out", 
	ACT_VM_IDLE = "weapon_idle", 
	ACT_VM_IDLE_LOWERED = "weapon_inspect", 
	ACT_VM_DRAW = "weapon_deploy", 
	ACT_VM_DRAW_EMPTY = "weapon_deploy_empty", 
	ACT_VM_DRAW_SPECIAL = "weapon_deploy_first", 
	ACT_VM_DRYFIRE = "weapon_dryfire", 
	ACT_VM_DRYFIRE_LEFT = "weapon_dryfire_alt", 
	ACT_VM_HAULBACK = "weapon_prefire", 
	ACT_VM_HOLSTER = "weapon_holster", 
	ACT_VM_HITCENTER = "weapon_melee_hit", 
	ACT_VM_HITCENTER2 = "weapon_melee_alt_hit", 
	ACT_VM_MISSCENTER = "weapon_melee_miss", 
	ACT_VM_MISSCENTER2 = "weapon_melee_alt_miss", 
	ACT_VM_PRIMARYATTACK = "weapon_fire", 
	ACT_VM_PRIMARYATTACK_EMPTY = "weapon_fire_empty", 
	ACT_VM_SECONDARYATTACK = "weapon_fire_alt", 
	ACT_VM_SWINGHIT = "weapon_melee_backstab_light", 
	ACT_VM_SWINGHARD = "weapon_melee_backstab_heavy", 
	ACT_VM_RELOAD = "weapon_reload", 
	ACT_VM_RELOAD_EMPTY = "weapon_reload_empty", 
	ACT_VM_PULLPIN = "weapon_grenade_pullpin", 
	ACT_VM_RELEASE = "weapon_grenade_underhand", 
	ACT_VM_THROW = "weapon_grenade_throw", 
	ACT_SECONDARY_VM_RELOAD = "weapon_reload_alt", 
	ACT_SECONDARY_VM_DRAW = "weapon_deploy_alt", 
	weapon_zoom_in = "weapon_zoom_in", 
	weapon_zoom_out = "weapon_zoom_out", 
	weapon_reload_refill = "weapon_reload_refill", 
	weapon_toidle = "weapon_toidle"
}

::CSSO_WeaponAttack_Activities <- {
	ACT_VM_PRIMARYATTACK = "weapon_fire", 
	ACT_VM_SECONDARYATTACK = "weapon_fire_alt", 
	ACT_VM_DRYFIRE = "weapon_dryfire", 
	ACT_VM_DRYFIRE_LEFT = "weapon_dryfire_alt"
}

::CSSO_WeaponReload_Activities <- {
	ACT_VM_RELOAD = "weapon_reload", 
	ACT_VM_RELOAD_EMPTY = "weapon_reload_empty", 
	ACT_SECONDARY_VM_RELOAD = "weapon_reload_alt"
}

::CSSO_WeaponMelee_Activities <- {
	ACT_VM_HITCENTER = "weapon_melee_hit", 
	ACT_VM_HITCENTER2 = "weapon_melee_alt_hit", 
	ACT_VM_MISSCENTER = "weapon_melee_miss", 
	ACT_VM_MISSCENTER2 = "weapon_melee_alt_miss", 
	ACT_VM_SWINGHIT = "weapon_melee_backstab_light", 
	ACT_VM_SWINGHARD = "weapon_melee_backstab_heavy"
}

::CSSO_WeaponAction_AltAttack_Activities <- {
	ACT_VM_DRYFIRE_LEFT = "weapon_dryfire_alt", 
	ACT_VM_SECONDARYATTACK = "weapon_fire_alt", 
	ACT_VM_HITCENTER2 = "weapon_melee_alt_hit", 
	ACT_VM_MISSCENTER2 = "weapon_melee_alt_miss", 
	ACT_VM_SWINGHARD = "weapon_melee_backstab_heavy", 
	ACT_VM_RELEASE = "weapon_grenade_underhand"
}

local viewmodelWeaponAction = function()
{
	if( !self || !self.IsValid() )
		return
	
	local scope = cm_allocateEntityScriptScope( self, 
		{
			previousActivity = null, 
			previousAction = null, 
			previousDuration = -1.0, 
			previousSequence = null, 
			previousCycle = 1.0, 
			previousParity = 0
		} )

	local currentCycle = self.GetCycle()
	local currentSequence = self.GetSequence()
	local currentActivity = self.GetSequenceActivityName( currentSequence )
	local seqDuration = self.GetSequenceDuration( currentSequence )
	local currentParity = NetProps.GetPropInt( self, "m_nNewSequenceParity" )

	local ply = self.GetMoveParent()
	if( !ply || !ply.IsValid() || !ply.IsAlive() )
	{
		scope.previousCycle = 1.0
		return
	}

	local weapon = ply.GetActiveWeapon()
	if( !weapon || !weapon.IsValid() )
	{
		scope.previousCycle = 1.0
		return
	}

	local wpnScope = cm_allocateEntityScriptScope( weapon, 
		{
			previousClipRefill = false, 
			previousIdleTime = -1.0
		} )

	// duct-tape to prevent infinite cycling caused by "ACT_VM_IDLE" activity, since it's looped
	if( currentActivity != "ACT_VM_IDLE" && 1.0 - currentCycle <= FrameTime()*seqDuration )
	{
		if( wpnScope.previousIdleTime < 0.0 )
		{
			local eventData = {
				user = ply, 
				userWeapon = weapon, 
				userVM = self, 
				userVM_activity = "weapon_toidle", 
				userVM_sequence = currentSequence, 
				userVM_seqCycle = currentCycle, 
				userVM_seqLength = seqDuration, 
				userVM_prevData = {
					lastActivity = scope.previousActivity
					lastSequence = scope.previousSequence
					lastSeqCycle = scope.previousCycle
					lastSeqLength = scope.previousDuration
					lastAction = scope.previousAction
				}, 
				weapon_action = "weapon_toidle"
			}
			
			CSSO_TriggerGameEvent( "weapon_action", eventData, seqDuration - ( seqDuration * currentCycle ) )
			scope.previousAction = "weapon_toidle"
		}
		
		wpnScope.previousIdleTime = Time()
	}
	else
	{
		if( currentActivity == "ACT_VM_IDLE" )
			scope.previousParity = currentParity
		
		wpnScope.previousIdleTime = -1.0
	}
	
	local curClipSize = weapon.Clip1()
	local ammoType = weapon.GetPrimaryAmmoType()
	local reloadRefillProcessed = NetProps.GetPropBool( weapon, "m_bReloadVisuallyComplete" )
	if( ammoType > -1 && reloadRefillProcessed && wpnScope.previousClipRefill != reloadRefillProcessed )
	{
		local eventData = {
			user = ply, 
			userWeapon = weapon, 
			userVM = self, 
			userVM_activity = "weapon_reload_refill", 
			userVM_sequence = currentSequence, 
			userVM_seqCycle = currentCycle, 
			userVM_seqLength = seqDuration, 
			userVM_prevData = {
				lastActivity = scope.previousActivity
				lastSequence = scope.previousSequence
				lastSeqCycle = scope.previousCycle
				lastSeqLength = scope.previousDuration
				lastAction = scope.previousAction
			}, 
			weapon_action = "weapon_reload_refill"
		}
		
		CSSO_TriggerGameEvent( "weapon_action", eventData )
		scope.previousAction = "weapon_reload_refill"
	}
	
	if( currentActivity in CSSO_WeaponAction_Activities && ( scope.previousActivity != currentActivity || scope.previousParity != currentParity ) )
	{
		local eventData = {
			user = ply, 
			userWeapon = weapon, 
			userVM = self, 
			userVM_activity = currentActivity, 
			userVM_sequence = currentSequence, 
			userVM_seqCycle = currentCycle, 
			userVM_seqLength = seqDuration, 
			userVM_prevData = {
				lastActivity = scope.previousActivity
				lastSequence = scope.previousSequence
				lastSeqCycle = scope.previousCycle
				lastSeqLength = scope.previousDuration
				lastAction = scope.previousAction
			}, 
			weapon_action = CSSO_WeaponAction_Activities[ currentActivity ]
		}
		
		CSSO_TriggerGameEvent( "weapon_action", eventData )
		scope.previousAction = eventData.weapon_action
	}

	scope.previousActivity = currentActivity
	scope.previousDuration = seqDuration
	scope.previousSequence = currentSequence
	scope.previousCycle = currentCycle
	scope.previousParity = currentParity
	wpnScope.previousClipRefill = reloadRefillProcessed
}

CSSO_AddCustomEvent( "weapon_action", function()
{
	for( local i = 1; i <= MaxClients().tointeger(); i++ )
	{
		local ply = PlayerInstanceFromIndex( i )
		if( !ply || !ply.IsValid() )
			continue
		
		local vm = cm_getPlayerViewmodel( ply )
		if( !vm || !vm.IsValid() )
			continue
		
		cm_addThinkFuncToEnt( vm, "viewmodelWeaponAction", -1, viewmodelWeaponAction )
	}
})

AddEventCallback( "weapon_zoom", "CSSOEvent_OnWeaponZoom", function( params )
{
	local player = GetPlayerFromUserID( params.userid )
	if( !player || !player.IsValid() )
		return
	
	local vm = cm_getPlayerViewmodel( player )
	if( !vm || !vm.IsValid() )
		return
	
	local weapon = player.GetActiveWeapon()
	if( !weapon || !weapon.IsValid() )
		return
	
	local currentSequence = vm.GetSequence()
	local currentCycle = vm.GetCycle()
	local currentActivity = vm.GetSequenceActivityName( currentSequence )
	local curClipSize = weapon.Clip1()
	local curWeaponMode = weapon.GetWeaponMode()
	local currentParity = NetProps.GetPropInt( vm, "m_nNewSequenceParity" )
	
	local scope = cm_allocateEntityScriptScope( vm, 
		{
			previousActivity = null, 
			previousAction = null, 
			previousDuration = -1.0, 
			previousSequence = null, 
			previousCycle = 1.0, 
			previousParity = currentParity
		} )
	
	local wpnZoomLevels = CSSO_GetWeaponDataParam( weapon, "ZoomLevels" )
	local wpnIronsight = CSSO_GetWeaponDataParam( weapon, "IronsightCapable" )
	local curScopeLevel = weapon.GetZoomLevel()
	scope.previousParity = currentParity
	if( wpnZoomLevels > 0 || wpnIronsight > 0 )
	{
		if( curWeaponMode > 0 )
		{
			currentActivity = "weapon_zoom_in"
			if( wpnZoomLevels > 0 && curScopeLevel > 0 )
				curWeaponMode = curScopeLevel
		}
		else if( wpnZoomLevels > 0 || curWeaponMode == 0 )
			currentActivity = "weapon_zoom_out"
		
		if( currentActivity != "ACT_VM_FIDGET" )
		{
			local eventData = {
				user = player, 
				userWeapon = weapon, 
				userVM = vm, 
				userVM_activity = currentActivity, 
				userVM_sequence = currentSequence, 
				userVM_seqCycle = currentCycle, 
				userVM_seqLength = vm.GetSequenceDuration( currentSequence ), 
				userVM_prevData = {
					lastActivity = scope.previousActivity
					lastSequence = scope.previousSequence
					lastSeqCycle = scope.previousCycle
					lastSeqLength = scope.previousDuration
					lastAction = scope.previousAction
				}, 
				weapon_action = CSSO_WeaponAction_Activities[ currentActivity ]
			}
			
			CSSO_TriggerGameEvent( "weapon_action", eventData )
		}
	}
})

AddEventCallback( "weapon_reload", "CSSOEvent_OnWeaponReload", function( params )
{
	local player = GetPlayerFromUserID( params.userid )
	if( !player || !player.IsValid() )
		return
	
	local vm = cm_getPlayerViewmodel( player )
	if( !vm || !vm.IsValid() )
		return
	
	local weapon = player.GetActiveWeapon()
	if( !weapon || !weapon.IsValid() )
		return
	
	local currentSequence = vm.GetSequence()
	local currentCycle = vm.GetCycle()
	local currentActivity = vm.GetSequenceActivityName( currentSequence )
	local seqDuration = vm.GetSequenceDuration( currentSequence )
	local currentParity = NetProps.GetPropInt( vm, "m_nNewSequenceParity" )
	
	local scope = cm_allocateEntityScriptScope( vm, 
		{
			previousActivity = currentActivity, 
			previousAction = CSSO_WeaponAction_Activities[ currentActivity ], 
			previousDuration = seqDuration, 
			previousSequence = currentSequence, 
			previousCycle = currentCycle, 
			previousParity = currentParity
		} )
	
	if( scope.previousParity == currentParity )
		return
	
	scope.previousActivity = currentActivity
	scope.previousCycle = currentCycle
	scope.previousParity = currentParity
	local eventData = {
		user = player, 
		userWeapon = weapon, 
		userVM = vm, 
		userVM_activity = currentActivity, 
		userVM_sequence = currentSequence, 
		userVM_seqCycle = currentCycle, 
		userVM_seqLength = seqDuration, 
		userVM_prevData = {
			lastActivity = scope.previousActivity
			lastSequence = scope.previousSequence
			lastSeqCycle = scope.previousCycle
			lastSeqLength = scope.previousDuration
			lastAction = scope.previousAction
		}, 
		weapon_action = CSSO_WeaponAction_Activities[ currentActivity ]
	}
	
	CSSO_TriggerGameEvent( "weapon_action", eventData )
})
