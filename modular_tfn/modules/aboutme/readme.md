<!-- This should be copy-pasted into the root of your module folder as readme.md -->

https://github.com/NovaSector/NovaSector/pull/<!--PR Number-->

## \<Title AboutMe>
Module ID: <!-- Uppercase, UNDERSCORE_CONNECTED name of your module, that you use to mark files. This is so people can case-sensitive search for your edits, if any. -->

### Description:
Hi! Thanks for your interest in this module, I will say outright i am not an experienced programmer, nor an experienced contributer to byond projects. I do however have a love for UI. There are likely many oversights or other ways that things could have been handled in this backend wise and i hope to make it easy to understand and modify. I will do my best to explain my reasoning and the way this works in this readme!

Player Entry Point: Human mob gets an aboutme component (aboutme_core.dm) on human component_initialize(). The component gives them an icon on the screen that they can press to view their character's about me panel. This will replace the old one, for now it leaves all that alone. This is all the player needs, and reads information from the mob. Gives them a button to open the panel, as well as sets up their group keys based on the mob. 

Once persistance saves are added to this system, lots will be possible.

Round Start: ssrpmanagement.dm : This manages all about me components and other major datums in the about me system. It sets up canon groups/relationship/and the Chronicles system, using all the components, and helps manage them for shared display in the about me menu on a player by player basis. Using only Group Keys, for now, saves will change this. Currently the Groups will hold the relationship and chronicles data for that group, on a round by round basis, and only for that round. (No saves are implimented in this version, but are planned and being prepared for.)

aboutme_defines: This is a catch all for all my defines right now, and will be cut down as needed.
aboutme_core.dm : This is the character's personal access to the aboutme system. Using the aboutme_component as a key holder.
aboutme_tgui.dm : passes the component payload, and group keys into the about me menu interface when the window opens, and allows for dynamic interaction using tgui's ui_act(). (These are Buttons!)
AboutmeInt.jsx : This is the singular Aboutme TGUI display, a single payload is deleivered to this by the component that called it, with prepared keys, and the payload information in the aboutme_component. It takes this information and sorts it into tabs. Displays the buttons for ui_act, and such forth. This is where it all comes together on the player side.

Planned staff control panel.
(StorytellerInterface.jsx) 
(storyteller_tgui.dm)
-This will display all features of the interface, and allow staff to open player aboutme_panels and interact with the information there as needed.
-This will also allow the viewing of all groups, relationships, chronicles, memories, etc, in a filterable way, for oversight and correction as needed.


(Getting a bit deeper into explaining each part.)
External Changes: (Not in the modular aboutme folder, but depends on these changes.)

Added AboutmeInt.jsx, for player interface, managed by aboutme_tgui.dm, which is a bridge between the .jsx and aboutme_core.dm

AddComponent(/datum/component/about_me) In /mob/living/carbon/human/ComponentInitialize()

Modular:
Added modular_tfn/modules/aboutme Folder.

ssrpmanagement.dm
New RP Management subsystem. This initalizes all the groups, stores shared chronicles, manages relationship maps, shares memories only as needed, and gets wiped every round, for now. This keeps it All in one place, and protects information from those who don't know it.
(For now, debugging will be handled through opening the player's about me screen. But a storyteller management tgui is planned, as above.)

About Me Component, and About Me TGUI Display:
The about_me component is attatched on character join, and manages the display of the players bio, groups, relationships, chronicles, and memories.

Core Datum Files:
group.dm, relationships.dm, chronicle.dm, memory.dm

Display:
aboutme_core.dm, aboutme_tgui.dm, aboutme_defines.dm. ssrpmangement.dm, and groups_canon.dm
Aboutme, for the player is based around their aboutme_component, and the display.


Aboutme Display Tabs:
The first page is the character's overview, and general information at a glance.

The second is Groups, all groups are the same, but wildly different in scope, they have a name, description, leaders, officers, and members.
Groups can be the entire city, factions, sects, clans/tribes, organization, or parties.

The third is Relationships. For now on round start, the only relationships are those that come from your groups, or are generated within the round.
Group type relationships are superficial ties and knowledge of a character, it can just as easily get a knife in your back, and does not reveal much.

The 4th is Chronicles.
These are citywide/group/relationship/or memory Events. Shared among groups or relationships. This allows players to create a relationship with prominate members of a group, and get access to some perks of group membership if they are trusted or recruited.


### TG Proc/File Changes:
- N/A
<!-- If you edited any core procs, you should list them here. You should specify the files and procs you changed.
E.g:
- `code/modules/mob/living.dm`: `proc/overriden_proc`, `var/overriden_var`
  -->

### Modular Overrides:
- N/A
<!-- If you added a new modular override (file or code-wise) for your module, you should list it here. Code files should specify what procs they changed, in case of multiple modules using the same file.
E.g:
- `modular_nova/master_files/sound/my_cool_sound.ogg`
- `modular_nova/master_files/code/my_modular_override.dm`: `proc/overriden_proc`, `var/overriden_var`
  -->

### Defines:
- aboutme_defines.dm (ALOT, for now.)

### Included files that are not contained in this module:
- AboutmeInt.jsx (TGUI Interface)

### Credits:
MichaelEUkari - <3 - Let's make some memories.
Soreyew - Prompted the cody bounties for factions, and a hapry favor tracking system. (Favor tracking will come with player saves.)
