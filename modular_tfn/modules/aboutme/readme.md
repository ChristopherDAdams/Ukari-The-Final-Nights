<!-- This should be copy-pasted into the root of your module folder as readme.md -->

https://github.com/NovaSector/NovaSector/pull/<!--PR Number-->

## \<Title AboutMe>

Module ID: <!-- Uppercase, UNDERSCORE_CONNECTED name of your module, that you use to mark files. This is so people can case-sensitive search for your edits, if any. -->

### Description:
External Changes:
Added AboutmeInt.jsx, to tgui interfaces, accessed by aboutme_tgui.dm
AddComponent(/datum/component/about_me) in mob/human. Using /mob/living/carbon/human/ComponentInitialize()

Modular:
Added modular_tfn/modules/aboutme Folder.
ssrpmanagement.dm
New RP Management subsystem. This initalizes all the groups, stores shared chronicles, manages relationship maps, shares memories if needed, etc. All in one place, and protects information from those who don't know it. Will be used for staff management/moderation screens.
(For now, debugging will be handled through opening the player's about me screen.)



About Me Component, and About Me TGUI Display:
The about_me component is attatched on character join, and manages the display of the players bio, groups, relationships, chronicles, and memories.

aboutme_core.dm, aboutme_tgui.dm, aboutme_defines.dm
Aboutme, for the player is based around their aboutme_component, and the display.


Aboutme Display:
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
