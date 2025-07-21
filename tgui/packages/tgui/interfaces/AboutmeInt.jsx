import React, { useState } from 'react';
import { useBackend, useLocalState } from '../backend';
import { Section, Tabs, Box, Button, Table, LabeledList } from 'tgui-core/components';
import { Window } from '../layouts';

// ====================
// Overview Tab Section
// ====================
const OverviewSection = ({ overview = {}, status, alignment }) => {
  const { general = {}, species = {} } = overview ?? {};
  const {
    name, role, special_role, species: speciesName, regnant, regnant_clan, stats = {},
  } = general;
  const {
    clan, generation, masquerade, humanity, disciplines = [],
  } = species;

  const displayOrUnknown = val =>
    val === undefined || val === null || val === "" ? "Unknown" : val;

  return (
    <Section fill title="Overview">
      <LabeledList>
        <LabeledList.Item label="Name">{displayOrUnknown(name)}</LabeledList.Item>
        <LabeledList.Item label="Species">{displayOrUnknown(speciesName)}</LabeledList.Item>
        <LabeledList.Item label="Role">
          {displayOrUnknown(role)}{special_role && ` (${special_role})`}
        </LabeledList.Item>
        {!!clan && clan !== "None" && clan !== "Unknown" &&
          <LabeledList.Item label="Clan">{clan}</LabeledList.Item>}
        {!!generation && generation !== 13 && generation !== "13" && generation !== "Unknown" &&
          <LabeledList.Item label="Generation">{generation}</LabeledList.Item>}
        <LabeledList.Item label="Masquerade">{displayOrUnknown(masquerade)}</LabeledList.Item>
        <LabeledList.Item label="Humanity">{displayOrUnknown(humanity)}</LabeledList.Item>
        <LabeledList.Item label="Status">{displayOrUnknown(status)}</LabeledList.Item>
        <LabeledList.Item label="Alignment">{displayOrUnknown(alignment)}</LabeledList.Item>
      </LabeledList>

      {stats && Object.keys(stats).length > 0 && (
        <>
          <Box mt={2} mb={1} bold underline>Stats</Box>
          <LabeledList>
            {Object.entries(stats).map(([k, v], i) =>
              <LabeledList.Item key={i} label={k}>{v}</LabeledList.Item>
            )}
          </LabeledList>
        </>
      )}

      <Box mt={2} mb={1} bold underline>Disciplines</Box>
      {Array.isArray(disciplines) && disciplines.length > 0 ? (
        <Table>
          {disciplines.map((d, i) =>
            <Table.Row key={i}>
              <Table.Cell bold>{d.name}</Table.Cell>
              <Table.Cell>Lv. {d.level}</Table.Cell>
              <Table.Cell>{d.desc}</Table.Cell>
            </Table.Row>
          )}
        </Table>
      ) : (
        <Box italic>No disciplines known.</Box>
      )}

      {(regnant || regnant_clan) && (regnant !== "Unknown" || regnant_clan !== "Unknown") && (
        <Box mt={3}>
          <Box bold underline>(Bonded)</Box>
          {regnant && regnant !== "Unknown" && <Box><b>Regnant:</b> {regnant}</Box>}
          {regnant_clan && regnant_clan !== "Unknown" && <Box><b>Regnant Clan:</b> {regnant_clan}</Box>}
        </Box>
      )}
    </Section>
  );
};
const GROUP_TYPES_UI = [
  { key: 'city', label: 'City' },
  { key: 'faction', label: 'Faction' },
  { key: 'sect', label: 'Sect' },
  { key: 'clan', label: 'Clan' },
  { key: 'tribe', label: 'Tribe' },
  { key: 'organization', label: 'Organization (1000 XP)' },
  { key: 'party', label: 'Coterie/Party (500 XP)' },
  { key: 'player_created', label: 'Player Group' },
];


const Collapsible = ({ label, open, onClick, children }) => (
  <Box mb={1}>
    <Box style={{ cursor: 'pointer', fontWeight: 'bold' }} onClick={onClick} underline>
      {open ? '▼' : '►'} {label}
    </Box>
    {open && <Box mt={1}>{children}</Box>}
  </Box>
);

const groupByType = groupList => {
  const byType = {};
  (Array.isArray(groupList) ? groupList : []).forEach(group => {
    if (group?.type) (byType[group.type] ??= []).push(group);
  });
  return byType;
};

const GroupsSection = ({ groups = {}, act }) => {
  const [openGroup, setOpenGroup] = useLocalState('aboutme_groupopen', '');
  // Accepts: array, array-of-arrays, or {group_objects: {type: [groups...]}}
  let groupList = [];
  if (Array.isArray(groups)) {
    // Flat array of groups
    groupList = groups;
  } else if (groups && typeof groups.group_objects === 'object') {
    // { group_objects: {type: [groups]} }
    groupList = Object.values(groups.group_objects).flat();
  } else if (typeof groups === 'object') {
    // Possibly just a {type: [groups]} map
    groupList = Object.values(groups).flat();
  }
  const grouped = groupByType(groupList);

  // Render all standard group types (with labels in preferred order)
  const standardRendered = GROUP_TYPES_UI.map(({ key, label }) => {
    const gList = grouped[key] || [];
    return gList.length ? (
      <Collapsible
        key={key}
        label={prettifyGroupType(key)}
        open={openGroup === key}
        onClick={() => setOpenGroup(openGroup === key ? '' : key)}
      >
        {gList.map((group, i) => (
          <Box key={group.id || i} mb={2} style={{ border: '1px solid #333', borderRadius: 6, padding: 8 }}>
            <Box bold mb={1}>
              {group.icon && <img src={group.icon} alt="icon" style={{ height: 24, verticalAlign: 'middle', marginRight: 6 }} />}
              {group.name}
            </Box>
            <Box mb={1} italic>{group.desc}</Box>
            <Box mb={1}><b>Type:</b> {prettifyGroupType(group.type)}</Box>
            <Box mb={1}><b>Leader:</b> {group.leader}</Box>
            <Box mb={1}><b>Members:</b> {Array.isArray(group.members) && group.members.length ? group.members.join(', ') : 'None'}</Box>
            {group.member_roles && Object.keys(group.member_roles).length > 0 && (
              <Box mb={1}><b>Member Roles:</b> {Object.entries(group.member_roles).map(([ckey, role]) => `${ckey}: ${role}`).join(', ')}</Box>
            )}
            <Button icon="edit" content="Edit" onClick={() => act('edit_group', { id: group.id })} mr={1} />
            <Button icon="trash" color="bad" content="Delete" onClick={() => act('delete_group', { id: group.id })} />
          </Box>
        ))}
      </Collapsible>
    ) : null;
  });

  // Render any group types not in the preferred list (custom types, etc)
  const knownKeys = GROUP_TYPES_UI.map(x => x.key);
  const unknownTypes = Object.keys(grouped).filter(k => !knownKeys.includes(k));
  const unknownRendered = unknownTypes.map(key => {
    const gList = grouped[key] || [];
    return gList.length ? (
      <Collapsible
        key={key}
        label={prettifyGroupType(key)}
        open={openGroup === key}
        onClick={() => setOpenGroup(openGroup === key ? '' : key)}
      >
        {gList.map((group, i) => (
          <Box key={group.id || i} mb={2} style={{ border: '1px solid #333', borderRadius: 6, padding: 8 }}>
            <Box bold mb={1}>
              {group.icon && <img src={group.icon} alt="icon" style={{ height: 24, verticalAlign: 'middle', marginRight: 6 }} />}
              {group.name}
            </Box>
            <Box mb={1} italic>{group.desc}</Box>
            <Box mb={1}><b>Type:</b> {prettifyGroupType(group.type)}</Box>
            <Box mb={1}><b>Leader:</b> {group.leader}</Box>
            <Box mb={1}><b>Members:</b> {Array.isArray(group.members) && group.members.length ? group.members.join(', ') : 'None'}</Box>
            {group.member_roles && Object.keys(group.member_roles).length > 0 && (
              <Box mb={1}><b>Member Roles:</b> {Object.entries(group.member_roles).map(([ckey, role]) => `${ckey}: ${role}`).join(', ')}</Box>
            )}
            <Button icon="edit" content="Edit" onClick={() => act('edit_group', { id: group.id })} mr={1} />
            <Button icon="trash" color="bad" content="Delete" onClick={() => act('delete_group', { id: group.id })} />
          </Box>
        ))}
      </Collapsible>
    ) : null;
  });

  const noGroups = !groupList.length;

  return (
    <Section title="Groups">
      <Box mb={1}>
        <Button icon="plus" content="Create Group" onClick={() => act('create_group')} />
      </Box>
      {standardRendered}
      {unknownRendered}
      {noGroups && <Box italic>No groups joined.</Box>}
      <Box mt={3} italic>
        Player Made Groups, Coteries/Squad/Organizations are on the way!
      </Box>
    </Section>
  );
};

const GROUP_TYPES_ORDER = [
  "city", "faction", "sect", "clan", "tribe", "organization", "party"
];

const prettifyGroupType = type =>
  (type ? type.charAt(0).toUpperCase() + type.slice(1).replace(/_/g, ' ') : 'Other');

function strengthDescriptor(rel) {
  const strength = rel.strength ?? 0;
  let color = "#bbb";
  if (strength >= 75) color = "#33ff00ff";
  else if (strength >= 50) color = "#8dbb36ff";
  else if (strength > 0) color = "#d9e666ff";
  else if (strength === 0) color = "#ffffffff";
  else if (strength < 0) color = "#e40000ff";
  else color = "#d00";
  return (
    <span style={{ color, fontWeight: 600 }}>
      {strength}
    </span>
  );
}

const CollapsibleRelationship = ({ rel, open, onClick, act }) => (
  <Box mb={1} style={{ border: '1px solid #333', borderRadius: 6, padding: 8 }}>
    <Box style={{ cursor: 'pointer', fontWeight: 'bold' }} onClick={onClick} underline>
      {open ? '▼' : '►'} {rel.name || rel.id}
      <span style={{ fontWeight: 'normal', color: '#bbb' }}> ({prettifyGroupType(rel.relationship_type)})</span>
      <span style={{ float: 'right', fontWeight: 'bold' }}>{strengthDescriptor(rel)}</span>
    </Box>
    {open && (
      <Box mt={1}>
        {rel.desc && <Box mb={1} italic>{rel.desc}</Box>}
        <Box mt={1}>
          <Button icon="edit" content="Edit" onClick={() => act('edit_relationship', { id: rel.id })} mr={1} />
          <Button icon="trash" color="bad" content="Delete" onClick={() => act('delete_relationship', { id: rel.id })} />
        </Box>
      </Box>
    )}
  </Box>
);

export const RelationshipsSection = ({ relationships = [], act }) => {
  let relArray = Array.isArray(relationships)
    ? relationships
    : (relationships && typeof relationships === 'object')
      ? Object.values(relationships).flat()
      : [];

  // Sort by relationship_type (groups first, then others)
  const typeOrder = [
    "city", "faction", "sect", "clan", "tribe", "organization", "party"
  ];
  relArray.sort((a, b) => {
    const aIdx = typeOrder.indexOf(a.relationship_type);
    const bIdx = typeOrder.indexOf(b.relationship_type);
    if (aIdx !== -1 && bIdx !== -1) return aIdx - bIdx;
    if (aIdx !== -1) return -1;
    if (bIdx !== -1) return 1;
    // If both not found, sort alphabetically by type then name
    return (a.relationship_type || '').localeCompare(b.relationship_type || '') ||
            (a.name || '').localeCompare(b.name || '');
  });

  const [openIdx, setOpenIdx] = useState(null);

  return (
    <Section title="Relationships">
      {relArray.length ? (
        relArray.map((rel, i) =>
          <CollapsibleRelationship
            key={rel.id || i}
            rel={rel}
            open={openIdx === i}
            onClick={() => setOpenIdx(openIdx === i ? null : i)}
            act={act}
          />
        )
      ) : <Box italic>No relationships defined.</Box>}
      <Box mt={2}>
        <Button icon="plus" content="New Relationship" onClick={() => act('create_relationship')} />
      </Box>
    </Section>
  );
};






const ChronicleSection = ({ chronicleEvents = [], act }) => {
  const events = Array.isArray(chronicleEvents) ? chronicleEvents : [];
  return (
    <Section title="Chronicle (Events!)">
      <Button icon="plus" content="Create Chronicle" onClick={() => act('create_chronicle')} mb={1} />
      {events.length ? (
        <Table>
          {events.map((entry, i) => (
            <Table.Row key={entry.id || i}>
              <Table.Cell bold>{entry.title}</Table.Cell>
              <Table.Cell>{entry.details}</Table.Cell>
              <Table.Cell>{entry.time || entry.timestamp || "—"}</Table.Cell>
              <Table.Cell>
                <Button icon="edit" tooltip="Edit" onClick={() => act('edit_chronicle', { id: entry.id })} />
                <Button icon="trash" tooltip="Delete" color="bad" onClick={() => act('delete_chronicle', { id: entry.id })} />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      ) : <Box italic>No chronicle entries yet.</Box>}
      {events.some(e => (e.memories?.length || e.relationships?.length || e.groups?.length)) && (
        <Box mt={2}>
          <b>Related Details:</b>
          {events.map((entry, i) => (
            <Box key={entry.id || i} mb={2}>
              {entry.memories?.length > 0 && <Box mb={1}><b>Memories:</b> {entry.memories.map(m => m.title || m.name).join(', ')}</Box>}
              {entry.relationships?.length > 0 && <Box mb={1}><b>Relationships:</b> {entry.relationships.map(r => r.name).join(', ')}</Box>}
              {entry.groups?.length > 0 && <Box mb={1}><b>Groups:</b> {entry.groups.map(g => g.name).join(', ')}</Box>}
            </Box>
          ))}
        </Box>
      )}
    </Section>
  );
};

const MEMORY_TAGS_UI = [
  { value: 'all', text: 'All Memories' },
  { value: 'background', text: 'Background' },
  { value: 'current', text: 'Current' },
  { value: 'recent', text: 'Recent' },
  { value: 'goal', text: 'Goals' },
  { value: 'secret', text: 'Secrets' },
  { value: 'reputation', text: 'Reputation' },
  { value: 'relationship', text: 'Relationships' },
  { value: 'character_memories', text: 'Character Memories' },
];

const MemoriesTabsSection = ({ memories = {}, act }) => {
  const [memTab, setMemTab] = useLocalState('aboutme_memtab', 'all');
  const memObj = Array.isArray(memories) ? { memories_all: memories } : (memories || {});
  const tagFiltered = memTab === 'all'
    ? Array.isArray(memObj.memories_all) ? memObj.memories_all : []
    : Array.isArray(memObj[memTab]) ? memObj[memTab] : [];

  return (
    <Section title="Memories">
      <Box mb={2}>
        <label htmlFor="memories-dropdown"><b>Filter by Type:</b> </label>
        <select
          id="memories-dropdown"
          value={memTab}
          onChange={e => setMemTab(e.target.value)}
          style={{ marginLeft: 8, minWidth: 120 }}
        >
          {MEMORY_TAGS_UI.map(({ value, text }) => (
            <option key={value} value={value}>{text}</option>
          ))}
        </select>
        <Button icon="plus" ml={2} content="Add Memory" onClick={() => act('create_memory')} />
      </Box>
      <Table>
        {tagFiltered.length ? tagFiltered.map((mem, i) => (
          <Table.Row key={mem.id || i}>
            <Table.Cell bold>{mem.title}</Table.Cell>
            <Table.Cell>{mem.details}</Table.Cell>
            <Table.Cell>
              {mem.tags && mem.tags.length
                ? mem.tags.join(', ')
                : <span style={{ color: '#aaa', fontStyle: 'italic' }}>No tags</span>}
            </Table.Cell>
            <Table.Cell>{mem.status || "—"}</Table.Cell>
            <Table.Cell>{mem.time || "—"}</Table.Cell>
            <Table.Cell>
              <Button icon="edit" tooltip="Edit" onClick={() => act('edit_memory', { id: mem.id })} />
              <Button icon="trash" color="bad" tooltip="Delete" onClick={() => act('delete_memory', { id: mem.id })} />
            </Table.Cell>
          </Table.Row>
        )) : (
          <Table.Row>
            <Table.Cell colSpan="6" italic>No memories in this category</Table.Cell>
          </Table.Row>
        )}
      </Table>
    </Section>
  );
};

// ====================
// Main AboutMeInt UI
// ====================
export const AboutmeInt = (props, context) => {
  const { data = {}, act } = useBackend(context);

  // Defensive everywhere!
  const overview = data.overview ?? {};
  const groups = data.groups ?? {};

  // Relationships: array or .group_affiliations fallback
  const relationships = Array.isArray(data.relationships)
    ? data.relationships
    : (data.relationships?.group_affiliations ?? []);

  // Chronicle: array or .events fallback
  const chronicleEvents = Array.isArray(data.chronicle)
    ? data.chronicle
    : (data.chronicle?.events ?? []);

  // Memories: canonical object, fallback to categories, fallback to []
  const memories = Array.isArray(data.memories)
    ? { memories_all: data.memories }
    : (data.memories ?? {
        memories_all: data.memories_all ?? [],
        background: data.background ?? [],
        current: data.current ?? [],
        recent: data.recent ?? [],
        goal: data.goal ?? [],
        secret: data.secret ?? [],
        reputation: data.reputation ?? [],
      });

  const [tab, setTab] = useLocalState('aboutme_tab', 'overview');

  return (
    <Window width={400} height={600} title="About Me">
      <Window.Content scrollable>
        <Box italic mb={1}>
          Welcome to the New About Me Panel!<br />
          There is no round to round Saving, while we test this out.
        </Box>
        <Tabs>
          <Tabs.Tab selected={tab === 'overview'} onClick={() => setTab('overview')}>Overview</Tabs.Tab>
          <Tabs.Tab selected={tab === 'groups'} onClick={() => setTab('groups')}>Groups</Tabs.Tab>
          <Tabs.Tab selected={tab === 'relationships'} onClick={() => setTab('relationships')}>Relationships</Tabs.Tab>
          <Tabs.Tab selected={tab === 'chronicle'} onClick={() => setTab('chronicle')}>Chronicle</Tabs.Tab>
          <Tabs.Tab selected={tab === 'memories'} onClick={() => setTab('memories')}>Memories</Tabs.Tab>
        </Tabs>
        <Box mt={2}>
          {tab === 'groups' && <GroupsSection groups={groups} act={act} />}
          {tab === 'relationships' && <RelationshipsSection relationships={relationships} act={act} />}
          {tab === 'chronicle' && <ChronicleSection chronicleEvents={chronicleEvents} act={act} />}
          {tab === 'memories' && <MemoriesTabsSection memories={memories} act={act} />}
          {tab === 'overview' && <OverviewSection overview={overview} status={data.status} alignment={data.alignment} />}
        </Box>
        <Box mt={3}>
          <details>
            <summary>Debug: Full Payload</summary>
            <pre style={{
              maxHeight: 180,
              overflowY: 'auto',
              fontSize: 12,
              background: '#111',
              color: '#eee',
              borderRadius: 4,
              padding: 8
            }}>
              {JSON.stringify(data, null, 2)}
            </pre>
          </details>
        </Box>
      </Window.Content>
    </Window>
  );
};


AboutmeInt.displayName = 'AboutmeInt';
AboutmeInt.defaultProps = {
  id: 'AboutmeInt',
  title: 'About Me',
};
