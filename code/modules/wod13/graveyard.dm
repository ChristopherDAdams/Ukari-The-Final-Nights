#define ZOMBIE_TYPE_DEFAULT   0
#define ZOMBIE_TYPE_SIEGE     1
#define ZOMBIE_TYPE_SHRIEKER  2
#define ZOMBIE_TYPE_WANDERER  3
#define ZOMBIE_TYPES list(ZOMBIE_TYPE_DEFAULT, ZOMBIE_TYPE_SIEGE, ZOMBIE_TYPE_SHRIEKER, ZOMBIE_TYPE_WANDERER)

#define ZOMBIE_TASK_ATTACK         0
#define ZOMBIE_TASK_GO_TO_GATE     1
#define ZOMBIE_TASK_WANDER         2
#define ZOMBIE_TASK_FLEE_AND_RALLY 3

SUBSYSTEM_DEF(graveyard)
	name = "Graveyard"
	init_order = INIT_ORDER_DEFAULT
	wait = 3000
	priority = FIRE_PRIORITY_DEFAULT
	var/max_graveyard_zombies = 50
	var/alive_zombies = 0
	var/lost_points = 0
	var/clear_runs = 0
	var/list/graves = list()
	var/total_good = 0
	var/total_bad = 0
	var/list/type_counts = list()

/datum/controller/subsystem/graveyard/fire()
	//checks for keepers and players in the graveyard. Limits spawns based on this.
	var/keeper_count = count_active_keepers()
	var/players_in_graveyard = get_graveyard_player_count()
	var/minimum_zombies = keeper_count * 5
	var/additional_zombies = players_in_graveyard * 5
	//50 hard limit. results in 10 per Keeper, 5 per any other role.
	var/target_total = clamp(minimum_zombies + additional_zombies, 10, max_graveyard_zombies)
	// Sets Spawn count intigers to 0, for logging.
	var/def_spawned = 0
	var/siege_spawned = 0
	var/shrieker_spawned = 0
	var/wanderer_spawned = 0
	var/to_spawn = min(target_total - alive_zombies, max_graveyard_zombies - alive_zombies)
	//Spawns Zombies:
	if (to_spawn > 0)
		announce_to_keepers("WALKING DEAD ARE RISING...")
		for (var/i = 1 to to_spawn)
			var/ztype = weighted_zombie_type_pick() //returns a zombie type by wieghted chance.
			var/grave = pick(graves) //grave
			if(!grave)
				break
			var/Z = spawn_graveyard_zombie(grave, ztype)
			if(Z) //for logging
				switch(ztype)
					if(ZOMBIE_TYPE_DEFAULT)   def_spawned++
					if(ZOMBIE_TYPE_SIEGE)     siege_spawned++
					if(ZOMBIE_TYPE_SHRIEKER)  shrieker_spawned++
					if(ZOMBIE_TYPE_WANDERER)  wanderer_spawned++
		clear_runs++ //old stuff, will rework this or take it out.
	else
		lost_points++ //lazy graveyard keepers, exploiting something to be passive. (Not bad currently, will make this ramp up the spawns.)
		clear_runs = 0 //Highscore Keeping?
		announce_to_keepers("Zombies not spawned. Too many alive.")

	var/spawn_report = "Graveyard Spawn Summary: Spawn #[to_spawn]"
	spawn_report += " Default: [def_spawned]"
	spawn_report += " Siege: [siege_spawned]"
	spawn_report += " Shrieker: [shrieker_spawned]"
	spawn_report += " Wanderer: [wanderer_spawned]"
	message_admins(spawn_report)

//for logging, dynamic names set later.
/proc/get_zombie_type_name(ztype)
	switch(ztype)
		if(ZOMBIE_TYPE_DEFAULT)   return "Default"
		if(ZOMBIE_TYPE_SIEGE)     return "Siege"
		if(ZOMBIE_TYPE_SHRIEKER)  return "Shrieker"
		if(ZOMBIE_TYPE_WANDERER)  return "Wanderer"
	return "([ztype])"

//Keeper check every Graveyard Fire()
/datum/controller/subsystem/graveyard/proc/count_active_keepers()
	var/count = 0
	for(var/mob/living/carbon/human/L in GLOB.player_list)
		if(L?.mind?.assigned_role == "Graveyard Keeper" && L.client)
			count++
	return count
//Player check every Graveyard Fire()
/datum/controller/subsystem/graveyard/proc/get_graveyard_player_count()
	var/count = 0
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(istype(get_area(H), /area/vtm/graveyard))
			count++
	return count

//How likely is a type of zombie to spawn.
/datum/controller/subsystem/graveyard/proc/weighted_zombie_type()
	log_admin(" weighted_zombie_type() called.")
	return list(
		ZOMBIE_TYPE_DEFAULT, 10,
		ZOMBIE_TYPE_SIEGE, 5,
		ZOMBIE_TYPE_SHRIEKER, 2,
		ZOMBIE_TYPE_WANDERER, 5
	)


//Actual weight comparisons and return.
/datum/controller/subsystem/graveyard/proc/weighted_zombie_type_pick()
	var/list/pairs = weighted_zombie_type()
	if(!pairs || !length(pairs))
		log_admin("⚠ weighted_zombie_type_pick(): No weights returned, defaulting to Default.")
		return ZOMBIE_TYPE_DEFAULT

	var/total_weight = 0
	for (var/i = 2; i <= pairs.len; i += 2)
		total_weight += pairs[i]

	if(total_weight <= 0)
		log_admin("⚠ weighted_zombie_type_pick(): Total weight was zero or less, defaulting.")
		return ZOMBIE_TYPE_DEFAULT

	var/roll = rand(1, total_weight)
	var/running_total = 0

	log_admin("weighted_zombie_type_pick(): Roll: [roll] (Total: [total_weight])")
	log_admin("Weight List:")
	for (var/i = 1; i <= pairs.len; i += 2)
		log_admin(" • [get_zombie_type_name(pairs[i])] => [pairs[i+1]]")

	for (var/i = 1; i <= pairs.len; i += 2)
		running_total += pairs[i+1]
		if(roll <= running_total)
			var/ztype = pairs[i]
			log_admin("Picked zombie type: [ztype] ([get_zombie_type_name(ztype)]) with running total: [running_total]")
			return ztype

	log_admin("weighted_zombie_type_pick(): Fallback return triggered.")
	return ZOMBIE_TYPE_DEFAULT


//Keeper Announcement
/datum/controller/subsystem/graveyard/proc/announce_to_keepers(msg)
	for(var/mob/living/carbon/human/L in GLOB.player_list)
		if(L?.mind?.assigned_role == "Graveyard Keeper" && L.client)
			to_chat(L, msg)


//Graveyard Zombie Component

/datum/controller/subsystem/graveyard/proc/create_graveyard_zombie(mob/living/L, ztype)
	if(!isnum(ztype) || !(ztype in ZOMBIE_TYPES))
		log_admin("create_graveyard_zombie(): Invalid zombie_type [ztype], defaulting to 0")
		ztype = ZOMBIE_TYPE_DEFAULT

	var/comp = L.AddComponent(/datum/component/graveyard_zombie, ztype)
	if(!comp)
		log_admin("create_graveyard_zombie(): Failed to attach component to [L]!")
		return null

	log_admin("create_graveyard_zombie(): Component added to [L] with type [ztype] ([get_zombie_type_name(ztype)])")
	return comp



/datum/controller/subsystem/graveyard/proc/spawn_graveyard_zombie(atom/grave, behavior)
	if(!isnum(behavior) || !(behavior in ZOMBIE_TYPES))
		log_admin("spawn_graveyard_zombie(): Invalid behavior [behavior]. Aborting spawn.")
		return null

	var/turf/T = get_turf(grave)
	var/mob/living/simple_animal/hostile/zombie/Z = new /mob/living/simple_animal/hostile/zombie(T)
	if(!Z)
		return null

	log_admin("spawn_graveyard_zombie(): Spawned zombie at [Z.x],[Z.y],[Z.z] with intended type: [get_zombie_type_name(behavior)]")

	var/comp = create_graveyard_zombie(Z, behavior)
	if(!comp)
		qdel(Z)
		return null

	GLOB.zombie_list += Z
	alive_zombies = max(0, alive_zombies + 1)
	return Z



// Graveyard Zombie Component
/datum/component/graveyard_zombie
	var/mob/living/simple_animal/hostile/zombie/owner
	var/loop_started = FALSE
	var/zombie_type = ZOMBIE_TYPE_DEFAULT
	var/can_rally = TRUE
	var/visiting_grave = FALSE
	var/current_task = ZOMBIE_TASK_WANDER
	var/last_rally_time = 0


/datum/component/graveyard_zombie/Initialize(ztype)
	. = ..()
	start(ztype)
/datum/component/graveyard_zombie/proc/start(ztype)
	if(!istype(parent, /mob/living/simple_animal/hostile/zombie))
		qdel(src)
		return
	owner = parent
	var/mob/living/simple_animal/hostile/zombie/Z = owner
	Z.graveyard_component = src
	zombie_type = ztype
	Z.name = set_zombie_name()
	StartztypeLoop()
	log_admin("grzombie: Component started on [Z] with type [zombie_type]")



//manages the graveyard duty system of the slaying player.
/datum/component/graveyard_zombie/proc/on_death()
	if(!ismob(owner)) return
	var/mob/living/simple_animal/hostile/zombie/Z = owner
	// Decrement graveyard counters
	SSgraveyard.alive_zombies = max(0, SSgraveyard.alive_zombies - 1)
	SSgraveyard.type_counts[zombie_type] = max(0, SSgraveyard.type_counts[zombie_type] - 1)
	GLOB.zombie_list -= Z
	// Handle attacker rewards
	var/mob/living/H = Z.last_attacker
	if(istype(H) && istype(get_area(H), /area/vtm/graveyard))
		H.killedzombies++
		if(H.killedzombies >= 10)
			H.killedzombies = 0
			H.masquerade++
			to_chat(H, "You slew 10 undead. <span class='notice'>Masquerade Point Restored.</span>")
		else
			to_chat(H, "Graveyard Duty: Zombies killed: [H.killedzombies]/10.")

//Names the zombie with a dynamic name, just for flavor.
/datum/component/graveyard_zombie/proc/set_zombie_name()
	if(zombie_type == ZOMBIE_TYPE_DEFAULT)
		return pick("Zombu", "Zombie", "Corpse")
	if(zombie_type == ZOMBIE_TYPE_SIEGE)
		return pick("Siege Zombie", "Siege Corpse")
	if(zombie_type == ZOMBIE_TYPE_SHRIEKER)
		return pick("Shrieker Zombu", "Shrieking Zombie", "Screaming Corpse")
	if(zombie_type == ZOMBIE_TYPE_WANDERER)
		return pick("Wayfaring Zombu", "Wandering Zombie", "Wandering Corpse")


// Graveyard Zombie ztype: These "AI's", handle setting the zombies tasks.

/datum/component/graveyard_zombie/proc/StartztypeLoop()
	if(loop_started)
		return
	loop_started = TRUE
	zombie_behavior()

/datum/component/graveyard_zombie/proc/zombie_behavior()
	Runztype()
	addtimer(CALLBACK(src, .proc/zombie_behavior), 10)

//Every graveyard zombie component calls this every 2 seconds to "use its brain"
/datum/component/graveyard_zombie/proc/Runztype()
	// Refresh or check target
	//random walk
	if (prob(10))
		step(owner, pick(NORTH, SOUTH, EAST, WEST))
		return
	// Switch AI behavior by zombie_type
	switch(zombie_type)
		if (ZOMBIE_TYPE_DEFAULT)   current_task = default_zombie_ai()
		if (ZOMBIE_TYPE_SIEGE)     current_task = siege_zombie_ai()
		if (ZOMBIE_TYPE_SHRIEKER)  current_task = shrieker_zombie_ai()
		if (ZOMBIE_TYPE_WANDERER)  current_task = wanderer_zombie_ai()
		else                      current_task = default_zombie_ai()
	HandleTask(current_task)


//The actual AI's, for zombies, they don't need to be that complicated, but this could expanded/reworked for other hostiles.
/datum/component/graveyard_zombie/proc/default_zombie_ai()
	if(owner.FindTarget())
		return ZOMBIE_TASK_ATTACK
	//has to return a task, but extra flavor and early return ztypes can go here.
	if(!owner.FindTarget())
		return ZOMBIE_TASK_GO_TO_GATE

/datum/component/graveyard_zombie/proc/siege_zombie_ai()
	if(owner.last_attacker)
		return ZOMBIE_TASK_ATTACK
	//has to return a task, but extra flavor and early return ztypes can go here.
	if(!owner.last_attacker)
		return ZOMBIE_TASK_GO_TO_GATE

/datum/component/graveyard_zombie/proc/shrieker_zombie_ai()
	if(owner.FindTarget())
		return ZOMBIE_TASK_FLEE_AND_RALLY
	//has to return a task, but extra flavor and early return ztypes can go here.
	if(!owner.FindTarget())
		return ZOMBIE_TASK_WANDER

/datum/component/graveyard_zombie/proc/wanderer_zombie_ai()
	if(owner.FindTarget())
		return ZOMBIE_TASK_ATTACK
	//has to return a task, but extra flavor and early return ztypes can go here.
	if(!owner.FindTarget())
		return ZOMBIE_TASK_WANDER

//Sets the zombie's current task and handles it until its done, or interupts itself, etc.
/datum/component/graveyard_zombie/proc/HandleTask(task)
	switch(task)
		if(ZOMBIE_TASK_ATTACK)         perform_attack()
		if(ZOMBIE_TASK_GO_TO_GATE)     perform_gate_rush()
		if(ZOMBIE_TASK_WANDER)         perform_wander()
		if(ZOMBIE_TASK_FLEE_AND_RALLY) perform_rally()

//Tasks are the place to call the bare minimum actions needed in that tick, and, if needed, cut themselves off if already running.
//Attack
/datum/component/graveyard_zombie/proc/perform_attack()
	var/target = owner.target
	if (!target)
		return
	if (get_dist(owner, target) <= 1)
		owner.UnarmedAttack(target)
	else
		step_towards(owner, target)

//GateRush
/datum/component/graveyard_zombie/proc/perform_gate_rush()
	if(!GLOB.vampgate || QDELETED(GLOB.vampgate)) return
	var/gate_open = GLOB.vampgate.icon_state == "gate-open"
	if(get_dist(src, GLOB.vampgate) <= 1)
		if(!gate_open)
			owner.UnarmedAttack(GLOB.vampgate)
			GLOB.vampgate.punched() //actually what damages the gates HP, and triggers gate health.
		else
			// Loiter near the gate for a bit
			for(var/i = 0, i < rand(4, 8); i++)
				if(QDELETED(src)) break
				var/dir = pick(NORTH, SOUTH, EAST, WEST)
				step(src, dir)
				sleep(rand(5, 10))
	else
		step_towards(src, GLOB.vampgate)
		if(prob(10))
			owner.emote(pick("moans...", "shuffles forward...", "growls lowly..."))

//Wander
/datum/component/graveyard_zombie/proc/perform_wander()
	if(visiting_grave)
		return
	wander_randomly()

/datum/component/graveyard_zombie/proc/wander_randomly()
	// Chance to initiate grave visiting "sub-task"
	if(prob(10))
		start_grave_wander()
		return
	// Otherwise, 50% chance to stumble
	if(prob(50))
		var/dir = pick(NORTH, SOUTH, EAST, WEST)
		step(src, dir)

/datum/component/graveyard_zombie/proc/start_grave_wander()
	if(visiting_grave) return

	var/list/nearby = list()
	for(var/obj/vampgrave/G in SSgraveyard.graves)
		if(get_dist(src, G) <= 20)
			nearby += G
	if(!length(nearby)) return

	var/obj/vampgrave/G = pick(nearby)
	visiting_grave = TRUE

	move_to_grave(G)

/datum/component/graveyard_zombie/proc/move_to_grave(obj/vampgrave/G, tick = 0)
	if(QDELETED(src) || QDELETED(G)) return end_grave_visit()
	if(get_dist(src, G) <= 1) return begin_grave_linger(G)
	if(tick >= 50) return begin_grave_linger(G)
	step_towards(src, G)
	addtimer(CALLBACK(src, .proc/move_to_grave, G, tick + 1), 5) // 0.5s per step

/datum/component/graveyard_zombie/proc/begin_grave_linger(obj/vampgrave/G, time_waited = 0, linger_time = -1)
	if(QDELETED(src) || QDELETED(G)) return end_grave_visit()
	if(linger_time == -1) linger_time = rand(300, 600) // 30–60s total

	var/origin = get_turf(G)
	var/loc = get_turf(src)

	if(get_dist(loc, origin) > 2)
		step_to(src, origin)
	else
		step(src, pick(NORTH, SOUTH, EAST, WEST))

	var/wait = rand(10, 20)
	if(time_waited + wait >= linger_time)
		return end_grave_visit()

	addtimer(CALLBACK(src, .proc/begin_grave_linger, G, time_waited + wait, linger_time), wait)

/datum/component/graveyard_zombie/proc/end_grave_visit()
	visiting_grave = FALSE

//Rally
/datum/component/graveyard_zombie/proc/perform_rally()
	start_zombie_rally(owner.target)
	follow_at_range(owner.target)

/datum/component/graveyard_zombie/proc/start_zombie_rally(mob/living/target = null)
	if(!target && GLOB.vampgate)
		target = GLOB.vampgate

	var/current_time = world.time
	if(current_time - last_rally_time < 100) // Only allow every 10s
		return
	last_rally_time = current_time
	owner.emote("scream")
	for(var/mob/living/simple_animal/hostile/zombie/Z in view(10, src))
		if(Z == owner) continue
		var/datum/component/graveyard_zombie/comp = Z.graveyard_component
		if(!comp) continue
		if(comp.current_task == ZOMBIE_TASK_ATTACK) continue
		comp.owner.target = target
		comp.current_task = ZOMBIE_TASK_GO_TO_GATE
		if (prob(20))
			Z.emote(pick("Turns to the scream."))
		step_towards(Z, target)

/// Makes the zombie maintain a position within a certain range of a target.
/datum/component/graveyard_zombie/proc/follow_at_range(mob/living/target, min_range = 3, max_range = 5)
	if(!target || QDELETED(target) || target.stat >= DEAD) return

	var/dist = get_dist(src, target)
	if(dist < min_range)
		step_away(src, target)
	else if(dist > max_range)
		step_towards(src, target)
	else
		owner.dir = get_dir(src, target)


// Graves: Graveyard Zombie Spawn Point
/obj/vampgrave
	icon = 'code/modules/wod13/props.dmi'
	icon_state = "grave1"
	name = "grave"
	plane = GAME_PLANE
	layer = ABOVE_NORMAL_TURF_LAYER
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/vampgrave/Initialize()
	. = ..()
	SSgraveyard.graves += src
	icon_state = "grave[rand(1, 10)]"
	if(GLOB.winter)
		var/area/vtm/V = get_area(src)
		if(istype(V) && V.upper)
			icon_state = "[icon_state]-snow"

/obj/vampgrave/Destroy()
	. = ..()
	SSgraveyard.graves -= src
