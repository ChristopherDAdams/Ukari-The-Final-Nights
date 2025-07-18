// ================================
// RP Management Subsystem - ssrpmanagement.dm (CLEAN)
// ================================
// Centralizes all group and persistence logic under the RP Management subsystem.
// ================================
GLOBAL_LIST_EMPTY(groups)
GLOBAL_LIST_EMPTY(canonical_groups)
GLOBAL_LIST_EMPTY(aboutme_components) //All aboutme_components
GLOBAL_LIST_EMPTY(chronicles)         // All chronicle datums for the round

var/global/list/canonical_groups = list(
    // --- City
    GROUP_KEY_CITY = /datum/group/city/SanFrancisco,
    // --- Factions
    GROUP_KEY_FACTION_UNKNOWING = /datum/group/faction/citizen,
    GROUP_KEY_FACTION_KINDRED   = /datum/group/faction/kindred,
    GROUP_KEY_FACTION_FERA      = /datum/group/faction/fera,
    GROUP_KEY_FACTION_HUNTERS   = /datum/group/faction/hunter,
    // --- Sects
    GROUP_KEY_SECT_CAMARILLA    = /datum/group/sect/camarilla,
    GROUP_KEY_SECT_ANARCHS      = /datum/group/sect/anarchs,
    GROUP_KEY_SECT_SABBAT       = /datum/group/sect/sabbat,
    GROUP_KEY_SECT_INDEPENDENT  = /datum/group/sect/independent,
    GROUP_KEY_SECT_PAINTEDCITY  = /datum/group/sect/paintedcity,
    GROUP_KEY_SECT_AMBERGLADE   = /datum/group/sect/amberglade,
    GROUP_KEY_SECT_POISONEDSHORE = /datum/group/sect/poisonedshore,
    // --- Clans (add all you want here)
    GROUP_KEY_CLAN_VENTRUE                = /datum/group/clan/ventrue,
    GROUP_KEY_CLAN_BRUJAH                 = /datum/group/clan/brujah,
    GROUP_KEY_CLAN_TOREADOR               = /datum/group/clan/toreador,
    GROUP_KEY_CLAN_MALKAVIAN              = /datum/group/clan/malkavian,
    GROUP_KEY_CLAN_NOSFERATU              = /datum/group/clan/nosferatu,
    GROUP_KEY_CLAN_GANGREL                = /datum/group/clan/gangrel,
    GROUP_KEY_CLAN_TREMERE                = /datum/group/clan/tremere,
    GROUP_KEY_CLAN_LASOMBRA               = /datum/group/clan/lasombra,
    GROUP_KEY_CLAN_TZIMISCE               = /datum/group/clan/tzimisce,
    GROUP_KEY_CLAN_MINISTRY               = /datum/group/clan/ministry,
    GROUP_KEY_CLAN_GIOVANNI               = /datum/group/clan/giovanni,
    GROUP_KEY_CLAN_SALUBRI                = /datum/group/clan/salubri,
    GROUP_KEY_CLAN_DAUGHTERS_OF_CACOPHONY = /datum/group/clan/daughters_of_cacophony,
    GROUP_KEY_CLAN_BAALI                  = /datum/group/clan/baali,
    // --- Tribes
    GROUP_KEY_TRIBE_RONIN               = /datum/group/tribe/ronin,
    GROUP_KEY_TRIBE_BLACKFURIES         = /datum/group/tribe/blackfuries,
    GROUP_KEY_TRIBE_BLACKSPIRALDANCERS  = /datum/group/tribe/blackspiraldancers,
    GROUP_KEY_TRIBE_BONEGNAWERS         = /datum/group/tribe/bonegnawers,
    GROUP_KEY_TRIBE_CHILDRENOFGAIA      = /datum/group/tribe/childrenofgaia,
    GROUP_KEY_TRIBE_CORAX               = /datum/group/tribe/corax,
    GROUP_KEY_TRIBE_GALESTALKERS        = /datum/group/tribe/galestalkers,
    GROUP_KEY_TRIBE_GETOFFENRIS         = /datum/group/tribe/getoffenris,
    GROUP_KEY_TRIBE_GHOSTCOUNCIL        = /datum/group/tribe/ghostcouncil,
    GROUP_KEY_TRIBE_GLASSWALKERS        = /datum/group/tribe/glasswalkers,
    GROUP_KEY_TRIBE_HARTWARDENS         = /datum/group/tribe/hartwardens,
    GROUP_KEY_TRIBE_REDTALONS           = /datum/group/tribe/redtalons,
    GROUP_KEY_TRIBE_SHADOWLORDS         = /datum/group/tribe/shadowlords,
    GROUP_KEY_TRIBE_SILENTSTRIDERS      = /datum/group/tribe/silentstriders,
    GROUP_KEY_TRIBE_SILVERFANGS         = /datum/group/tribe/silverfangs,
    GROUP_KEY_TRIBE_STARGAZERS          = /datum/group/tribe/stargazers,
)

SUBSYSTEM_DEF(rpmanagement)
    name = "RP Management"
    init_order = INIT_ORDER_DEFAULT
    wait = 10

// Main subsystem class
/datum/controller/subsystem/rpmanagement
/datum/controller/subsystem/rpmanagement/Initialize()
    ..()
    InitAllGroups()
    return
/datum/controller/subsystem/rpmanagement/proc/InitAllGroups()
    for (var/group_key in canonical_groups)
        if (!(group_key in GLOB.groups))
            var/typepath = canonical_groups[group_key]
            GLOB.groups[group_key] = new typepath()
    message_admins("[length(GLOB.groups)] core groups initialized!")
