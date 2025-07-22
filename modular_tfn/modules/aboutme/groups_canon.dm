//This sets up groups membership for canon groups, for each component when its initialized.
//This will be cut up to downsize calls.
//Based on solely character information in the component,
//so it can change over the course of the round.
/datum/component/about_me/proc/assign_groups()
    src.group_keys = list()
    var/mob/living/carbon/human/H = owner

    // --- Always assign city group ---
    if (GLOB.groups && GLOB.groups[GROUP_KEY_CITY])
        src.group_keys += GROUP_KEY_CITY

    // --- Faction assignment (Kindred, Fera, or default) ---
    if (ishuman(H) && !iskindred(H) && !isgarou(H))
        src.group_keys += GROUP_KEY_FACTION_UNKNOWING
    if (iskindred(H) || isghoul(H))
        src.group_keys += GROUP_KEY_FACTION_KINDRED
    if (iswerewolf(H))
        src.group_keys += GROUP_KEY_FACTION_FERA

    // --- Sect assignment via role parsing ---
    var/sect_info = role_to_sect(H.mind?.assigned_role)
    var/sect = sect_info["sect"]
    if (!sect || sect == "")
        sect = "Independent"
    src.sect = sect
    var/sect_key = GROUP_KEY_SECT(sect)
    var/datum/group/sect_group = null
    if (GLOB.groups && GLOB.groups[sect_key])
        src.group_keys += sect_key
        sect_group = GLOB.groups[sect_key]
    else
        message_admins("DEBUG: SECT group not found for key: [sect_key]")

    if (sect_group)
        if (sect_info["is_leader"])
            sect_group.add_leader(H)
        else if (sect_info["is_officer"])
            sect_group.add_officer(H)
        else
            sect_group.add_member(H)

    // --- Clan assignment (Kindred only, fallback to Caitiff) ---
    if (iskindred(H))
        var/clan = lowertext(trim(H.clan?.name))
        src.clan = clan
        var/clan_key = GROUP_KEY_CLAN(clan)
        var/datum/group/clan_group = null
        if (GLOB.groups && GLOB.groups[clan_key])
            src.group_keys += clan_key
            clan_group = GLOB.groups[clan_key]
        else if (GLOB.groups && GLOB.groups[GROUP_KEY_CLAN_CAITIF])
            src.group_keys += GROUP_KEY_CLAN_CAITIF
            clan_group = GLOB.groups[GROUP_KEY_CLAN_CAITIF]
        else
            message_admins("DEBUG: CLAN group not found for clan_key or CAITIF")

        if (clan_group)
            var/clan_info = role_to_clan_role(H.mind?.assigned_role)
            if (clan_info["is_leader"])
                clan_group.add_leader(H)
            else if (clan_info["is_officer"])
                clan_group.add_officer(H)
            else
                clan_group.add_member(H)


    // --- Tribe assignment (Garou/Fera only, fallback to Ronin) ---
    if (isgarou(H) || iswerewolf(H))
        var/tribe = H.auspice?.tribe?.name || ""
        src.tribe = tribe
        var/tribe_key = tribe ? GROUP_KEY_TRIBE(tribe) : GROUP_KEY_TRIBE_RONIN
        var/datum/group/tribe_group = null
        if (GLOB.groups && GLOB.groups[tribe_key])
            src.group_keys += tribe_key
            tribe_group = GLOB.groups[tribe_key]
        else if (GLOB.groups && GLOB.groups[GROUP_KEY_TRIBE_RONIN])
            src.group_keys += GROUP_KEY_TRIBE_RONIN
            tribe_group = GLOB.groups[GROUP_KEY_TRIBE_RONIN]
        else
            message_admins("DEBUG: TRIBE group not found for tribe_key or RONIN")

        if (tribe_group)
            // Use role-based logic for tribe leader/officer/member
            var/tribe_info = role_to_tribe_role(H.mind?.assigned_role)
            if (tribe_info["is_leader"])
                tribe_group.add_leader(H)
            else if (tribe_info["is_officer"])
                tribe_group.add_officer(H)
            else
                tribe_group.add_member(H)

    // --- Remove from groups no longer assigned ---
    if (!islist(src.current_groups)) src.current_groups = list()
    for (var/gkey in src.current_groups)
        if (!(gkey in src.group_keys) && GLOB.groups && (gkey in GLOB.groups))
            var/datum/group/G = GLOB.groups[gkey]
            if (istype(G, /datum/group))
                G.remove_member(owner)

    // --- Update relationships for all groups ---
    for (var/gkey in src.group_keys)
        if (GLOB.groups && (gkey in GLOB.groups))
            var/datum/group/G = GLOB.groups[gkey]
            if (istype(G, /datum/group))
                G.generate_member_relationships()

    // --- Track current group state for next call ---
    src.current_groups = src.group_keys.Copy()


/datum/component/about_me/proc/remove_mob_from_all_groups(mob/living/carbon/human/M) //for disconnecting players.
    for (var/gkey in GLOB.groups)
        var/datum/group/G = GLOB.groups[gkey]
        if (istype(G, /datum/group) && (M in G.members))
            G.remove_member(M)

//This takes the roles and applies them to sects, based on keywords.
// Returns a list: list("sect", "is_leader", "is_officer")
/datum/component/about_me/proc/role_to_sect(role)
    if (!role || !istext(role))
        return list("sect"="Independent", "is_leader"=FALSE, "is_officer"=FALSE)
    var/_role = lowertext(trim(role))
    // Camarilla
    if (findtext(_role, "prince"))
        return list("sect"="Camarilla", "is_leader"=TRUE, "is_officer"=FALSE)
    if (findtext(_role, "primogen") || findtext(_role, "sheriff") || findtext(_role, "seneschal") || findtext(_role, "harpy") || findtext(_role, "hound") || findtext(_role, "tower") || findtext(_role, "chantry"))
        return list("sect"="Camarilla", "is_leader"=FALSE, "is_officer"=TRUE)
    // Anarch
    if (findtext(_role, "baron"))
        return list("sect"="Anarch", "is_leader"=TRUE, "is_officer"=FALSE)
    if (findtext(_role, "emissary") || findtext(_role, "sweeper") || findtext(_role, "bruiser"))
        return list("sect"="Anarch", "is_leader"=FALSE, "is_officer"=TRUE)
    // Sabbat
    if (findtext(_role, "ductus") || findtext(_role, "voivode"))
        return list("sect"="Sabbat", "is_leader"=TRUE, "is_officer"=FALSE)
    if (findtext(_role, "pack") || findtext(_role, "priest") || findtext(_role, "bogatyr") || findtext(_role, "zadruga"))
        return list("sect"="Sabbat", "is_leader"=FALSE, "is_officer"=TRUE)
    // Shifter (tribal)
    if (findtext(_role, "amberglade") || findtext(_role, "painted city"))
        return list("sect"="Shifter", "is_leader"=FALSE, "is_officer"=TRUE) // Adjust as needed
    // Organization
    if (findtext(_role, "endron") || findtext(_role, "police") || findtext(_role, "district attorney"))
        return list("sect"="Organization", "is_leader"=FALSE, "is_officer"=TRUE)
    // All other roles default to Independent/member
    return list("sect"="Independent", "is_leader"=FALSE, "is_officer"=FALSE)

// Returns a list: list("is_leader"=TRUE/FALSE, "is_officer"=TRUE/FALSE)
/datum/component/about_me/proc/role_to_clan_role(role)
    if (!role || !istext(role))
        return list("is_leader"=FALSE, "is_officer"=FALSE)
    var/_role = lowertext(trim(role))
    // Example: Ventrue Primogen is a leader, Clan Whip is an officer
    if (findtext(_role, "primogen"))
        return list("is_leader"=TRUE, "is_officer"=FALSE)
    if (findtext(_role, "whip") || findtext(_role, "clan officer"))
        return list("is_leader"=FALSE, "is_officer"=TRUE)
    // Add more clan titles as needed
    return list("is_leader"=FALSE, "is_officer"=FALSE)

/datum/component/about_me/proc/role_to_tribe_role(role)
    if (!role || !istext(role))
        return list("is_leader"=FALSE, "is_officer"=FALSE)
    var/_role = lowertext(trim(role))
    // Example: Tribal Elder is leader, Warder is officer
    if (findtext(_role, "elder") || findtext(_role, "chief"))
        return list("is_leader"=TRUE, "is_officer"=FALSE)
    if (findtext(_role, "warder") || findtext(_role, "speaker"))
        return list("is_leader"=FALSE, "is_officer"=TRUE)
    // Add more tribal titles as needed
    return list("is_leader"=FALSE, "is_officer"=FALSE)

// ---------------------------------------------
// Premade Groups!
// ---------------------------------------------
//CITY/FACTIONS/SECTS/CLANS/TRIBES/ORGANIZATIONS/PARTIES!!!
//This is where groups start to change a lot. The main ones stay the same though.
//These are the base group datums, datum/group/something, should NEVER be used, use these.
//These are being extended for fully premade groups and dynamics below, and will only be generated in round, as needed, in most cases.
//City is just the whole city.
/datum/group/city
    group_type = GROUP_TYPE_CITY
    tags = list(GROUP_TAG_CITY)
    orders = "'Live your life as you see fit within the confines of the city's laws.'-Mayor of San Fran"
/datum/group/faction
    group_type = GROUP_TYPE_FACTION
    tags = list(GROUP_TAG_FACTION)
    orders = "(Nothing of note is happening, currently...)"
/datum/group/sect
    group_type = GROUP_TYPE_SECT
    tags = list(GROUP_TAG_SECT)
    orders = "'(Follow the ways of the sect.)' - Leader"
/datum/group/clan
    group_type = GROUP_TYPE_CLAN
    tags = list(GROUP_TAG_CLAN)
    var/sect = "" //if applies.
    orders = "'(Follow the ways of the clan.' - Leader"
/datum/group/tribe
    group_type = GROUP_TYPE_TRIBE
    tags = list(GROUP_TAG_TRIBE)
    var/sect = ""
    orders = "'(Follow the ways of the tribe.' - Leader"
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
	leader_name = "Government/Mayor/City Council"
//Factions: These represent mob mentality, for example kindred whispers of sabbat can be updated here. Very Generalized
//Citizens, all city services fall under this.
/datum/group/faction/citizen
    id = GROUP_KEY_FACTION_UNKNOWING // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
    name = "Citizen of San Francisco"
    desc = "You are among the masses of San Francisco."
    leader_name = "The Masses."
//Kindred
/datum/group/faction/kindred
    id = GROUP_KEY_FACTION_KINDRED // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
    name = "Kindred of San Francisco"
    desc = "You are among the Kindred of San Francisco."
    leader_name = "Varies"
//Fera
/datum/group/faction/fera
	id = GROUP_KEY_FACTION_FERA // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
	name = "Fera of San Francisco"
	desc = "You are among the Fera of San Francisco."
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
//Kindred Sects, set from role
/datum/group/sect/camarilla
	id = GROUP_KEY_SECT_CAMARILLA
	name = "Camarilla"
	desc = "You are a member of the Camarilla, you are dedicated to preserving the Traditions."
	leader_name = "Prince"
/datum/group/sect/anarchs
	id = GROUP_KEY_SECT_ANARCHS
	name = "Anarch"
	desc = "You are an Anarch, a member of the Anarch Movement, which opposes the rigid hierarchy of the Camarilla and seeks greater freedom and equality among Kindred."
	leader_name = "Baron"
/datum/group/sect/sabbat
	id = GROUP_KEY_SECT_SABBAT
	name = "Sabbat"
	desc = "You are a member of the Sabbat, a sect of Kindred that rejects human morality and embraces their predatory nature, often engaging in violent and ruthless behavior."
	leader_name = "Ductus"
//Fera Sects, set from role
/datum/group/sect/paintedcity
	id = GROUP_KEY_SECT_PAINTEDCITY
	name = "painted city"
	desc = "You are a member of the painted city."
	leader_name = "The Spirits"
/datum/group/sect/amberglade
	id = GROUP_KEY_SECT_AMBERGLADE
	name = "amber glade"
	desc = "You are a member of the amber glade."
	leader_name = "The Spirits"
/datum/group/sect/poisonedshore
	id = GROUP_KEY_SECT_POISONEDSHORE
	name = "poisoned shore"
	desc = "You are a member of the poisoned shore."
	leader_name = "The Spirits"
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
// --- Government ---
/datum/group/organization/government
    id = GROUP_KEY_ORG_GOVERNMENT
    name = "San Francisco City Government"
    desc = "The officials, clerks, and leaders who keep the city running."
    leader_name = "Mayor, City Council, and Commissioners"
    orders = "" // Optionally set city policies

// --- Police Department ---
/datum/group/organization/policedepartment
    id = GROUP_KEY_ORG_POLICE
    name = "San Francisco Police Department"
    desc = "The police officers sworn to serve and protect the city."
    leader_name = "Chief of Police"
    orders = "Patrol. Monitor suspicious activity."

// --- Hospital Staff ---
/datum/group/organization/hospital
    id = GROUP_KEY_ORG_HOSPITAL
    name = "St. Mary's Hospital Staff"
    desc = "Doctors, nurses, and medical professionals of San Francisco."
    leader_name = "Chief Medical Officer"
    orders = "ER is on high alert for unusual injuries. Coordinate with PD for blood shortage."

// --- Military ---
/datum/group/organization/military
    id = GROUP_KEY_ORG_MILITARY
    name = "National Guard - San Francisco Garrison"
    desc = "National Guard soldiers stationed in the city."
    leader_name = "Colonel of the Garrison"
    orders = ""

// --- Gangs ---
/datum/group/organization/gang
    id = GROUP_KEY_ORG_BIKERGANG
    name = "The Neon Tigers"
    desc = "A street gang known for controlling parts of the Sunset District."
    leader_name = "Tiger King"
    orders = "Watch for rival gang moves near the docks."

// --- Corporation ---
/datum/group/organization/corporation
    id = GROUP_KEY_ORG_CORP
    name = "NovaGen Industries"
    desc = "A biotech megacorp with mysterious interests in San Francisco."
    leader_name = "CEO Amanda Chen"
    orders = "All research personnel report any police activity."

//Squads/parties are coteries, small groups of like-minded friends or associates.
//Hunter/Swat/National Guard
/datum/group/party/hunters_squad
/datum/group/party/coterie
/datum/group/party/squad
