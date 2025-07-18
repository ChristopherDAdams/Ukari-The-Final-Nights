
/datum/chronicle
	var/id
	var/title = "Untitled Chronicle"
	var/details = ""
	var/tags
	var/list/related_memories = list()         // /datum/memory
	var/list/related_relationships = list()     // /datum/relationship
	var/list/related_characters = list()       // list of ckeys
	var/list/related_groups = list()           // /datum/groups

/datum/chronicle/proc/GetFormattedUI()
    return list(
        "id" = id,
        "title" = title,
        "details" = details,
        "related_memories" = related_memories,         // list of memory ids (or empty list)
        "related_relationships" = related_relationships, // list of relationship ids (or empty list)
        "related_characters" = related_characters,       // list of ckeys or character ids
        "related_groups" = related_groups,               // list of group keys
        "tags" = tags                                    // list of chronicle tags
    )
