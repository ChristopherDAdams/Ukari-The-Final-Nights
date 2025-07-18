//Base Group Datum
/datum/group
	var/id
	var/name
	var/group_type
	var/desc
	var/tags
	var/leader_name
	var/members = list()

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
/datum/group/proc/get_member_display_list()
    var/list/exported = list()
    for (var/mob/living/carbon/human/H in members)
        if (!istype(H, /mob/living/carbon/human)) continue
        exported += list(H.real_name)
    return exported
