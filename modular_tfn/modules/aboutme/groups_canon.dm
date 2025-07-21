//This sets up canon groups for each component when its initialized.
//Based on character information in the component.
/datum/component/about_me/proc/assign_groups()
    src.group_keys = list()
    var/mob/living/carbon/human/H = owner
    if (!H) return

    // Always city group
    if (GLOB.groups && GLOB.groups[GROUP_KEY_CITY])
        src.group_keys += GROUP_KEY_CITY

    if (H.dna?.species.name == "Kindred")
        src.group_keys += GROUP_KEY_FACTION_KINDRED
    if (H.dna?.species.name == "Werewolf")
        src.group_keys += GROUP_KEY_FACTION_FERA
    if (ishuman(H))
        src.group_keys += GROUP_KEY_FACTION_UNKNOWING

    // Sect (fall back to independent if none)
    var/sect = src.sect
    if (!sect || sect == "")
        sect = "Independent"
    var/sect_key = GROUP_KEY_SECT(sect)
    if (GLOB.groups && GLOB.groups[sect_key])
        src.group_keys += sect_key

    // Clan (Kindred only, fallback to Caitiff)
    var/clan = H.clan.name
    var/clan_key = GROUP_KEY_CLAN(clan)
    if (GLOB.groups && GLOB.groups[clan_key])
        src.group_keys += clan_key
    else if (GLOB.groups && GLOB.groups[GROUP_KEY_CLAN_CAITIF])
        src.group_keys += GROUP_KEY_CLAN_CAITIF

    // Tribe (Fera/Garou only, fallback to Ronin)
    var/tribe = owner.auspice.tribe.name
    if (tribe != "")
        var/tribe_key = GROUP_KEY_TRIBE(tribe)
        if (GLOB.groups && GLOB.groups[tribe_key])
            src.group_keys += tribe_key
        else if (GLOB.groups && GLOB.groups[GROUP_KEY_TRIBE_RONIN])
            src.group_keys += GROUP_KEY_TRIBE_RONIN

    // Optional: organizations, parties, etc., using src.organization, src.parties, etc.

    // Debug!
    message_admins("<span class='notice'>assign_groups() FINAL: [json_encode(src.group_keys, TRUE)]</span>")

/datum/component/about_me/proc/role_to_sect(role)
    var/_role = lowertext(trim(role))
    if (findtext(_role, "prince"))
        return "Camarilla"
    // fallback:
    return "Independent"

// ---------------------------------------------
// Premade Groups!
// ---------------------------------------------
//CITY/FACTIONS/SECTS/CLANS/TRIBES/ORGANIZATIONS/PARTIES!!!
//These are the base group datums, which can be extended for fully premade groups below, or can begenerated in round, as needed.
//City is just the whole city.
/datum/group/city
    group_type = GROUP_TYPE_CITY
    tags = list(GROUP_TAG_CITY)
/datum/group/faction
    group_type = GROUP_TYPE_FACTION
    tags = list(GROUP_TAG_FACTION)
/datum/group/sect
    group_type = GROUP_TYPE_SECT
    tags = list(GROUP_TAG_SECT)
/datum/group/clan
    group_type = GROUP_TYPE_CLAN
    tags = list(GROUP_TAG_CLAN)
/datum/group/tribe
    group_type = GROUP_TYPE_TRIBE
    tags = list(GROUP_TAG_TRIBE)
// Catch-all organizations (PD, hospital, etc)
/datum/group/organization
    group_type = GROUP_TYPE_ORGANIZATION
    tags = list(GROUP_TAG_ORG)
/datum/group/party
    group_type = GROUP_TYPE_PARTY
    tags = list(GROUP_TAG_PARTY)

//PREMADE GROUPS!
//ALL OF THESE MUST HAVE A KEY FOR THEIR ID. Found in group.dm.
//The WHOLE City.
/datum/group/city/SanFrancisco
	id = GROUP_KEY_CITY
	name = "San Francisco"
	desc = "The city of San Francisco. No matter your story, citizen or visitor, your choices brought you here this night."
	leader_name = "Government/Mayor/City Council of San Francisco"
	members = list("(Everyone within the city.)") // Everyone is a member of the city, by default.
//Factions: These represent mob mentality, for example kindred whispers of sabbat can be updated here. Very Generalized
//Citizens, all city services fall under this.
/datum/group/faction/citizen
    id = GROUP_KEY_FACTION_UNKNOWING // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
    name = "Citizen of San Francisco"
    desc = "You are a just a regular citizen of San Francisco."
    leader_name = "Elected Mayor."
    members = list("(The Masses.)")
//Kindred
/datum/group/faction/kindred
    id = GROUP_KEY_FACTION_KINDRED // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
    name = "Kindred of San Francisco"
    desc = "You are a Kindred of San Francisco."
    leader_name = "Varies, between sects."
//Fera
/datum/group/faction/fera
	id = GROUP_KEY_FACTION_FERA // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
	name = "Fera of San Francisco"
	desc = "You are a Fera of San Francisco."
	leader_name = "Varies, between sects."
//Hunters
/datum/group/faction/hunter
	id = GROUP_KEY_FACTION_HUNTERS // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
	name = "Hunter of San Francisco"
	desc = "You are a hunter of San Francisco, with all that entails."
	leader_name = "Varies"
//Sects: Unlike generalized factions, sects are driven largly by player choices!
//Independent, Catch all for everyone.
/datum/group/sect/independent
	id = GROUP_KEY_SECT_INDEPENDENT
	name = "Independent"
	desc = "You are independent, and not aligned with any major sect, for now."
	leader_name = "You lead your own life, as you will."
	members = list("(Anyone not aligned with a sect.)")
//Kindred Sects, set from role
/datum/group/sect/camarilla
	id = GROUP_KEY_SECT_CAMARILLA
	name = "Camarilla"
	desc = "You are a member of the Camarilla, the largest and most influential sect of Kindred, dedicated to preserving the Traditions, and namely, the Masquerade. You maintain order among kindred."
	leader_name = "Prince"
	members = list("(All Camarilla Members.)")
/datum/group/sect/anarchs
	id = GROUP_KEY_SECT_ANARCHS
	name = "Anarch"
	desc = "You are an Anarch, a member of the Anarch Movement, which opposes the rigid hierarchy of the Camarilla and seeks greater freedom and equality among Kindred."
	leader_name = "Baron"
	members = list("(All Anarch Members.)")
/datum/group/sect/sabbat
	id = GROUP_KEY_SECT_SABBAT
	name = "Sabbat"
	desc = "You are a member of the Sabbat, a sect of Kindred that rejects human morality and embraces their predatory nature, often engaging in violent and ruthless behavior."
	leader_name = "Ductus"
	members = list("(All Sabbat Members.)")
//Fera Sects, set from role
/datum/group/sect/paintedcity
	id = GROUP_KEY_SECT_PAINTEDCITY
	name = "painted city"
	desc = "You are a member of the painted city."
	leader_name = "The Spirits?"
	members = list("(All Fera Kind, whispers between spirits.)")
/datum/group/sect/amberglade
	id = GROUP_KEY_SECT_AMBERGLADE
	name = "amber glade"
	desc = "You are a member of the amber glade."
	leader_name = "The Spirits?"
	members = list("(All Fera Kind, whispers between spirits.)")
/datum/group/sect/poisonedshore
	id = GROUP_KEY_SECT_POISONEDSHORE
	name = "poisoned shore"
	desc = "You are a member of the poisoned shore."
	leader_name = "The Spirits?"
	members = list("(All Fera Kind, whispers between spirits.)")
//Kindred Clans, set from character
/datum/group/clan/caitif
    id = GROUP_KEY_CLAN_CAITIF
    name = "Clanless"
    desc = "You are without clan."
/datum/group/clan/ventrue
    id = GROUP_KEY_CLAN_VENTRUE
    name = "Clan Ventrue"
    desc = "Clan Ventrue, the blue bloods and aristocrats of the Kindred."
/datum/group/clan/brujah
    id = GROUP_KEY_CLAN_BRUJAH
    name = "Clan Brujah"
    desc = "Clan Brujah, the rabble, rebels, and iconoclasts of the Kindred."
/datum/group/clan/toreador
    id = GROUP_KEY_CLAN_TOREADOR
    name = "Clan Toreador"
    desc = "Clan Toreador, the artistes, socialites, and patrons of the Kindred."
/datum/group/clan/malkavian
    id = GROUP_KEY_CLAN_MALKAVIAN
    name = "Clan Malkavian"
    desc = "Clan Malkavian, the seers, lunatics, and visionaries of the Kindred."
/datum/group/clan/nosferatu
    id = GROUP_KEY_CLAN_NOSFERATU
    name = "Clan Nosferatu"
    desc = "Clan Nosferatu, the outcasts, spies, and information brokers of the Kindred."
/datum/group/clan/gangrel
    id = GROUP_KEY_CLAN_GANGREL
    name = "Clan Gangrel"
    desc = "Clan Gangrel, the wanderers and shapeshifters of the Kindred."
/datum/group/clan/tremere
    id = GROUP_KEY_CLAN_TREMERE
    name = "Clan Tremere"
    desc = "Clan Tremere, the warlocks, scholars, and blood mages of the Kindred."
/datum/group/clan/lasombra
    id = GROUP_KEY_CLAN_LASOMBRA
    name = "Clan Lasombra"
    desc = "Clan Lasombra, the shadow manipulators and rulers of the Kindred."
/datum/group/clan/tzimisce
    id = GROUP_KEY_CLAN_TZIMISCE
    name = "Clan Tzimisce"
    desc = "Clan Tzimisce, the flesh-shapers and lords of horror among the Kindred."
/datum/group/clan/ministry
    id = GROUP_KEY_CLAN_MINISTRY
    name = "Clan Ministry"
    desc = "The Ministry (formerly Setites), the corrupters, tempters, and cultists of the Kindred."
/datum/group/clan/giovanni
    id = GROUP_KEY_CLAN_GIOVANNI
    name = "Clan Giovanni"
    desc = "Clan Giovanni, the necromancers and merchant princes of the Kindred."
/datum/group/clan/salubri
    id = GROUP_KEY_CLAN_SALUBRI
    name = "Clan Salubri"
    desc = "Clan Salubri, the healers, sages, and outcasts among the Kindred."
/datum/group/clan/daughters_of_cacophony
    id = GROUP_KEY_CLAN_DAUGHTERS_OF_CACOPHONY
    name = "Daughters of Cacophony"
    desc = "The Daughters of Cacophony, enigmatic sirens and masters of supernatural song."
/datum/group/clan/baali
    id = GROUP_KEY_CLAN_BAALI
    name = "Clan Baali"
    desc = "The Baali, infernalists, corrupters, and worshippers of dark powers among the Kindred."
//Fera Tribes, ronin default, set from character.
/datum/group/tribe/ronin
    id = GROUP_KEY_TRIBE_RONIN
    name = "Ronin"
    desc = "Ronin, those Garou and Fera who walk alone without tribe or allegiance."
/datum/group/tribe/blackfuries
    id = GROUP_KEY_TRIBE_BLACKFURIES
    name = "Black Furies"
    desc = "The Black Furies, protectors of the sacred and avengers of the oppressed."
/datum/group/tribe/blackspiraldancers
    id = GROUP_KEY_TRIBE_BLACKSPIRALDANCERS
    name = "Black Spiral Dancers"
    desc = "The Black Spiral Dancers, lost to the Wyrm and bringers of chaos and corruption."
/datum/group/tribe/bonegnawers
    id = GROUP_KEY_TRIBE_BONEGNAWERS
    name = "Bone Gnawers"
    desc = "The Bone Gnawers, survivors of the streets and scavengers among the Garou."
/datum/group/tribe/childrenofgaia
    id = GROUP_KEY_TRIBE_CHILDRENOFGAIA
    name = "Children of Gaia"
    desc = "The Children of Gaia, peacemakers, healers, and seekers of unity among the Garou."
/datum/group/tribe/corax
    id = GROUP_KEY_TRIBE_CORAX
    name = "Corax"
    desc = "The Corax, raven-shifters, messengers, and keepers of secrets."
/datum/group/tribe/galestalkers
    id = GROUP_KEY_TRIBE_GALESTALKERS
    name = "Gale Stalkers"
    desc = "The Gale Stalkers, elusive and wild Garou, attuned to the storm."
/datum/group/tribe/getoffenris
    id = GROUP_KEY_TRIBE_GETOFFENRIS
    name = "Get of Fenris"
    desc = "The Get of Fenris, warriors, berserkers, and defenders of Garou honor."
/datum/group/tribe/ghostcouncil
    id = GROUP_KEY_TRIBE_GHOSTCOUNCIL
    name = "Ghost Council"
    desc = "The Ghost Council, mysterious spirit-guided Garou or the wise of the Umbra."
/datum/group/tribe/glasswalkers
    id = GROUP_KEY_TRIBE_GLASSWALKERS
    name = "Glass Walkers"
    desc = "The Glass Walkers, masters of technology and urban Garou society."
/datum/group/tribe/hartwardens
    id = GROUP_KEY_TRIBE_HARTWARDENS
    name = "Hart Wardens"
    desc = "The Hart Wardens, guardians of nature and sacred lands."
/datum/group/tribe/redtalons
    id = GROUP_KEY_TRIBE_REDTALONS
    name = "Red Talons"
    desc = "The Red Talons, savage Garou, fierce protectors of the wild."
/datum/group/tribe/shadowlords
    id = GROUP_KEY_TRIBE_SHADOWLORDS
    name = "Shadow Lords"
    desc = "The Shadow Lords, cunning politicians, manipulators, and seekers of power."
/datum/group/tribe/silentstriders
    id = GROUP_KEY_TRIBE_SILENTSTRIDERS
    name = "Silent Striders"
    desc = "The Silent Striders, wanderers and messengers of the restless dead."
/datum/group/tribe/silverfangs
    id = GROUP_KEY_TRIBE_SILVERFANGS
    name = "Silver Fangs"
    desc = "The Silver Fangs, noble rulers and ancient leaders of the Garou Nation."
/datum/group/tribe/stargazers
    id = GROUP_KEY_TRIBE_STARGAZERS
    name = "Stargazers"
    desc = "The Stargazers, mystics, philosophers, and seekers of cosmic truth."
//Organizations, these are the catch all for smaller groups. Like the PD, Hospital Staff, etc.
//Set from role, or joining them in round from leaders/officers.
/datum/group/organization/primogencouncil
/datum/group/organization/government
/datum/group/organization/military
/datum/group/organization/policedepartment
/datum/group/organization/hospital
/datum/group/organization/gang
/datum/group/organization/corporation
//Squads/parties are coteries, small groups of like-minded friends or associates.
//Hunter/Swat/National Guard
/datum/group/party/hunters_squad
/datum/group/party/coterie
/datum/group/party/squad
