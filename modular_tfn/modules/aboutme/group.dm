//Base Group Datum
/datum/group
    var/id
    var/name
    var/group_type
    var/desc
    var/tags
    var/leader_name
    var/list/leaders = list()   // List of ckeys
    var/list/officers = list()  // List of ckeys
    var/list/members = list()   // List of ckeys

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
        "leader" = leader_name,
        "members" = get_member_display_list()
    )

/datum/group/proc/add_member(mob/living/carbon/human/M)
    if (!M || !(istype(M, /mob/living/carbon/human))) return
    if (M in members)
        message_admins("DEBUG: [M.real_name] is already a member of [name]!")
        return
    members += M
    message_admins("DEBUG: Added [M.real_name] to [name]")


/datum/group/proc/remove_member(mob/living/carbon/human/M)
    if (!M) return
    if (M in members)
        members -= M

/datum/group/proc/get_member_display_list()
    var/list/exported = list()
    var/list/seen = list()
    for (var/mob/living/carbon/human/H in members)
        if (ismob(H) && istype(H, /mob/living/carbon/human))
            if (!(H.real_name in seen))
                exported += list(H.real_name)
                seen += H.real_name
    return exported


/datum/group/proc/generate_member_relationships()
    for (var/mob/living/carbon/human/M in members)
        if (!M || !ismob(M)) continue
        var/datum/component/about_me/MC = M.GetComponent(/datum/component/about_me)
        if (!MC) continue

        var/group_id = istype(src, /datum/group) ? src.id : "unknown_group"
        var/desc = ""
        var/strength = 0
        var/rel_type = group_type // This will be e.g. "clan", "sect", "city", etc.
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
            GROUP_REL.relationship_type = rel_type // Will be one of your #define'd group types
            GROUP_REL.name = name
            GROUP_REL.desc = desc
            GROUP_REL.strength = strength
            GROUP_REL.visible = TRUE
            GROUP_REL.mutual = FALSE
            MC.AddRelationship(src, GROUP_REL)


