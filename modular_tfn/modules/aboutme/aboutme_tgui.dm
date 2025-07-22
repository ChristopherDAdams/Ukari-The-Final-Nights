// ==========================================================
// About Me TGUI Handler (aboutme_tgui.dm)
// ==========================================================
//aboutme_defines.dm is a catch all for the defines made or needed by this system.
// This file acts as the bridge between BYOND's backend and the About Me TGUI (AboutmeInt.jsx) interface.
//
// - Sets up the About Me TGUI window for each player and pushes data payloads from their /datum/component/about_me.
// - Handles ui_act() events from the frontend, routing button actions to the appropriate backend procs.
// - Ensures the UI reflects any changes made by the player or staff through About Me actions.
//
// Key Responsibilities:
//   • Create and update the About Me TGUI window
//   • Provide fresh data payloads as About Me info is edited in-round
//   • Routes all UI button actions to the correct BACKEND procs (in aboutme_core.dm and aboutme_tgui_player_input.dm)
//
// UI architecture:
//   - About Me data is gathered from the /datum/component/about_me attached to each mob.
//   - AboutmeInt.jsx (TGUI React UI) displays the info, split into Overview, Groups, Relationships, Chronicle, and Memories tabs.
//   - This handler keeps the UI and game state in sync, but does NOT do the actual game logic or data changes (that’s handled in the component and player input files).
//
// To add new actions/buttons/options:
//   - Add their routing here in ui_act() or use the existing options, then implement further logic in aboutme_tgui_player_input.dm where appropriate to keep this clean.
// ==========================================================

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
