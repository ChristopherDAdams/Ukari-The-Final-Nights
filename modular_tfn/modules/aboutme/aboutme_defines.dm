// ===========================================================
// About Me System Defines (aboutme_defines.dm)
// ===========================================================
//
// This file contains all the core constants, macros, and key/tag definitions
// for the About Me and RP Management systems. Centralizing these here makes
// the rest of the system easy to expand and maintain.
//
// Major sections include:
//    - Group Types & Group Keys (city, faction, clan, etc)
//    - Group Tag Macros for dynamic lookup and assignment
//    - Standard group/social/setting tags
//    - Chronicle Tags (for events, wars, relationships, etc.)
//    - Relationship Types & Flags
//    - Memory Tags (for filtering About Me entries)
//
// When adding new groups, relationship types, tags, or memory types,
// always update this file!
//
// Used by: ssrpmanagement.dm, aboutme_core.dm, aboutme_tgui_player_input.dm, and TGUI UI code
// ===========================================================

// ================================
// Group Types
// ================================
#define GROUP_TYPE_CITY          "city"
#define GROUP_TYPE_FACTION       "faction"
#define GROUP_TYPE_SECT          "sect"
#define GROUP_TYPE_CLAN          "clan"
#define GROUP_TYPE_TRIBE         "tribe"
#define GROUP_TYPE_ORGANIZATION  "organization"
#define GROUP_TYPE_PARTY         "party"
/// List of valid group types
#define GROUP_TYPES list(\
	GROUP_TYPE_CITY, \
	GROUP_TYPE_FACTION, \
	GROUP_TYPE_SECT, \
	GROUP_TYPE_CLAN, \
	GROUP_TYPE_TRIBE, \
	GROUP_TYPE_ORGANIZATION, \
	GROUP_TYPE_PARTY \
)
// Group Keys
// City
#define GROUP_KEY_CITY "city"
// Factions
#define GROUP_KEY_FACTION_UNKNOWING      "faction_unknowing"
#define GROUP_KEY_FACTION_KINDRED        "faction_kindred"
#define GROUP_KEY_FACTION_FERA           "faction_fera"
#define GROUP_KEY_FACTION_HUNTERS        "faction_hunters"
// Sects
#define GROUP_KEY_SECT_INDEPENDENT       "sect_independent"
#define GROUP_KEY_SECT_CAMARILLA         "sect_camarilla"
#define GROUP_KEY_SECT_ANARCHS           "sect_anarchs"
#define GROUP_KEY_SECT_SABBAT            "sect_sabbat"
#define GROUP_KEY_SECT_PAINTEDCITY       "sect_paintedcity"
#define GROUP_KEY_SECT_AMBERGLADE        "sect_amberglade"
#define GROUP_KEY_SECT_POISONEDSHORE     "sect_poisonedshore"
// Clans
#define GROUP_KEY_CLAN_CAITIF                 "clan_caitif"
#define GROUP_KEY_CLAN_VENTRUE                "clan_ventrue"
#define GROUP_KEY_CLAN_BRUJAH                 "clan_brujah"
#define GROUP_KEY_CLAN_TOREADOR               "clan_toreador"
#define GROUP_KEY_CLAN_MALKAVIAN              "clan_malkavian"
#define GROUP_KEY_CLAN_NOSFERATU              "clan_nosferatu"
#define GROUP_KEY_CLAN_GANGREL                "clan_gangrel"
#define GROUP_KEY_CLAN_TREMERE                "clan_tremere"
#define GROUP_KEY_CLAN_LASOMBRA               "clan_lasombra"
#define GROUP_KEY_CLAN_TZIMISCE               "clan_tzimisce"
#define GROUP_KEY_CLAN_MINISTRY               "clan_ministry"
#define GROUP_KEY_CLAN_GIOVANNI               "clan_giovanni"
#define GROUP_KEY_CLAN_SALUBRI                "clan_salubri"
#define GROUP_KEY_CLAN_DAUGHTERS_OF_CACOPHONY "clan_daughters_of_cacophony"
#define GROUP_KEY_CLAN_BAALI                  "clan_baali"
// Tribes
#define GROUP_KEY_TRIBE_RONIN               "tribe_ronin"
#define GROUP_KEY_TRIBE_BLACKFURIES         "tribe_blackfuries"
#define GROUP_KEY_TRIBE_BLACKSPIRALDANCERS  "tribe_blackspiraldancers"
#define GROUP_KEY_TRIBE_BONEGNAWERS         "tribe_bonegnawers"
#define GROUP_KEY_TRIBE_CHILDRENOFGAIA      "tribe_childrenofgaia"
#define GROUP_KEY_TRIBE_CORAX               "tribe_corax"
#define GROUP_KEY_TRIBE_GALESTALKERS        "tribe_galestalkers"
#define GROUP_KEY_TRIBE_GETOFFENRIS         "tribe_getoffenris"
#define GROUP_KEY_TRIBE_GHOSTCOUNCIL        "tribe_ghostcouncil"
#define GROUP_KEY_TRIBE_GLASSWALKERS        "tribe_glasswalkers"
#define GROUP_KEY_TRIBE_HARTWARDENS         "tribe_hartwardens"
#define GROUP_KEY_TRIBE_REDTALONS           "tribe_redtalons"
#define GROUP_KEY_TRIBE_SHADOWLORDS         "tribe_shadowlords"
#define GROUP_KEY_TRIBE_SILENTSTRIDERS      "tribe_silentstriders"
#define GROUP_KEY_TRIBE_SILVERFANGS         "tribe_silverfangs"
#define GROUP_KEY_TRIBE_STARGAZERS          "tribe_stargazers"
// Organizations
#define GROUP_KEY_ORG_GOVERNMENT        "org_government"
#define GROUP_KEY_ORG_MILITARY          "org_military"
#define GROUP_KEY_ORG_POLICE  "org_police"
#define GROUP_KEY_ORG_HOSPITAL          "org_hospital"
#define GROUP_KEY_ORG_TOWER          "org_tower"
#define GROUP_KEY_ORG_PRIMOGENCOUNCIL   "org_primogencouncil"
#define GROUP_KEY_ORG_BIKERGANG   "org_bikergang"
#define GROUP_KEY_ORG_CORP   "org_primogencouncil"
// Parties
#define GROUP_KEY_PARTY_COTERIE         "party_coterie"
#define GROUP_KEY_PARTY_SQUAD           "party_squad"
// ================================
// Group Dynamic Key Construction Macros
// ================================
/// These help with dynamic lookups using keys, and the ssrpmanagement subsystem.
#define GROUP_KEY_FACTION(_id)      "faction_[lowertext(_id)]"
#define GROUP_KEY_SECT(_id)         "sect_[lowertext(_id)]"
#define GROUP_KEY_CLAN(_id)         "clan_[lowertext(_id)]"
#define GROUP_KEY_TRIBE(_id) "tribe_[lowertext(trim(replacetext(_id, " ", "")))]"
#define GROUP_KEY_ORG(_id)          "org_[lowertext(_id)]"
#define GROUP_KEY_PARTY(_id)        "party_[lowertext(_id)]"
// Group Tags, these get stacked on, Core, are all the main group types, the rest is to help define those groups, and what they can do, how they appear etc.
// --- Core/Political Structure ---
#define GROUP_TAG_CITY          "city"          // Any city or metropolitan group
#define GROUP_TAG_FACTION       "faction"       // Broad supernatural or mortal faction (Kindred, Fera, Hunter, etc)
#define GROUP_TAG_SECT          "sect"          // Sects like Camarilla, Sabbat, Anarchs, Independent, etc
#define GROUP_TAG_CLAN          "clan"          // Vampire clans, bloodlines, etc
#define GROUP_TAG_TRIBE         "tribe"         // Garou or Fera tribe
#define GROUP_TAG_ORG           "organization"  // Hospital, PD, gangs, corporations, etc
#define GROUP_TAG_PARTY         "party"         // Coteries, squads, units, etc
// --- Social/Role/Relationship ---
#define GROUP_TAG_COTERIE       "coterie"       // Small groups of player-selected associates
#define GROUP_TAG_SOCIAL        "social"        // Social clubs, events, salons, gatherings
#define GROUP_TAG_POLITICAL     "political"     // Councils, ruling bodies, governing roles
#define GROUP_TAG_HIERARCHY     "hierarchy"     // Explicitly hierarchical (e.g., Primogen, Inner Circle, Packs)
#define GROUP_TAG_WORK          "work"          // Job/Profession-based (Doctors, Police, Bartenders, etc)
#define GROUP_TAG_FAMILY        "family"        // Mortal or supernatural "family" (e.g. Giovanni family, mortal mafias)
#define GROUP_TAG_CREW          "crew"          // Heist crews, organized crime, street gangs
// --- Supernatural/Thematic ---
#define GROUP_TAG_VAMPIRE       "vampire"
#define GROUP_TAG_GAROU         "garou"
#define GROUP_TAG_FERA          "fera"
#define GROUP_TAG_WRAITH        "wraith"
#define GROUP_TAG_HUNTER        "hunter"
#define GROUP_TAG_MORTAL        "mortal"
// --- Secret/Special Access ---
#define GROUP_TAG_SECRET        "secret"        // Hidden/secret societies, cults, conspiracies
#define GROUP_TAG_CULT          "cult"          // Any cult, religious or esoteric group
#define GROUP_TAG_UNDERGROUND   "underground"   // Criminal, black market, or secret undergrounds
// --- Regional/Setting-Specific ---
#define GROUP_TAG_SANFRANCISCO  "sanfrancisco"
#define GROUP_TAG_SETTING       "setting"
#define GROUP_TAG_REGIONAL      "regional"
// --- Law/Crime/Enforcement ---
#define GROUP_TAG_LAW           "law"           // Law enforcement
#define GROUP_TAG_CRIME         "crime"         // Criminal organizations
#define GROUP_TAG_GOVERNMENT    "government"
#define GROUP_TAG_MILITARY      "military"
// --- Story/Legacy ---
#define GROUP_TAG_HISTORICAL    "historical"    // Legacy/old organizations, historical societies
// --- Miscellaneous/Custom ---
#define GROUP_TAG_PLAYER        "player"        // Player-created
#define GROUP_TAG_EVENT         "event"         // Temporary/event-based
#define GROUP_TAG_TEMPORARY     "temporary"
#define GROUP_TAG_SPECIAL       "special"
#define GROUP_TAG_CUSTOM        "custom"
// --- Complete group tag list for lookup/assignment ---
#define GROUP_TAGS list(\
    GROUP_TAG_CITY, \
    GROUP_TAG_FACTION, \
    GROUP_TAG_SECT, \
    GROUP_TAG_CLAN, \
    GROUP_TAG_TRIBE, \
    GROUP_TAG_ORG, \
    GROUP_TAG_PARTY, \
    GROUP_TAG_COTERIE, \
    GROUP_TAG_SOCIAL, \
    GROUP_TAG_POLITICAL, \
    GROUP_TAG_HIERARCHY, \
    GROUP_TAG_WORK, \
    GROUP_TAG_FAMILY, \
    GROUP_TAG_CREW, \
    GROUP_TAG_VAMPIRE, \
    GROUP_TAG_GAROU, \
    GROUP_TAG_FERA, \
    GROUP_TAG_WRAITH, \
    GROUP_TAG_MAGE, \
    GROUP_TAG_HUNTER, \
    GROUP_TAG_MORTAL, \
    GROUP_TAG_SECRET, \
    GROUP_TAG_CULT, \
    GROUP_TAG_UNDERGROUND, \
    GROUP_TAG_SANFRANCISCO, \
    GROUP_TAG_SETTING, \
    GROUP_TAG_REGIONAL, \
    GROUP_TAG_LAW, \
    GROUP_TAG_CRIME, \
    GROUP_TAG_GOVERNMENT, \
    GROUP_TAG_MILITARY, \
    GROUP_TAG_HISTORICAL, \
    GROUP_TAG_PLAYER, \
    GROUP_TAG_EVENT, \
    GROUP_TAG_TEMPORARY, \
    GROUP_TAG_SPECIAL, \
    GROUP_TAG_CUSTOM \
)

// ================================
// Chronicle Tags / Types
// ================================
#define CHRONICLE_TAG_EVENT        "event"
#define CHRONICLE_TAG_WAR          "war"
#define CHRONICLE_TAG_ROMANCE      "romance"
#define CHRONICLE_TAG_POLITICAL    "political"
#define CHRONICLE_TAG_PERSONAL     "personal"
#define CHRONICLE_TAG_TRAGEDY      "tragedy"
#define CHRONICLE_TAG_VICTORY      "victory"
#define CHRONICLE_TAG_DISCOVERY    "discovery"
#define CHRONICLE_TAG_RELATIONSHIP "relationship"

/// List of standard chronicle tags
#define CHRONICLE_TAGS list(\
	CHRONICLE_TAG_EVENT, \
	CHRONICLE_TAG_WAR, \
	CHRONICLE_TAG_ROMANCE, \
	CHRONICLE_TAG_POLITICAL, \
	CHRONICLE_TAG_PERSONAL, \
	CHRONICLE_TAG_TRAGEDY, \
	CHRONICLE_TAG_VICTORY, \
	CHRONICLE_TAG_DISCOVERY, \
	CHRONICLE_TAG_RELATIONSHIP \
)

// -------------------------
// Relationship Types
// -------------------------
#define REL_TYPE_SIRE         "sire"
#define REL_TYPE_CHILDE       "childe"
#define REL_TYPE_LOVER        "lover"
#define REL_TYPE_RIVAL        "rival"
#define REL_TYPE_ENEMY        "enemy"
#define REL_TYPE_FRIEND       "friend"
#define REL_TYPE_ALLY         "ally"
#define REL_TYPE_ACQUAINTANCE "acquaintance"
#define REL_TYPE_CONFIDANT    "confidant"
#define REL_TYPE_TARGET       "target"
#define REL_TYPE_OBSESSION    "obsession"
#define REL_TYPE_MAKER        "maker"
#define REL_TYPE_VICTIM       "victim"
#define REL_TYPE_COTERIE      "coterie"

// ================================
// Relationship Types List
// ================================
#define REL_TYPES list( \
    "Sire", \
    "Childe", \
    "Lover", \
    "Rival", \
    "Enemy", \
    "Friend", \
    "Ally", \
    "Acquaintance", \
    "Confidant", \
    "Target", \
    "Obsession", \
    "Maker", \
    "Victim", \
    "Coterie" \
)


// -------------------------
// Relationship Flags
// -------------------------
#define REL_FLAG_SECRET     (1 << 0) // Hidden from public view
#define REL_FLAG_POLITICAL  (1 << 1) // Involves clan/sect goals
#define REL_FLAG_BROKEN     (1 << 2) // Formerly close
#define REL_FLAG_OBSESSIVE  (1 << 3) // Extreme fixation
#define REL_FLAG_TENSION    (1 << 4) // On the verge of collapse
#define REL_FLAG_MAINTAINED (1 << 5) // Maintained consistently
#define REL_FLAG_NPC_ONLY   (1 << 6) // Invisible to players

// -------------------------
// Memory Tags
// -------------------------
// ================================
// Memory Tags
// ================================
#define MEMORY_TAG_BACKGROUND   "background"
#define MEMORY_TAG_CURRENT      "current"
#define MEMORY_TAG_RECENT       "recent"
#define MEMORY_TAG_GOAL         "goal"
#define MEMORY_TAG_SECRET       "secret"
#define MEMORY_TAG_REPUTATION   "reputation"
#define MEMORY_TAG_CHARACTER    "character"
#define MEMORY_TAG_GROUP        "group"
#define MEMORY_TAG_SECT         "sect"
#define MEMORY_TAG_CLAN         "clan"
#define MEMORY_TAG_COTERIE      "coterie"
#define MEMORY_TAG_EVENT        "event"
#define MEMORY_TAG_RELATIONSHIP "relationship"
#define MEMORY_TAG_PATH         "path"
#define MEMORY_TAG_DISCIPLINE   "discipline"

/// List of standard memory tags for AboutMe filtering
#define MEMORY_TAGS list(\
	MEMORY_TAG_BACKGROUND, \
	MEMORY_TAG_CURRENT, \
	MEMORY_TAG_RECENT, \
	MEMORY_TAG_GOAL, \
	MEMORY_TAG_SECRET, \
	MEMORY_TAG_REPUTATION, \
	MEMORY_TAG_CHARACTER, \
	MEMORY_TAG_GROUP, \
	MEMORY_TAG_SECT, \
	MEMORY_TAG_CLAN, \
	MEMORY_TAG_COTERIE, \
	MEMORY_TAG_EVENT, \
	MEMORY_TAG_RELATIONSHIP, \
	MEMORY_TAG_PATH, \
	MEMORY_TAG_DISCIPLINE \
)
