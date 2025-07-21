// About Me Component (aboutme_core.dm)
// Core data holder and interface for character info, memories, relationships, chronicles, and groups
// Expands via aboutme_memories, aboutme_relationships, aboutme_chronicles, aboutme_group, etc.
// Data FOR and BY the aboutme system, is only accessed/modified through this component, and the payload it generates for TGUI.

/datum/component/about_me
    var/mob/living/carbon/human/owner
    // Only dynamic data that persists in the component
    var/sect = ""
    var/list/memories_all = list()
    var/list/relationships_all = list()
    var/list/chronicles_all = list()
    var/list/group_keys = list()

/datum/component/about_me/Initialize()
    . = ..()
    if (ismob(parent) && istype(parent, /mob/living/carbon/human))
        owner = parent
        GLOB.aboutme_components[owner.ckey] = src
        assign_groups()
        var/datum/action/about_me/about_me = new(parent)
        about_me.Grant(parent)

/datum/component/about_me/proc/get_full_payload()
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
        "tribe" = "Unknown"
    )

    if (istype(owner, /mob/living/carbon/human))
        var/mob/living/carbon/human/H = owner
        general["name"] = H.real_name || "Unknown"
        general["species"] = iskindred(H) ? "Kindred" : isgarou(H) ? "Fera" : ishuman(H) ? "Human" : "Unknown"
        general["role"] = H.mind?.assigned_role || "Unknown"
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
        // Kindred details
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
            species["clan"] = H.clan.name || "Unknown"
            species["generation"] = H.generation || "Unknown"
            species["masquerade"] = !isnull(H.masquerade) ? H.masquerade : "0"
            species["humanity"] = H.morality_path?.score || "Unknown"
            species["disciplines"] = discipline_list
        // Garou details
        else if (isgarou(H))
            var/datum/garou_tribe/gtribe = H.auspice?.tribe
            species["tribe"] = gtribe?.name || "Unknown"
        // If neither, leave defaults above.
	//Uses keys to know what to display from the ssrpmanagement subsystem.
	//NO DUPLICATE groups relationships, memories, or chronicles. Data effecient.
    var/list/group_objects = export_group_payload()      ; if (!islist(group_objects)) group_objects = list()
    var/list/relationships = export_relationships()      ; if (!islist(relationships)) relationships = list()
    var/list/memories = export_memory()                  ; if (!islist(memories)) memories = list()
    var/list/chronicle = export_chronicle()              ; if (!islist(chronicle)) chronicle = list()

    return list(
        "overview" = list(
            "general" = general,
            "species" = species
        ),
        "groups" = group_objects,
        "relationships" = relationships,
        "memories" = memories,
        "chronicle" = chronicle
    )

// --- Debug Verb ---
/client/verb/DebugAboutMePayload()
    set name = "About Me Debug Payload"
    set category = "IC"
    if (!istype(mob, /mob/living/carbon/human)) return
    var/mob/living/carbon/human/H = mob
    var/datum/component/about_me/C = H.GetComponent(/datum/component/about_me)
    if (!C) return
    to_chat(src, "<span class='notice'>[json_encode(C.get_full_payload(), TRUE)]</span>")
//Data packaging. Takes datums down to lists of strings and keys so the UI can use it.
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
    for (var/G in relationships_all)
        if (!istype(G, /datum/group)) continue
        var/datum/group/group = G
        exported += list(list(
            "id" = group.id,
            "name" = group.name,
            "relationship_type" = group.get_relationship_type(owner), // e.g. "Clan", "Sect", "Coterie"
            "strength" = "Member", // Or whatever logic you want
        ))
    // In the future, merge relationships_all as well!
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

