// Static catalog of the sidebar's configurable menu items, used by the
// Custom Roles "visible menu items" picker (dashboard/routes/dashboard/settings/customRoles)
// and by the sidebar itself (components-next/sidebar/provider.js) to decide
// what a role is allowed to see.
//
// Keys MUST match the `name` field of the corresponding entry in
// Sidebar.vue's `menuItems` computed exactly, since that's how the sidebar
// cross-references a role's allowlist at render time.
//
// Only structural/configurable items are listed here — sidebar nodes that
// are generated per-account at runtime (a specific label, team, inbox,
// contact segment, saved folder, etc.) aren't "menu items" in the
// role-configuration sense, so they're intentionally left out and always
// follow their parent section's visibility.
export const SIDEBAR_MENU_CATALOG = [
  { key: 'Inbox', labelKey: 'SIDEBAR.INBOX' },
  {
    key: 'Conversation',
    labelKey: 'SIDEBAR.CONVERSATIONS',
    children: [
      { key: 'All', labelKey: 'SIDEBAR.ALL_CONVERSATIONS' },
      { key: 'Mentions', labelKey: 'SIDEBAR.MENTIONED_CONVERSATIONS' },
      { key: 'Participating', labelKey: 'SIDEBAR.PARTICIPATING_CONVERSATIONS' },
      { key: 'Unattended', labelKey: 'SIDEBAR.UNATTENDED_CONVERSATIONS' },
      { key: 'Folders', labelKey: 'SIDEBAR.CUSTOM_VIEWS_FOLDER' },
      { key: 'Teams', labelKey: 'SIDEBAR.TEAMS' },
      { key: 'Channels', labelKey: 'SIDEBAR.CHANNELS' },
      { key: 'Labels', labelKey: 'SIDEBAR.LABELS' },
    ],
  },
  {
    key: 'Captain',
    labelKey: 'SIDEBAR.CAPTAIN',
    children: [
      { key: 'Overview', labelKey: 'SIDEBAR.CAPTAIN_OVERVIEW' },
      { key: 'FAQs', labelKey: 'SIDEBAR.CAPTAIN_RESPONSES' },
      { key: 'Documents', labelKey: 'SIDEBAR.CAPTAIN_DOCUMENTS' },
      { key: 'Scenarios', labelKey: 'SIDEBAR.CAPTAIN_SCENARIOS' },
      { key: 'Playground', labelKey: 'SIDEBAR.CAPTAIN_PLAYGROUND' },
      { key: 'Inboxes', labelKey: 'SIDEBAR.CAPTAIN_INBOXES' },
      { key: 'Tools', labelKey: 'SIDEBAR.CAPTAIN_TOOLS' },
      { key: 'Settings', labelKey: 'SIDEBAR.CAPTAIN_SETTINGS' },
    ],
  },
  { key: 'Calls', labelKey: 'SIDEBAR.CALLS' },
  {
    key: 'Contacts',
    labelKey: 'SIDEBAR.CONTACTS',
    children: [
      { key: 'All Contacts', labelKey: 'SIDEBAR.ALL_CONTACTS' },
      { key: 'Active', labelKey: 'SIDEBAR.ACTIVE' },
      { key: 'Segments', labelKey: 'SIDEBAR.CUSTOM_VIEWS_SEGMENTS' },
      { key: 'Tagged With', labelKey: 'SIDEBAR.TAGGED_WITH' },
    ],
  },
  {
    key: 'Companies',
    labelKey: 'SIDEBAR.COMPANIES',
    children: [{ key: 'All Companies', labelKey: 'SIDEBAR.ALL_COMPANIES' }],
  },
  {
    key: 'Reports',
    labelKey: 'SIDEBAR.REPORTS',
    children: [
      { key: 'Report Overview', labelKey: 'SIDEBAR.REPORTS_OVERVIEW' },
      { key: 'Report Conversation', labelKey: 'SIDEBAR.REPORTS_CONVERSATION' },
      { key: 'Reports Label', labelKey: 'SIDEBAR.REPORTS_LABEL' },
      { key: 'Reports Inbox', labelKey: 'SIDEBAR.REPORTS_INBOX' },
      { key: 'Reports Team', labelKey: 'SIDEBAR.REPORTS_TEAM' },
      { key: 'Reports CSAT', labelKey: 'SIDEBAR.CSAT' },
      { key: 'Reports SLA', labelKey: 'SIDEBAR.REPORTS_SLA' },
      { key: 'Reports Bot', labelKey: 'SIDEBAR.REPORTS_BOT' },
    ],
  },
  {
    key: 'Campaigns',
    labelKey: 'SIDEBAR.CAMPAIGNS',
    children: [
      { key: 'Live chat', labelKey: 'SIDEBAR.LIVE_CHAT' },
      { key: 'SMS', labelKey: 'SIDEBAR.SMS' },
      { key: 'WhatsApp', labelKey: 'SIDEBAR.WHATSAPP' },
    ],
  },
  {
    key: 'Portals',
    labelKey: 'SIDEBAR.HELP_CENTER.TITLE',
    children: [
      { key: 'Articles', labelKey: 'SIDEBAR.HELP_CENTER.ARTICLES' },
      { key: 'Categories', labelKey: 'SIDEBAR.HELP_CENTER.CATEGORIES' },
      { key: 'Locales', labelKey: 'SIDEBAR.HELP_CENTER.LOCALES' },
      { key: 'Settings', labelKey: 'SIDEBAR.HELP_CENTER.SETTINGS' },
    ],
  },
  {
    key: 'Settings',
    labelKey: 'SIDEBAR.SETTINGS',
    children: [
      {
        key: 'Settings Account Settings',
        labelKey: 'SIDEBAR.ACCOUNT_SETTINGS',
      },
      { key: 'Settings Agents', labelKey: 'SIDEBAR.AGENTS' },
      { key: 'Settings Teams', labelKey: 'SIDEBAR.TEAMS' },
      {
        key: 'Settings Agent Assignment',
        labelKey: 'SIDEBAR.AGENT_ASSIGNMENT',
      },
      { key: 'Settings Inboxes', labelKey: 'SIDEBAR.INBOXES' },
      { key: 'Settings Templates', labelKey: 'SIDEBAR.WHATSAPP_TEMPLATES' },
      { key: 'Settings Labels', labelKey: 'SIDEBAR.LABELS' },
      {
        key: 'Settings Custom Attributes',
        labelKey: 'SIDEBAR.CUSTOM_ATTRIBUTES',
      },
      { key: 'Settings Automation', labelKey: 'SIDEBAR.AUTOMATION' },
      { key: 'Settings Agent Bots', labelKey: 'SIDEBAR.AGENT_BOTS' },
      { key: 'Settings Macros', labelKey: 'SIDEBAR.MACROS' },
      {
        key: 'Settings Canned Responses',
        labelKey: 'SIDEBAR.CANNED_RESPONSES',
      },
      { key: 'Settings Integrations', labelKey: 'SIDEBAR.INTEGRATIONS' },
      { key: 'Settings Data', labelKey: 'SIDEBAR.DATA' },
      { key: 'Settings Audit Logs', labelKey: 'SIDEBAR.AUDIT_LOGS' },
      { key: 'Settings Custom Roles', labelKey: 'SIDEBAR.CUSTOM_ROLES' },
      { key: 'Settings Sla', labelKey: 'SIDEBAR.SLA' },
      {
        key: 'Conversation Workflow',
        labelKey: 'SIDEBAR.CONVERSATION_WORKFLOW',
      },
      { key: 'Settings Security', labelKey: 'SIDEBAR.SECURITY' },
      { key: 'Settings Billing', labelKey: 'SIDEBAR.BILLING' },
    ],
  },
];

// Flat list of every *checkable* key: a childless top-level item (its own
// key, e.g. "Inbox") or a child within a group (e.g. "All" under
// "Conversation"). Group headers themselves (Conversation, Reports,
// Settings...) have no route of their own — the sidebar already hides them
// once every child is hidden — so they're never stored as a key on their
// own. Used to tell "everything selected" (equivalent to unrestricted,
// stored as []) apart from a real partial restriction.
export const ALL_SIDEBAR_MENU_ITEM_KEYS = SIDEBAR_MENU_CATALOG.flatMap(
  section =>
    section.children?.length ? section.children.map(c => c.key) : [section.key]
);
