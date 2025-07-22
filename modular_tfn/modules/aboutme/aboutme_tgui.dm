/datum/component/about_me
    var/tgui_id = "AboutmeInt"
//This simply sets up the character's personal TGUI display. Once, then its gone. Used for loading in-round changed information.
/datum/component/about_me/ui_state(mob/user)
    return GLOB.always_state

/datum/component/about_me/ui_data(mob/user)
    try
        var/payload = update_payload()
        return payload // <--- No json_encode!
    catch(var/exception/e)
        return list("error" = "ui_data exception: [e]")

/datum/component/about_me/ui_static_data(mob/user)
    return list()

/datum/component/about_me/ui_interact(mob/user, datum/tgui/ui)
    if (!about_me_ui_opened) // Only assign groups when the UI is opened.
        assign_groups()
        about_me_ui_opened = TRUE
    ui = SStgui.try_update_ui(user, src, ui)
    if (!ui)
        ui = new(user, src, "AboutmeInt")
        ui.open()

/datum/component/about_me/ui_close(mob/user)
    . = ..()
    assign_groups()
    about_me_ui_opened = FALSE // Mark that UI is now closed

/datum/action/about_me
	name = "About Me"
	desc = "Press to view your About Me Menu."
	button_icon_state = "masquerade"
	check_flags = NONE
	var/datum/component/about_me/about_me_component

/datum/action/about_me/New()
	. = ..()

/datum/action/about_me/Trigger(trigger_flags)
	about_me_component = owner.GetComponent(/datum/component/about_me)
	if (about_me_component)
		about_me_component.ui_interact(owner)

// Return a native DM list, NOT a string or json_encode result
/datum/component/about_me/proc/update_payload()
    var/payload = src.get_full_payload()
    return payload


//BUTTONS! This is where the UI goes to aboutme_tgui_player_input.dm
/datum/component/about_me/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
    . = ..()
    if (.) return
    var/user = ui.user

    if (action == "edit_overview")
        src.prompt_edit_overview(user)
        return TRUE

    if (action == "manage_groups")
        src.prompt_manage_groups(user)
        return TRUE

    if (action == "change_relationship")
        src.prompt_change_relationship(user)
        return TRUE

    if (action == "interact_chronicle")
        src.prompt_interact_chronicle(user)
        return TRUE

    if (action == "manage_memories")
        src.prompt_manage_memories(user)
        return TRUE
