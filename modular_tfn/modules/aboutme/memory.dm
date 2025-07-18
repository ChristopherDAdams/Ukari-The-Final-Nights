/datum/memory
	var/id // Unique memory ID.
	var/title = ""
	var/details = ""
	var/tags = ""

/datum/memory/proc/export_data()
    return list(
        "id" = id,
        "title" = title,
        "details" = details,
        "tags" = tags,      // list of tag strings, e.g. ["background","clan"]
    )
