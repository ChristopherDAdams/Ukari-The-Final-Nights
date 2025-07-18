//This simply sets up the character's personal TGUI display.
/datum/component/about_me/ui_state(mob/user)
    return GLOB.always_state

/datum/component/about_me/ui_data(mob/user)
    return get_full_payload()

/datum/component/about_me/ui_static_data(mob/user)
    return list()

/datum/component/about_me/ui_interact(mob/user, datum/tgui/ui)
    ui = SStgui.try_update_ui(user, src, ui)
    if(!ui)
        ui = new(user, src, "AboutmeInt")
        ui.open()

//Saves on Close.
/datum/component/about_me/ui_close(mob/user)
	. = ..()

	message_admins("[src]: ui_close() — about_me data saved for [owner?.ckey].")

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


//BUTTONS!
/datum/component/about_me/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	// ------ Memory Actions ------
	//if (action == "create_memory")
	//	src.prompt_create_memory(ui.user)
	//	return TRUE

	//if (action == "edit_memory")
	//	src.prompt_edit_memory(ui.user)
	//	return TRUE

	//if (action == "delete_memory")
	//	src.prompt_delete_memory(ui.user)
	//	return TRUE
