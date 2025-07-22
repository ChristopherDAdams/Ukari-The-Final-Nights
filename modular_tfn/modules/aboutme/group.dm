//Base Group Datum
/datum/group
    var/id
    var/name = "Some Group"
    var/group_type
    var/desc
    var/tags
    var/leader_name
    var/list/leaders = list()   // List of ckeys
    var/list/officers = list()  // List of ckeys
    var/list/members = list()   // List of ckeys
    var/orders = "" //These are changeable orders, that the leader can choose.



// Given a unique key (can be ckey, real_name, or your own player key system), finds the mob reference
/datum/group/proc/locate_mob_by_target_key(target_key)
    if (!target_key) return null
    // This is a placeholder: replace with your canonical lookup logic (by ckey, real_name, etc)
    for (var/mob/living/carbon/human/M in world)
        if (M.ckey == target_key || M.real_name == target_key)
            return M
    return null

// Promote a member to leader (add to leaders list, if not present)
/datum/group/proc/promote_leader(target_key)
    var/mob/living/carbon/human/M = locate_mob_by_target_key(target_key)
    if (M)
        if (!(M in leaders)) leaders += M

// Promote a member to officer (add to officers list, if not present)
/datum/group/proc/promote_officer(target_key)
    var/mob/living/carbon/human/M = locate_mob_by_target_key(target_key)
    if (M)
        if (!(M in officers)) officers += M

// Demote a member (remove from leaders and officers, but not from members)
/datum/group/proc/demote_member(target_key)
    var/mob/living/carbon/human/M = locate_mob_by_target_key(target_key)
    if (M)
        if (M in leaders) leaders -= M
        if (M in officers) officers -= M

// Remove completely from group (from members, leaders, officers)
/datum/group/proc/remove_member_by_target_key(target_key)
    var/mob/living/carbon/human/M = locate_mob_by_target_key(target_key)
    if (M)
        if (M in members) members -= M
        if (M in leaders) leaders -= M
        if (M in officers) officers -= M












//Backend
/datum/group/proc/get_relationship_type(owner)
    switch(group_type)
        if (GROUP_TYPE_CLAN)
            return "Clan"
        if (GROUP_TYPE_SECT)
            return "Sect"
        if (GROUP_TYPE_FACTION)
            return "Faction"
        if (GROUP_TYPE_TRIBE)
            return "Tribe"
        if (GROUP_TYPE_CITY)
            return "City"
        if (GROUP_TYPE_ORGANIZATION)
            return "Organization"
        if (GROUP_TYPE_PARTY)
            return "Party"
        else
            return initial(group_type) // fallback to raw type for non-canonical groups/relationships

/datum/group/proc/GetFormattedUI(owner)
    return list(
        "id" = id,
        "name" = name,
        "type" = group_type,
        "desc" = desc,
        "tags" = tags,
        "leaders" = get_leader_display_list(),
        "leader_name" = leader_name,
        "officers" = get_officer_display_list(),
        "members" = get_member_display_list(),
        "orders" = orders
    )


//Might be multiple leaders in the case of parties or more democratic organizations, like councils.
//If a leader makes a change and there are other leaders, they have to meet 50% vote to make the change.
/datum/group/proc/get_leader_display_list()
    var/list/exported = list()
    var/list/seen = list()
    for (var/mob/living/carbon/human/H in leaders)
        if (ismob(H) && istype(H, /mob/living/carbon/human))
            if (!(H.real_name in seen))
                exported += list(H.real_name)
                seen += H.real_name
    return exported

/datum/group/proc/get_officer_display_list()
    var/list/exported = list()
    var/list/seen = list()
    for (var/mob/living/carbon/human/H in officers)
        if (ismob(H) && istype(H, /mob/living/carbon/human))
            if (!(H.real_name in seen))
                exported += list(H.real_name)
                seen += H.real_name
    return exported

/datum/group/proc/get_member_display_list()
    var/list/exported = list()
    var/list/seen = list()
    for (var/mob/living/carbon/human/H in members)
        if (ismob(H) && istype(H, /mob/living/carbon/human))
            if (!(H.real_name in seen))
                exported += list(H.real_name)
                seen += H.real_name
    return exported

// --- MEMBERS ---
/datum/group/proc/add_member(mob/living/carbon/human/M)
    if (!M || !ismob(M) || !istype(M, /mob/living/carbon/human)) return
    if (M in members)
        message_admins("DEBUG: [M.real_name] is already a member of [name]!")
        return
    // Remove from leaders/officers if present
    if (M in leaders) leaders -= M
    if (M in officers) officers -= M
    members += M
    message_admins("DEBUG: Added [M.real_name] as member to [name]")

/datum/group/proc/remove_member(mob/living/carbon/human/M)
    if (islist(members) && (M in members))
        members -= M
    if (islist(leaders) && (M in leaders))
        leaders -= M
    if (islist(officers) && (M in officers))
        officers -= M

// --- LEADERS ---
/datum/group/proc/add_leader(mob/living/carbon/human/M)
    if (!M || !ismob(M) || !istype(M, /mob/living/carbon/human)) return
    if (M in leaders)
        message_admins("DEBUG: [M.real_name] is already a leader of [name]!")
        return
    // Remove from members/officers if present
    if (M in members) members -= M
    if (M in officers) officers -= M
    leaders += M
    message_admins("DEBUG: Added [M.real_name] as leader to [name]")

/datum/group/proc/remove_leader(mob/living/carbon/human/M)
    if (!M) return
    if (M in leaders)
        leaders -= M
        message_admins("DEBUG: Removed [M.real_name] from leaders of [name]")

// --- OFFICERS ---
/datum/group/proc/add_officer(mob/living/carbon/human/M)
    if (!M || !ismob(M) || !istype(M, /mob/living/carbon/human)) return
    if (M in officers)
        message_admins("DEBUG: [M.real_name] is already an officer of [name]!")
        return
    // Remove from members/leaders if present
    if (M in members) members -= M
    if (M in leaders) leaders -= M
    officers += M
    message_admins("DEBUG: Added [M.real_name] as officer to [name]")

/datum/group/proc/remove_officer(mob/living/carbon/human/M)
    if (!M) return
    if (M in officers)
        officers -= M
        message_admins("DEBUG: Removed [M.real_name] from officers of [name]")

/datum/group/proc/generate_member_relationships()
    // Combine all members, leaders, officers into a single list (no duplicates)
    var/list/all_people = list()
    for (var/mob/living/carbon/human/M in members)
        if (M && ismob(M) && !(M in all_people))
            all_people += M
    for (var/mob/living/carbon/human/L in leaders)
        if (L && ismob(L) && !(L in all_people))
            all_people += L
    for (var/mob/living/carbon/human/O in officers)
        if (O && ismob(O) && !(O in all_people))
            all_people += O

    for (var/mob/living/carbon/human/M in all_people)
        var/datum/component/about_me/MC = M.GetComponent(/datum/component/about_me)
        if (!MC) continue

        var/group_id = istype(src, /datum/group) ? src.id : "unknown_group"
        var/desc = ""
        var/strength = 0
        var/rel_type = group_type
        switch(group_type)
            if ("clan")
                desc = "You are a member of [name], sharing blood, culture, and goals with your fellow clanmates."
                strength = 50
            if ("sect")
                desc = "Your sect allegiance lies with [name]."
                strength = 20
            if ("faction")
                desc = "You are a [name], bound by shared causes or circumstances."
                strength = 20
            if ("city")
                desc = "You reside in the city of [name], sharing its fate with other denizens."
                strength = 10
            if ("tribe")
                desc = "You are kin to the [name], united by spiritual ties and ancient oaths."
                strength = 50
            else
                rel_type = "group"
                desc = "You are a member of [name]."
                strength = 10

        var/id = "[M.ckey]_[group_id]_[rel_type]"
        if (!MC.GetRelationshipTo(src, rel_type))
            var/datum/relationships/GROUP_REL = new()
            GROUP_REL.id = id
            GROUP_REL.relationship_type = rel_type
            GROUP_REL.name = name
            GROUP_REL.desc = desc
            GROUP_REL.strength = strength
            GROUP_REL.visible = TRUE
            GROUP_REL.mutual = FALSE
            MC.AddRelationship(src, GROUP_REL)

