// ================================
// About Me TGUI: Player Input Branching Procs
// File: aboutme_tgui_player_input.dm (modular NovaSector)
// All procs are attached to /datum/component/about_me, in aboutme_core.dm
// These procs are called via aboutme_tgui's ui_act(), driven by button actions in the About Me UI.
// Each branch represents a high-level UI action and further prompts the player for their desired operation.
// ================================

//Gotta have backward to go forward.
/datum/component/about_me/proc/back_to(procname, mob/user)
    // procname: string of parent proc, e.g. "prompt_edit_overview"
    // This will call src.procname(user) if it exists.
    if(isnull(procname) || !user) return
    // Call by string (no arguments except user)
    call(src, procname)(user)


/* ----------------------------------------------------
    OVERVIEW TAB: Character Overview Edit Branches
    ----------------------------------------------------
    - Allows players to update their display info, such as name, occupation, faction, and other traits.
    - Each choice can lead to another branching prompt or a direct edit.
---------------------------------------------------- */
/// Entry prompt for overview edits (Display Name, Role, etc.)
/datum/component/about_me/proc/prompt_edit_overview(mob/user)
    var/choice = tgui_input_list(user, "Edit Overview", "Choose what to edit:", list(
        "Display Name",
        "Display Role/Occupation",
        "Character Status/Goals",
        "Clan/Tribe/Faction",
        "Other Personal Info"
    ))
    if(isnull(choice)) return
    switch(choice)
        if("Display Name") src.prompt_edit_overview_display_name(user)
        if("Role/Occupation") src.prompt_edit_overview_role(user)
        if("Status/Goals") src.prompt_edit_overview_status(user)
        if("Clan/Tribe/Faction") src.prompt_edit_overview_clan(user)
        if("Other Personal Info") src.prompt_edit_overview_other(user)

/// Edit Display Name
/datum/component/about_me/proc/prompt_edit_overview_display_name(mob/user)
    // TODO: tgui_input_text for new display name
    message_admins("[user] AboutMe: Chose to edit Display Name.")

/// Edit Role/Occupation
/datum/component/about_me/proc/prompt_edit_overview_role(mob/user)
    // TODO: tgui_input_text for new role
    message_admins("[user] AboutMe: Chose to edit Role/Occupation.")

/// Edit Status/Goals (branch: ambitions, quote)
/datum/component/about_me/proc/prompt_edit_overview_status(mob/user)
    var/choice = tgui_input_list(user, "Edit Status/Goals", "What do you want to update?", list(
        "Ambitions/Goals",
        "Personal Quote",
        "Back"
    ))
    if(isnull(choice) || choice == "Back")
        src.back_to("prompt_edit_overview", user)
        return
    // TODO: prompt for chosen item
    message_admins("[user] AboutMe: Chose to update Status/Goals: [choice]")


/// Edit Clan/Tribe/Faction
/datum/component/about_me/proc/prompt_edit_overview_clan(mob/user)
    // TODO: tgui_input_text for new clan/faction
    message_admins("[user] AboutMe: Chose to edit Clan/Tribe/Faction.")

/// Edit Other Personal Info (branch: gender, age, description)
/datum/component/about_me/proc/prompt_edit_overview_other(mob/user)
    var/choice = tgui_input_list(user, "Other Info", "Pick one:", list(
        "Gender/Pronouns",
        "Age/Origin/Birthplace",
        "Physical Description",
        "Back"
    ))
    if(isnull(choice) || choice == "Back")
        src.back_to("prompt_edit_overview", user)
        return
    // TODO: prompt for chosen item
    message_admins("[user] AboutMe: Chose to edit Other Personal Info: [choice]")

/* ----------------------------------------------------
    GROUPS TAB: Group Management Branches
    ----------------------------------------------------
    - Join, leave, view, or administer groups (factions, coteries, etc).
    - Future: Will call procs to perform the requested group operations.
---------------------------------------------------- */

/// Entry: Manage groups (join, view, admin)
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

/// Join/leave/apply to groups
/datum/component/about_me/proc/prompt_manage_groups_joinleave(mob/user)
    var/choice = tgui_input_list(user, "Join/Leave Group", "Choose:", list(
        "Join Public Group",
        "Leave Group",
        "Apply to Private Group",
        "Back"
    ))
    if(isnull(choice) || choice == "Back")
        src.back_to("prompt_manage_groups", user)
        return
    message_admins("[user] AboutMe: Group Join/Leave: [choice]")

/// View personal group memberships
/datum/component/about_me/proc/prompt_manage_groups_my(mob/user)
    message_admins("[user] AboutMe: Viewed My Groups.")

/// Group administration actions (promote/demote, disband, change icon)
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
    ----------------------------------------------------
    - Add, edit, remove, or view relationships (friend, rival, etc).
    - Future: Will let players create or modify relationships.
---------------------------------------------------- */

/// Entry: Manage relationships
/datum/component/about_me/proc/prompt_change_relationship(mob/user)
    var/choice = tgui_input_list(user, "Change Relationship", "Relationship action?", list(
        "Add New Relationship",
        "Edit/Remove Relationship",
        "View All Relationships"
    ))
    if(isnull(choice)) return
    switch(choice)
        if("Add New Relationship") src.prompt_relationship_add(user)
        if("Edit/Remove Relationship") src.prompt_relationship_manage(user)
        if("View All Relationships") message_admins("[user] AboutMe: Viewed all relationships.")

/// Add a new relationship
/datum/component/about_me/proc/prompt_relationship_add(mob/user)
    message_admins("[user] AboutMe: Add New Relationship (no further branch)")

/// Edit or remove existing relationships
/datum/component/about_me/proc/prompt_relationship_manage(mob/user)
    var/choice = tgui_input_list(user, "Manage Relationship", "Action:", list(
        "Edit Relationship",
        "Remove Relationship",
        "Back"
    ))
    if(isnull(choice) || choice == "Back")
        src.back_to("prompt_change_relationship", user)
        return
    message_admins("[user] AboutMe: Relationship Manage Action: [choice]")

/* ----------------------------------------------------
    CHRONICLE TAB: Chronicle Management
    ----------------------------------------------------
    - View or manage citywide or group chronicle events.
---------------------------------------------------- */

/// Entry: Manage chronicles
/datum/component/about_me/proc/prompt_interact_chronicle(mob/user)
    var/choice = tgui_input_list(user, "Chronicle Interaction", "Action:", list(
        "Manage Personal Chronicle",
        "Manage Group Chronicle"
    ))
    if(isnull(choice)) return
    switch(choice)
        if("Manage Personal Chronicle") src.prompt_chronicle_personal(user)
        if("Manage Group Chronicle") src.prompt_chronicle_group(user)

/// Manage personal chronicle events
/datum/component/about_me/proc/prompt_chronicle_personal(mob/user)
    message_admins("[user] AboutMe: Manage Personal Chronicle (no further branch)")

/// Manage group chronicle events
/datum/component/about_me/proc/prompt_chronicle_group(mob/user)
    message_admins("[user] AboutMe: Manage Group Chronicle (no further branch)")

/* ----------------------------------------------------
    MEMORIES TAB: Memory Management
    ----------------------------------------------------
    - Create, edit, delete, or tag memories (backgrounds, secrets, etc).
---------------------------------------------------- */

/// Entry: Manage memories
/datum/component/about_me/proc/prompt_manage_memories(mob/user)
    var/choice = tgui_input_list(user, "Manage Memories", "Memory action?", list(
        "Create Memory",
        "Edit/Delete Memory",
        "Tag or Share Memory"
    ))
    if(isnull(choice)) return
    switch(choice)
        if("Create Memory") src.prompt_memory_create(user)
        if("Edit/Delete Memory") src.prompt_memory_edit(user)
        if("Tag or Share Memory") src.prompt_memory_tag(user)

/// Create new memory
/datum/component/about_me/proc/prompt_memory_create(mob/user)
    message_admins("[user] AboutMe: Create Memory (no further branch)")

/// Edit/delete existing memory (branch)
/datum/component/about_me/proc/prompt_memory_edit(mob/user)
    var/choice = tgui_input_list(user, "Edit/Delete Memory", "Action:", list(
        "Edit Existing Memory",
        "Delete Memory",
        "Back"
    ))
    if(isnull(choice) || choice == "Back")
        src.back_to("prompt_manage_memories", user)
        return
    message_admins("[user] AboutMe: Memory Edit/Delete Action: [choice]")

/// Tag or share a memory
/datum/component/about_me/proc/prompt_memory_tag(mob/user)
    message_admins("[user] AboutMe: Tag or Share Memory (no further branch)")
