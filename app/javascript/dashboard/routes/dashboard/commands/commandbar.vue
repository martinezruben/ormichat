<script setup>
import { ref, toRef, computed, watch } from 'vue';
import { useStore } from 'dashboard/composables/store';
import { useTrack } from 'dashboard/composables';
import { useEmitter } from 'dashboard/composables/emitter';
import { useI18n } from 'vue-i18n';
import { useLocale } from 'shared/composables/useLocale';
import { useAppearanceHotKeys } from 'dashboard/composables/commands/useAppearanceHotKeys';
import { useInboxHotKeys } from 'dashboard/composables/commands/useInboxHotKeys';
import { useGoToCommandHotKeys } from 'dashboard/composables/commands/useGoToCommandHotKeys';
import { useBulkActionsHotKeys } from 'dashboard/composables/commands/useBulkActionsHotKeys';
import { useConversationHotKeys } from 'dashboard/composables/commands/useConversationHotKeys';
import { useMacroHotKeys } from 'dashboard/composables/commands/useMacroHotKeys';
import CommandPalette from './CommandPalette.vue';
import ConversationResolveAttributesModal from 'dashboard/components-next/ConversationWorkflow/ConversationResolveAttributesModal.vue';
import wootConstants from 'dashboard/constants/globals';
import {
  GENERAL_EVENTS,
  SNOOZE_EVENTS,
} from 'dashboard/helper/AnalyticsHelper/events';
import { generateSnoozeSuggestions } from 'dashboard/helper/snoozeHelpers';
import { ICON_SNOOZE_CONVERSATION } from 'dashboard/helper/commandbar/icons';
import {
  CMD_OPEN_COMMAND_BAR,
  CMD_SNOOZE_CONVERSATION,
  CMD_SNOOZE_NOTIFICATION,
  CMD_BULK_ACTION_SNOOZE_CONVERSATION,
} from 'dashboard/helper/commandbar/events';
import { emitter } from 'shared/helpers/mitt';

const props = defineProps({
  isPaywalled: {
    type: Boolean,
    default: false,
  },
});

const store = useStore();
const { t, tm } = useI18n();
const { resolvedLocale } = useLocale();

const palette = ref(null);
const resolveAttributesModalRef = ref(null);

// Added selectedSnoozeType to track the selected snooze type
// So if the selected snooze type is "custom snooze" then we set selectedSnoozeType with the CMD action id
// So that we can track the selected snooze type and when we close the command bar
const selectedSnoozeType = ref(null);

const { goToAppearanceHotKeys } = useAppearanceHotKeys();
const { inboxHotKeys } = useInboxHotKeys();
const { goToCommandHotKeys } = useGoToCommandHotKeys(
  toRef(props, 'isPaywalled')
);
const { bulkActionsHotKeys } = useBulkActionsHotKeys();
const { conversationHotKeys } = useConversationHotKeys();
const {
  macroHotKeys,
  pendingAttributes,
  submitPendingAttributes,
  dismissPendingAttributes,
} = useMacroHotKeys();

watch(pendingAttributes, pending => {
  if (pending) {
    resolveAttributesModalRef.value?.open(
      pending.missing,
      pending.customAttributes
    );
  }
});

const SNOOZE_PARENT_IDS = [
  'snooze_conversation',
  'snooze_notification',
  'bulk_action_snooze_conversation',
];
const DYNAMIC_SNOOZE_PREFIX = 'dynamic_snooze_';

const CUSTOM_SNOOZE = wootConstants.SNOOZE_OPTIONS.UNTIL_CUSTOM_TIME;

const dynamicSnoozeActions = ref([]);
const currentCommandRoot = ref(null);

const placeholder = computed(() =>
  SNOOZE_PARENT_IDS.includes(currentCommandRoot.value)
    ? t('COMMAND_BAR.SNOOZE_PLACEHOLDER')
    : t('COMMAND_BAR.SEARCH_PLACEHOLDER')
);

const SNOOZE_PRESET_IDS = new Set(Object.values(wootConstants.SNOOZE_OPTIONS));

const hotKeys = computed(() => {
  if (props.isPaywalled) {
    return [...goToAppearanceHotKeys.value, ...goToCommandHotKeys.value];
  }

  const allActions = [
    ...dynamicSnoozeActions.value,
    ...inboxHotKeys.value,
    ...goToCommandHotKeys.value,
    ...goToAppearanceHotKeys.value,
    ...bulkActionsHotKeys.value,
    ...conversationHotKeys.value,
    ...macroHotKeys.value,
  ];
  // When dynamic NLP snooze suggestions exist, hide all preset snooze actions to avoid duplication
  if (!dynamicSnoozeActions.value.length) return allActions;
  return allActions.filter(
    a => !SNOOZE_PRESET_IDS.has(a.id) || !SNOOZE_PARENT_IDS.includes(a.parent)
  );
});

const SNOOZE_EVENT_MAP = {
  snooze_conversation: CMD_SNOOZE_CONVERSATION,
  snooze_notification: CMD_SNOOZE_NOTIFICATION,
  bulk_action_snooze_conversation: CMD_BULK_ACTION_SNOOZE_CONVERSATION,
};

const SNOOZE_SECTION_MAP = {
  snooze_conversation: 'COMMAND_BAR.SECTIONS.SNOOZE_CONVERSATION',
  snooze_notification: 'COMMAND_BAR.SECTIONS.SNOOZE_NOTIFICATION',
  bulk_action_snooze_conversation: 'COMMAND_BAR.SECTIONS.BULK_ACTIONS',
};

const snoozeTranslations = computed(() => {
  const raw = tm('SNOOZE_PARSER');
  if (!raw || typeof raw !== 'object') return {};
  return JSON.parse(JSON.stringify(raw));
});

const buildDynamicSnoozeActions = (search, parentId) => {
  const suggestions = generateSnoozeSuggestions(search, new Date(), {
    translations: snoozeTranslations.value,
    locale: resolvedLocale.value,
  });
  if (!suggestions.length) return [];

  const busEvent = SNOOZE_EVENT_MAP[parentId];
  const section = t(SNOOZE_SECTION_MAP[parentId]);

  return suggestions.map((parsed, index) => ({
    id: `${DYNAMIC_SNOOZE_PREFIX}${index}`,
    title:
      parsed.label !== parsed.formattedDate
        ? `${parsed.label} - ${parsed.formattedDate}`
        : parsed.formattedDate,
    parent: parentId,
    section,
    icon: ICON_SNOOZE_CONVERSATION,
    keywords: search,
    handler: () => {
      emitter.emit(busEvent, parsed.resolve());
      useTrack(SNOOZE_EVENTS.NLP_SNOOZE_APPLIED, { label: parsed.label });
    },
  }));
};

const resetSnoozeState = () => {
  currentCommandRoot.value = null;
  dynamicSnoozeActions.value = [];
};

const openCommandBar = ({ parent = null } = {}) => {
  currentCommandRoot.value = parent;
  dynamicSnoozeActions.value = [];
  palette.value.open({ parent });
};

useEmitter(CMD_OPEN_COMMAND_BAR, openCommandBar);

const onSelected = ({
  title = null,
  section = null,
  id = null,
  children = null,
}) => {
  selectedSnoozeType.value = id === CUSTOM_SNOOZE ? id : null;

  if (Array.isArray(children) && children.length) {
    currentCommandRoot.value = id;
  }

  useTrack(GENERAL_EVENTS.COMMAND_BAR, { section, action: title });
};

const onCommandBarChange = ({ search = '', actions = [] }) => {
  const normalizedSearch = search.trim();

  if (actions.length > 0) {
    const uniqueParents = [
      ...new Set(actions.map(action => action.parent).filter(Boolean)),
    ];
    if (uniqueParents.length === 1) {
      currentCommandRoot.value = uniqueParents[0];
    } else {
      currentCommandRoot.value = null;
    }
  }

  if (
    !normalizedSearch ||
    !SNOOZE_PARENT_IDS.includes(currentCommandRoot.value || '')
  ) {
    dynamicSnoozeActions.value = [];
    return;
  }

  dynamicSnoozeActions.value = buildDynamicSnoozeActions(
    normalizedSearch,
    currentCommandRoot.value
  );
};

const onClosed = () => {
  if (selectedSnoozeType.value !== CUSTOM_SNOOZE) {
    store.dispatch('setContextMenuChatId', null);
  }
  resetSnoozeState();
};
</script>

<template>
  <CommandPalette
    ref="palette"
    :actions="hotKeys"
    :placeholder="placeholder"
    @change="onCommandBarChange"
    @selected="onSelected"
    @closed="onClosed"
  />
  <ConversationResolveAttributesModal
    ref="resolveAttributesModalRef"
    @submit="submitPendingAttributes"
    @close="dismissPendingAttributes"
  />
</template>
