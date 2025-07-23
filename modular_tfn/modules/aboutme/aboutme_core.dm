// ===============================================
// About Me Component (aboutme_core.dm)
// ===============================================
//
//
// This is the core player and staff interface for the About Me system.
//
// - Each mob gets a /datum/component/about_me attached on join.
// - Stores and manages the character's About Me data (bio, goals, group keys, memories, etc).
// - Syncs and updates data from the mob to the RP Management subsystem (ssrpmanagement).
// - Prepares data to send to TGUI for display (AboutmeInt.jsx).
// - Handles updating in-memory variables when the player edits details in the UI.
// - Will support save/load for persistence in the future.
//
//  Key files connected to this component:
//    - aboutme_tgui.dm (TGUI window handler and UI dispatcher)
//    - aboutme_tgui_player_input.dm (branching input/menu logic)
//    - AboutmeInt.jsx (TGUI React UI, front-end)
//
//  For contributors: To add new fields or logic, add variables and helper procs here!
// ===============================================

/datum/component/about_me
    var/tgui_id = "AboutmeInt" //UI
    var/mob/living/carbon/human/owner
    // Core AboutMe group assignment keys
    var/role = ""
    var/species = ""
    var/sect = ""
    var/faction = ""
    var/tribe = ""
    var/clan = ""
    var/org = ""
    var/party = ""
    // Dynamic data
    var/list/memories_all = list()
    var/list/relationships_all = list()
    var/list/chronicles_all = list()
    var/list/group_keys = list()
    var/list/current_groups = list() //This is their current keys, for the round, if they got kicked out in this round, or left, etc.
    var/about_me_ui_opened = FALSE //Is the player doing stuff in here? If so, wait a sec.

    //overview
    var/goals = ""
    var/personal_quote = ""
    var/gender = "" //With pronouns!
    var/physical_desc = ""


/datum/component/about_me/Destroy() //Cleans up after itself.
    if (ismob(owner))
        remove_mob_from_all_groups(owner)
    ..()


/datum/component/about_me/Initialize()
    . = ..()
    if (ismob(parent) && istype(parent, /mob/living/carbon/human))
        owner = parent
        GLOB.aboutme_components[owner.ckey] = src
        var/datum/action/about_me/about_me = new(parent)
        about_me.Grant(parent)
    assign_groups()

/datum/component/about_me/proc/get_full_payload()
    var/mob/living/carbon/human/H = owner
    // Keep all assignment keys in sync for debug, future editing, or assignment.
    src.role    = ""
    src.species = ""
    src.clan    = ""
    src.sect    = ""
    src.faction = ""
    src.tribe   = ""

    var/list/general = list(
        "name" = "Unknown",
        "species" = "Unknown",
        "role" = "Unknown",
        "special_role" = null,
        "regnant" = null,
        "regnant_clan" = null,
        "stats" = list()
    )
    var/list/species = list(
        "clan" = "Unknown",
        "generation" = "Unknown",
        "masquerade" = "Unknown",
        "humanity" = "Unknown",
        "disciplines" = list(),
        "tribe" = "Unknown",
        "faction" = "Unknown",
        "sect" = "Unknown"
    )

    if (istype(H, /mob/living/carbon/human))
        // Assign AboutMe key strings for later use
        src.role    = H.mind?.assigned_role      || ""
        src.species = H.dna?.species?.name       || ""
        src.clan    = H.clan?.name               || ""
        src.tribe   = H.auspice?.tribe?.name     || ""
        // Faction assignment
        if (iskindred(H))
            src.faction = "Kindred"
            src.species = "Kindred" //hotfix for unimmersive text.
        else if (isgarou(H))
            src.faction = "Fera"
        else
            src.faction = "Unknowing"
        // Sect assignment based on role
        src.sect = role_to_sect(src.role)
        if (!src.sect || src.sect == "")
            src.sect = "Independent"

        // Fill out the general info for the UI
        general["name"] = H.real_name || "Unknown"
        general["species"] = src.species || "Unknown"
        general["role"] = src.role || "Unknown"
        general["special_role"] = H.mind?.special_role
        general["regnant"] = H.mind?.enslaved_to ? "[H.mind.enslaved_to]" : null
        general["stats"] = list(
            "Physique" = H.physique + H.additional_physique,
            "Dexterity" = H.dexterity + H.additional_dexterity,
            "Social" = H.social + H.additional_social,
            "Mentality" = H.mentality + H.additional_mentality,
            "Cruelty" = H.blood + H.additional_blood,
            "Lockpicking" = H.lockpicking + H.additional_lockpicking,
            "Athletics" = H.athletics + H.additional_athletics
        )

        // Fill out the species info for the UI
        if (iskindred(H))
            var/datum/species/kindred/K = H.dna?.species
            var/list/discipline_list = list()
            if (islist(K?.disciplines))
                for (var/datum/discipline/D in K.disciplines)
                    if (D)
                        discipline_list += list(list(
                            "name" = D.name,
                            "level" = D.level,
                            "desc" = D.desc || ""
                        ))
            species["clan"]        = src.clan || "Unknown"
            species["generation"]  = H.generation || "Unknown"
            species["masquerade"]  = !isnull(H.masquerade) ? H.masquerade : "0"
            species["humanity"]    = H.morality_path?.score || "Unknown"
            species["disciplines"] = discipline_list
            species["faction"]     = src.faction
            species["sect"]        = src.sect
        else if (isgarou(H))
            var/datum/garou_tribe/gtribe = H.auspice?.tribe
            species["tribe"]     = src.tribe || gtribe?.name || "Unknown"
            species["faction"]   = src.faction
            species["sect"]      = src.sect
        else
            // Default fallback for mortals/unknowns
            species["faction"] = src.faction
            species["sect"]    = src.sect

    // --- Standard group/memory/relationship export logic ---
    var/list/group_objects = export_group_payload();    if (!islist(group_objects)) group_objects = list()
    var/list/relationships = export_relationships();    if (!islist(relationships)) relationships = list()
    var/list/memories      = export_memory();           if (!islist(memories)) memories = list()
    var/list/chronicle     = export_chronicle();        if (!islist(chronicle)) chronicle = list()

    // --- Return the AboutMe payload ---
    return list(
        "overview" = list(
            "general" = general,
            "species" = species,
            "goals" = src.goals, //vars like this are set by interactions with the system.
            "personal_quote" = src.personal_quote,
            "gender" = src.gender,
            "physical_desc" = src.physical_desc
        ),
        "groups"        = group_objects,
        "relationships" = relationships,
        "memories"      = memories,
        "chronicle"     = chronicle
    )

//relationships.
/datum/component/about_me/proc/AddRelationship(target, datum/relationships/R)
    if (!R || !R.id || !R.relationship_type) return
    // Ignore system/mutual ("@"-prefixed) relationships if you wish:
    if (copytext(R.id, 1, 2) == "@")
        return

    if (!islist(relationships_all)) relationships_all = list()
    for (var/datum/relationships/EXIST in relationships_all)
        if (EXIST.id == R.id && EXIST.relationship_type == R.relationship_type)
            // Update fields if you want (optional)
            EXIST.strength = R.strength
            EXIST.desc = R.desc
            EXIST.visible = R.visible
            return // Already present (now updated)
    relationships_all += R

/datum/component/about_me/proc/GetRelationshipTo(target, group_type)
    if (!islist(relationships_all)) return null

    var/tkey = null

    if (ismob(target))
        var/mob/M = target
        tkey = M.ckey
    else if (istype(target, /datum/group))
        var/datum/group/G = target
        tkey = G.id
    else
        return null

    for (var/datum/relationships/R in relationships_all)
        if (R.relationship_type == group_type && R.id == "[owner.ckey]_[tkey]_[group_type]")
            return R
    return null





// --- Debug Verb ---
/client/verb/DebugAboutMePayload()
    set name = "About Me Debug Payload"
    set category = "IC"
    if (!istype(mob, /mob/living/carbon/human)) return
    var/mob/living/carbon/human/H = mob
    var/datum/component/about_me/C = H.GetComponent(/datum/component/about_me)
    if (!C) return
    to_chat(src, "<span class='notice'>[json_encode(C.get_full_payload(), TRUE)]</span>")

//Data packaging. Takes datums down to lists of strings and packaged keys so the UI can render it.
//This exports and sorts specific data for the about me tgui, to format it so the tgui can read it.
/datum/component/about_me/proc/export_memory()
    var/list/exported = list()
    for (var/datum/memory/M in src.memories_all)
        exported += list(M.export_data())
    return exported
/datum/component/about_me/proc/export_chronicle()
    var/list/events = list()
    for (var/event in chronicles_all)
        if (islist(event))
            events += list(event)
        else if (istype(event, /datum/chronicle))
            var/datum/chronicle/E = event
            events += list(E.GetFormattedUI())
    return events

/datum/component/about_me/proc/export_relationships()
    var/list/exported = list()
    for (var/datum/relationships/R in relationships_all)
        exported += list(list(
            "id" = R.id,
            "name" = R.name,
            "relationship_type" = R.relationship_type,
            "desc" = R.desc,
            "strength" = R.strength,
            "visible" = R.visible,
            "mutual" = R.mutual,
        ))
    return exported

/datum/component/about_me/proc/export_group_payload()
    var/list/group_objects = list()
    for (var/gkey in group_keys)
        var/datum/group/G = GLOB.groups[gkey]
        if (!istype(G, /datum/group)) continue
        var/group_type = G.group_type
        if (!group_objects[group_type])
            group_objects[group_type] = list()
        group_objects[group_type] += list(G.GetFormattedUI(owner))
    return list("group_objects" = group_objects)

