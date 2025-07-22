// ================================
// About Me TGUI: Player Input Branching Procs
// File: aboutme_tgui_player_input.dm (modular NovaSector)
// All procs are attached to /datum/component/about_me, in aboutme_core.dm
// These procs are called via aboutme_tgui's ui_act(), driven by button actions in the About Me UI.
// Each branch represents a high-level UI action and further prompts the player for their desired operation.
// ================================

//The procs in this file rely on the aboutme_core.dm, the components dynamic datums,
//and character holders/keys for groups, relationships, chronicle.dm, and memory.dm



//Gotta have backward to go forward.
/datum/component/about_me/proc/back_to(procname, mob/user)
    // procname: string of parent proc, e.g. "prompt_edit_overview"
    // This will call src.procname(user) if it exists.
    if(isnull(procname) || !user) return
    // Call by string (no arguments except user)
    call(src, procname)(user)


/* ----------------------------------------------------
    OVERVIEW TAB: Character Overview Edit Branches
    - Allows players to update their display info, such as status/goals and other personal details.
---------------------------------------------------- */
/// Entry point for Overview edit menu
/datum/component/about_me/proc/prompt_edit_overview(mob/user)
    var/choice = tgui_input_list(user, "Edit Overview", "Choose what to edit:", list(
        "Character Status/Goals",
        "Edit Character Details"
    ))
    if(isnull(choice)) return
    switch(choice)
        if("Character Status/Goals") src.prompt_edit_overview_status(user)
        if("Edit Character Details") src.prompt_edit_overview_other(user)

/// Edit Status/Goals (Ambitions or Personal Quote)
/datum/component/about_me/proc/prompt_edit_overview_status(mob/user)
    var/choice = tgui_input_list(user, "Edit Status/Goals", "What do you want to update?", list(
        "Ambitions/Goals",
        "Personal Quote",
        "Back"
    ))
    if(isnull(choice) || choice == "Back")
        src.back_to("prompt_edit_overview", user)
        return

    if(choice == "Ambitions/Goals")
        var/new_goals = tgui_input_text(user, "Ambitions/Goals", "What are your character's ambitions or goals?", src.goals)
        if(isnull(new_goals))
            src.back_to("prompt_edit_overview_status", user)
            return
        src.goals = new_goals
        to_chat(user, "<span class='notice'>Your ambitions/goals were updated.</span>")
        src.back_to("prompt_edit_overview_status", user)
        return

    if(choice == "Personal Quote")
        var/new_quote = tgui_input_text(user, "Personal Quote", "Enter your character's personal quote.", src.personal_quote)
        if(isnull(new_quote))
            src.back_to("prompt_edit_overview_status", user)
            return
        src.personal_quote = new_quote
        to_chat(user, "<span class='notice'>Your personal quote was updated.</span>")
        src.back_to("prompt_edit_overview_status", user)
        return

/// Edit Other Personal Info (gender/pronouns, description)
/datum/component/about_me/proc/prompt_edit_overview_other(mob/user)
    var/choice = tgui_input_list(user, "Edit Character Details", "Pick one to edit:", list(
        "Gender/Pronouns",
        "Short Physical Description",
        "Back"
    ))
    if(isnull(choice) || choice == "Back")
        src.back_to("prompt_edit_overview", user)
        return

    if(choice == "Gender/Pronouns")
        var/new_gender = tgui_input_text(user, "Gender/Pronouns", "How should others refer to you?", src.gender)
        if(isnull(new_gender))
            src.back_to("prompt_edit_overview_other", user)
            return
        src.gender = new_gender
        to_chat(user, "<span class='notice'>Your gender/pronouns were updated.</span>")
        src.back_to("prompt_edit_overview_other", user)
        return

    if(choice == "Short Physical Description")
        var/new_desc = tgui_input_text(user, "Short Physical Description", "Describe your character's appearance.", src.physical_desc)
        if(isnull(new_desc))
            src.back_to("prompt_edit_overview_other", user)
            return
        src.physical_desc = new_desc
        to_chat(user, "<span class='notice'>Your description was updated.</span>")
        src.back_to("prompt_edit_overview_other", user)
        return

/* ----------------------------------------------------
    GROUPS TAB: Group Management Branches
    - Allows the player to join public groups, apply to private groups, leave groups, or manage groups they are part of.
    - Admin functions (promote, disband, icon) are stubbed.
---------------------------------------------------- */
/// Entry: Manage groups (join/leave, view my groups, admin)
/datum/component/about_me/proc/prompt_manage_groups(mob/user)
    var/choice = tgui_input_list(user, "Manage Groups", "What group action?", list(
        "Join/Leave Group",
        "My Groups",
        "Group Administration"
    ))
    if(isnull(choice)) return
    switch(choice)
        if("Join/Leave Group") src.prompt_manage_groups_joinleave(user)
        if("My Groups") src.prompt_manage_groups_my(user)
        if("Group Administration") src.prompt_manage_groups_admin(user)


/// Join, apply, or leave
/datum/component/about_me/proc/prompt_manage_groups_joinleave(mob/user)
    var/choice = tgui_input_list(user, "Join/Leave Group", "Choose:", list(
        "Join Public Group",
        "Apply to Private Group",
        "Leave Group",
        "Back"
    ))
    if(isnull(choice) || choice == "Back")
        src.back_to("prompt_manage_groups", user)
        return

    if(choice == "Join Public Group")
        src.prompt_join_public_group(user)
        return
    if(choice == "Apply to Private Group")
        src.prompt_apply_private_group(user)
        return
    if(choice == "Leave Group")
        src.prompt_leave_group(user)
        return

/// Show joinable public groups (not already in)
/datum/component/about_me/proc/prompt_join_public_group(mob/user)
    // Gather all public groups not already joined
    var/list/available = list()
    for(var/group_key in GLOB.groups)
        var/datum/group/G = GLOB.groups[group_key]
        if(G.is_public && !(src.owner.ckey in G.members))
            available += list(G.name)
    if(!available.len)
        to_chat(user, "<span class='warning'>There are no public groups available to join!</span>")
        src.back_to("prompt_manage_groups_joinleave", user)
        return
    var/choice = tgui_input_list(user, "Join Public Group", "Choose a group to join:", available + list("Back"))
    if(isnull(choice) || choice == "Back")
        src.back_to("prompt_manage_groups_joinleave", user)
        return
    // TODO: Actually join the selected group
    message_admins("[user] AboutMe: Would join public group: [choice]")

/// Show private groups (not already in), allow applying
/datum/component/about_me/proc/prompt_apply_private_group(mob/user)
    var/list/available = list()
    for(var/group_key in GLOB.groups)
        var/datum/group/G = GLOB.groups[group_key]
        if(!G.is_public && !(src.owner.ckey in G.members))
            available += list(G.name)
    if(!available.len)
        to_chat(user, "<span class='warning'>There are no private groups available to apply for!</span>")
        src.back_to("prompt_manage_groups_joinleave", user)
        return
    var/choice = tgui_input_list(user, "Apply to Private Group", "Choose a group to apply for:", available + list("Back"))
    if(isnull(choice) || choice == "Back")
        src.back_to("prompt_manage_groups_joinleave", user)
        return
    // TODO: Actually apply for the selected private group
    message_admins("[user] AboutMe: Would apply to private group: [choice]")

/// Show groups the player is a member of, allow leaving
/datum/component/about_me/proc/prompt_leave_group(mob/user)
    var/list/joined = list()
    for(var/group_key in GLOB.groups)
        var/datum/group/G = GLOB.groups[group_key]
        if(src.owner.ckey in G.members)
            joined += list(G.name)
    if(!joined.len)
        to_chat(user, "<span class='warning'>You are not currently in any groups you can leave!</span>")
        src.back_to("prompt_manage_groups_joinleave", user)
        return
    var/choice = tgui_input_list(user, "Leave Group", "Choose a group to leave:", joined + list("Back"))
    if(isnull(choice) || choice == "Back")
        src.back_to("prompt_manage_groups_joinleave", user)
        return
    // TODO: Actually leave the selected group
    message_admins("[user] AboutMe: Would leave group: [choice]")

/// Show all groups the player is a member of (view only for now)
/datum/component/about_me/proc/prompt_manage_groups_my(mob/user)
    var/list/joined = list()
    for(var/group_key in GLOB.groups)
        var/datum/group/G = GLOB.groups[group_key]
        if(src.owner.ckey in G.members)
            joined += list(G.name)
    if(!joined.len)
        to_chat(user, "<span class='info'>You are not a member of any groups this round.</span>")
        src.back_to("prompt_manage_groups", user)
        return
    var/choice = tgui_input_list(user, "My Groups", "You are a member of:", joined + list("Back"))
    // For v1, just view and back; future: click group for admin/leave
    if(isnull(choice) || choice == "Back")
        src.back_to("prompt_manage_groups", user)
        return
    message_admins("[user] AboutMe: Looked at My Groups: [choice]")

/// Admin functions (future implementation)
/datum/component/about_me/proc/prompt_manage_groups_admin(mob/user)
    var/choice = tgui_input_list(user, "Group Administration", "Action:", list(
        "Promote/Demote Member",
        "Disband Group",
        "Change Group Icon",
        "Back"
    ))
    if(isnull(choice) || choice == "Back")
        src.back_to("prompt_manage_groups", user)
        return
    message_admins("[user] AboutMe: Group Admin Action: [choice]")



/* ----------------------------------------------------
    RELATIONSHIPS TAB: Relationship Management
    - Add, edit, remove, or view relationships (friend, rival, etc).
    - All changes are in-memory only (no persistence).
---------------------------------------------------- */

/// Entry: Manage relationships
/datum/component/about_me/proc/prompt_change_relationship(mob/user)
    var/choice = tgui_input_list(user, "Change Relationship", "Relationship action?", list(
        "Add New Relationship",
        "Edit/Remove Relationship",
        "View All Relationships",
        "Back"
    ))
    if(isnull(choice) || choice == "Back") return
    switch(choice)
        if("Add New Relationship") src.prompt_relationship_add(user)
        if("Edit/Remove Relationship") src.prompt_relationship_manage(user)
        if("View All Relationships") src.prompt_relationship_list(user)

/// Add a new relationship
/datum/component/about_me/proc/prompt_relationship_add(mob/user)
    var/rel_name = tgui_input_text(user, "Add Relationship", "Enter the character's name or group:")
    if(isnull(rel_name) || !length(rel_name))
        src.back_to("prompt_change_relationship", user)
        return

    var/rel_type = tgui_input_list(user, "Relationship Type", "Choose the relationship type:", REL_TYPES + list("Back"))
    if(isnull(rel_type) || rel_type == "Back")
        src.back_to("prompt_change_relationship", user)
        return

    var/rel_desc = tgui_input_text(user, "Details", "Add notes or details (optional):")
    // Add new relationship to the player's list
    var/relationship = list(
        "name" = rel_name,
        "type" = rel_type,
        "desc" = rel_desc,
        "id" = "[rel_name]-[rel_type]-[rand(1000,9999)]"
    )
    src.relationships_all += list(relationship)

    to_chat(user, "<span class='notice'>Relationship with [rel_name] added as [rel_type].</span>")
    src.back_to("prompt_change_relationship", user)
    return

/// Edit or remove existing relationships
/datum/component/about_me/proc/prompt_relationship_manage(mob/user)
    // Present a list of current relationships to edit/remove
    if(!src.relationships_all.len)
        to_chat(user, "<span class='warning'>You have no relationships to edit or remove.</span>")
        src.back_to("prompt_change_relationship", user)
        return

    var/list/names = list()
    for(var/i in 1 to src.relationships_all.len)
        var/r = src.relationships_all[i]
        names += list("[r["name"]] ([r["type"]])")

    var/choice = tgui_input_list(user, "Manage Relationship", "Select a relationship:", names + list("Back"))
    if(isnull(choice) || choice == "Back")
        src.back_to("prompt_change_relationship", user)
        return

    var/index = names.Find(choice)
    if(!index)
        src.back_to("prompt_change_relationship", user)
        return

    var/action = tgui_input_list(user, "Action", "What do you want to do?", list("Edit", "Remove", "Back"))
    if(isnull(action) || action == "Back")
        src.back_to("prompt_relationship_manage", user)
        return

    if(action == "Edit")
        var/new_type = tgui_input_list(user, "Relationship Type", "New type:", REL_TYPES + list("Back"))
        if(isnull(new_type) || new_type == "Back")
            src.back_to("prompt_relationship_manage", user)
            return
        var/new_desc = tgui_input_text(user, "Edit Details", "Update details:", src.relationships_all[index]["desc"])
        src.relationships_all[index]["type"] = new_type
        src.relationships_all[index]["desc"] = new_desc

        to_chat(user, "<span class='notice'>Relationship updated.</span>")
        src.back_to("prompt_relationship_manage", user)
        return

    if(action == "Remove")
        var/removed = src.relationships_all[index]["name"]
        src.relationships_all.Cut(index, index+1)

        to_chat(user, "<span class='alert'>Relationship with [removed] removed.</span>")
        src.back_to("prompt_relationship_manage", user)
        return

/// View all relationships (simple list)
/datum/component/about_me/proc/prompt_relationship_list(mob/user)
    if(!src.relationships_all.len)
        to_chat(user, "<span class='info'>You have no defined relationships yet.</span>")
        src.back_to("prompt_change_relationship", user)
        return

    var/list/names = list()
    for(var/i in 1 to src.relationships_all.len)
        var/r = src.relationships_all[i]
        names += list("[r["name"]] ([r["type"]]) - [r["desc"]]")

    tgui_input_list(user, "All Relationships", "Here are your relationships:", names + list("Back"))
    src.back_to("prompt_change_relationship", user)
    return


/* ----------------------------------------------------
    CHRONICLE TAB: Chronicle Management
    - Players can manage personal chronicle events for their character.
    - Future: Group chronicles may be managed by group leaders/staff.
---------------------------------------------------- */

/// Entry: Manage chronicles
/datum/component/about_me/proc/prompt_interact_chronicle(mob/user)
    var/choice = tgui_input_list(user, "Chronicle Interaction", "Action:", list(
        "Manage Personal Chronicle",
        "Manage Group Chronicle",
        "Back"
    ))
    if(isnull(choice) || choice == "Back") return
    switch(choice)
        if("Manage Personal Chronicle") src.prompt_chronicle_personal(user)
        if("Manage Group Chronicle") src.prompt_chronicle_group(user)

/// Manage personal chronicle events
/datum/component/about_me/proc/prompt_chronicle_personal(mob/user)
    var/choice = tgui_input_list(user, "Personal Chronicle", "Action:", list(
        "Add Chronicle Entry",
        "Edit/Remove Chronicle Entry",
        "View All Entries",
        "Back"
    ))
    if(isnull(choice) || choice == "Back")
        src.back_to("prompt_interact_chronicle", user)
        return

    if(choice == "Add Chronicle Entry")
        src.prompt_add_chronicle_entry(user)
        return

    if(choice == "Edit/Remove Chronicle Entry")
        src.prompt_manage_chronicle_entry(user)
        return

    if(choice == "View All Entries")
        src.prompt_list_chronicle_entries(user)
        return

/// Add new chronicle entry
/datum/component/about_me/proc/prompt_add_chronicle_entry(mob/user)
    var/title = tgui_input_text(user, "New Chronicle Entry", "Title or event summary:")
    if(isnull(title) || !length(title))
        src.back_to("prompt_chronicle_personal", user)
        return
    var/details = tgui_input_text(user, "Details", "Describe what happened (optional):")
    var/tag = tgui_input_list(user, "Tag", "Select a tag:", CHRONICLE_TAGS + list("Back"))
    if(isnull(tag) || tag == "Back")
        src.back_to("prompt_chronicle_personal", user)
        return
    var/entry = list(
        "title" = title,
        "details" = details,
        "tag" = tag,
        "id" = "[title]-[tag]-[rand(1000,9999)]"
    )
    src.chronicles_all += list(entry)

    to_chat(user, "<span class='notice'>Chronicle entry '[title]' added.</span>")
    src.back_to("prompt_chronicle_personal", user)
    return

/// Edit/remove existing chronicle entry
/datum/component/about_me/proc/prompt_manage_chronicle_entry(mob/user)
    if(!src.chronicles_all.len)
        to_chat(user, "<span class='warning'>You have no chronicle entries to manage.</span>")
        src.back_to("prompt_chronicle_personal", user)
        return

    var/list/titles = list()
    for(var/i in 1 to src.chronicles_all.len)
        var/e = src.chronicles_all[i]
        titles += list("[e["title"]] ([e["tag"]])")

    var/choice = tgui_input_list(user, "Edit/Remove Chronicle", "Select an entry:", titles + list("Back"))
    if(isnull(choice) || choice == "Back")
        src.back_to("prompt_chronicle_personal", user)
        return

    var/index = titles.Find(choice)
    if(!index)
        src.back_to("prompt_chronicle_personal", user)
        return

    var/action = tgui_input_list(user, "Action", "What do you want to do?", list("Edit", "Remove", "Back"))
    if(isnull(action) || action == "Back")
        src.back_to("prompt_manage_chronicle_entry", user)
        return

    if(action == "Edit")
        var/new_title = tgui_input_text(user, "Edit Title", "Update title:", src.chronicles_all[index]["title"])
        var/new_details = tgui_input_text(user, "Edit Details", "Update details:", src.chronicles_all[index]["details"])
        var/new_tag = tgui_input_list(user, "Tag", "Update tag:", CHRONICLE_TAGS + list("Back"))
        if(isnull(new_tag) || new_tag == "Back")
            src.back_to("prompt_manage_chronicle_entry", user)
            return
        src.chronicles_all[index]["title"] = new_title
        src.chronicles_all[index]["details"] = new_details
        src.chronicles_all[index]["tag"] = new_tag

        to_chat(user, "<span class='notice'>Chronicle entry updated.</span>")
        src.back_to("prompt_manage_chronicle_entry", user)
        return

    if(action == "Remove")
        var/removed = src.chronicles_all[index]["title"]
        src.chronicles_all.Cut(index, index+1)

        to_chat(user, "<span class='alert'>Chronicle entry '[removed]' removed.</span>")
        src.back_to("prompt_manage_chronicle_entry", user)
        return

/// View all chronicle entries
/datum/component/about_me/proc/prompt_list_chronicle_entries(mob/user)
    if(!src.chronicles_all.len)
        to_chat(user, "<span class='info'>You have no personal chronicle entries yet.</span>")
        src.back_to("prompt_chronicle_personal", user)
        return

    var/list/titles = list()
    for(var/i in 1 to src.chronicles_all.len)
        var/e = src.chronicles_all[i]
        titles += list("[e["title"]] ([e["tag"]]) - [e["details"]]")

    tgui_input_list(user, "All Chronicle Entries", "Your entries:", titles + list("Back"))
    src.back_to("prompt_chronicle_personal", user)
    return

/// Manage group chronicle events (stub for V1)
/datum/component/about_me/proc/prompt_chronicle_group(mob/user)
    to_chat(user, "<span class='info'>Group chronicles are not yet implemented in this version.</span>")
    src.back_to("prompt_interact_chronicle", user)
    return

/* ----------------------------------------------------
    MEMORIES TAB: Memory Management
    - Create, edit, delete, tag, or share memories (backgrounds, secrets, etc).
    - All changes are in-memory only (no persistence).
---------------------------------------------------- */

/// Entry: Manage memories
/datum/component/about_me/proc/prompt_manage_memories(mob/user)
    var/choice = tgui_input_list(user, "Manage Memories", "Memory action?", list(
        "Create Memory",
        "Edit/Delete Memory",
        "Tag or Share Memory",
        "View All Memories",
        "Back"
    ))
    if(isnull(choice) || choice == "Back") return
    switch(choice)
        if("Create Memory") src.prompt_memory_create(user)
        if("Edit/Delete Memory") src.prompt_memory_edit(user)
        if("Tag or Share Memory") src.prompt_memory_tag(user)
        if("View All Memories") src.prompt_memory_list(user)

/// Create new memory
/datum/component/about_me/proc/prompt_memory_create(mob/user)
    var/title = tgui_input_text(user, "New Memory", "Memory title or summary:")
    if(isnull(title) || !length(title))
        src.back_to("prompt_manage_memories", user)
        return
    var/details = tgui_input_text(user, "Details", "Describe the memory or its significance (optional):")
    var/tag = tgui_input_list(user, "Memory Tag", "Tag this memory:", MEMORY_TAGS + list("Back"))
    if(isnull(tag) || tag == "Back")
        src.back_to("prompt_manage_memories", user)
        return
    var/mem = list(
        "title" = title,
        "details" = details,
        "tags" = list(tag),
        "id" = "[title]-[tag]-[rand(1000,9999)]"
    )
    src.memories_all += list(mem)

    to_chat(user, "<span class='notice'>Memory '[title]' added.</span>")
    src.back_to("prompt_manage_memories", user)
    return

/// Edit or delete existing memory
/datum/component/about_me/proc/prompt_memory_edit(mob/user)
    if(!src.memories_all.len)
        to_chat(user, "<span class='warning'>You have no memories to edit or delete.</span>")
        src.back_to("prompt_manage_memories", user)
        return

    var/list/titles = list()
    for(var/i in 1 to src.memories_all.len)
        var/m = src.memories_all[i]
        var/mem_title = m["title"]
        titles += list("[mem_title]")

    var/choice = tgui_input_list(user, "Edit/Delete Memory", "Select a memory:", titles + list("Back"))
    if(isnull(choice) || choice == "Back")
        src.back_to("prompt_manage_memories", user)
        return

    var/index = titles.Find(choice)
    if(!index)
        src.back_to("prompt_manage_memories", user)
        return

    var/action = tgui_input_list(user, "Action", "What do you want to do?", list("Edit", "Delete", "Back"))
    if(isnull(action) || action == "Back")
        src.back_to("prompt_memory_edit", user)
        return

    if(action == "Edit")
        var/mem = src.memories_all[index]
        var/new_title = tgui_input_text(user, "Edit Title", "Update title:", mem["title"])
        var/new_details = tgui_input_text(user, "Edit Details", "Update details:", mem["details"])
        var/new_tag = tgui_input_list(user, "Edit Tag", "Update tag:", MEMORY_TAGS + list("Back"))
        if(isnull(new_tag) || new_tag == "Back")
            src.back_to("prompt_memory_edit", user)
            return
        src.memories_all[index]["title"] = new_title
        src.memories_all[index]["details"] = new_details
        src.memories_all[index]["tags"] = list(new_tag)
        to_chat(user, "<span class='notice'>Memory updated.</span>")
        src.back_to("prompt_memory_edit", user)
        return

    if(action == "Delete")
        var/removed = src.memories_all[index]["title"]
        src.memories_all.Cut(index, index+1)
        to_chat(user, "<span class='alert'>Memory '[removed]' deleted.</span>")
        src.back_to("prompt_memory_edit", user)
        return

/// Tag or share a memory (adds a tag)
/datum/component/about_me/proc/prompt_memory_tag(mob/user)
    if(!src.memories_all.len)
        to_chat(user, "<span class='warning'>You have no memories to tag or share.</span>")
        src.back_to("prompt_manage_memories", user)
        return

    var/list/titles = list()
    for(var/i in 1 to src.memories_all.len)
        var/m = src.memories_all[i]
        var/mem_title = m["title"]
        titles += list("[mem_title]")

    var/choice = tgui_input_list(user, "Tag/Share Memory", "Select a memory to tag/share:", titles + list("Back"))
    if(isnull(choice) || choice == "Back")
        src.back_to("prompt_manage_memories", user)
        return

    var/index = titles.Find(choice)
    if(!index)
        src.back_to("prompt_manage_memories", user)
        return

    var/new_tag = tgui_input_list(user, "Add Tag", "Select an additional tag to add:", MEMORY_TAGS + list("Back"))
    if(isnull(new_tag) || new_tag == "Back")
        src.back_to("prompt_memory_tag", user)
        return

    if(!(new_tag in src.memories_all[index]["tags"]))
        src.memories_all[index]["tags"] += new_tag


    to_chat(user, "<span class='notice'>Tag '[new_tag]' added to memory.</span>")
    src.back_to("prompt_memory_tag", user)
    return

/// View all memories (simple list)
/datum/component/about_me/proc/prompt_memory_list(mob/user)
    if(!src.memories_all.len)
        to_chat(user, "<span class='info'>You have no memories yet.</span>")
        src.back_to("prompt_manage_memories", user)
        return
    var/list/titles = list()
    for(var/i in 1 to src.memories_all.len)
        var/m = src.memories_all[i]
        var/mem_title = m["title"]
        titles += list("[mem_title]")

    tgui_input_list(user, "All Memories", "Your memories:", titles + list("Back"))
    src.back_to("prompt_manage_memories", user)
    return

