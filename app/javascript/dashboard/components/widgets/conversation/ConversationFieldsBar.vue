<script setup>
import { computed } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import { useMapGetter } from 'dashboard/composables/store';
import { CONVERSATION_PRIORITY } from 'shared/constants/messages';
import {
  DropdownContainer,
  DropdownBody,
  DropdownItem,
} from 'dashboard/components-next/dropdown-menu/base';
import HeaderAssignee from './HeaderAssignee.vue';

const props = defineProps({
  chat: { type: Object, required: true },
});

const STATUS_OPTIONS = ['open', 'pending', 'resolved'];
const STATUS_DOTS = {
  open: 'bg-n-teal-9',
  pending: 'bg-n-amber-9',
  resolved: 'bg-n-slate-9',
  snoozed: 'bg-n-iris-9',
};
const PRIORITY_OPTIONS = [
  null,
  CONVERSATION_PRIORITY.URGENT,
  CONVERSATION_PRIORITY.HIGH,
  CONVERSATION_PRIORITY.MEDIUM,
  CONVERSATION_PRIORITY.LOW,
];

const store = useStore();
const { t } = useI18n();
const teams = useMapGetter('teams/getTeams');
const accountLabels = useMapGetter('labels/getLabels');

const statusLabel = status =>
  t(`CHAT_LIST.CHAT_STATUS_FILTER_ITEMS.${status}.TEXT`);
const priorityLabel = priority =>
  t(`CONVERSATION.PRIORITY.OPTIONS.${(priority || 'none').toUpperCase()}`);

const conversationId = computed(() => props.chat.id);
const team = computed(() => props.chat.meta?.team);
const activeLabels = computed(() =>
  (props.chat.labels || []).map(title => ({
    title,
    color: accountLabels.value.find(label => label.title === title)?.color,
  }))
);

const setStatus = status =>
  store.dispatch('toggleStatus', {
    conversationId: conversationId.value,
    status,
  });

const setTeam = selectedTeam => {
  store.dispatch('assignTeam', {
    conversationId: conversationId.value,
    teamId: selectedTeam ? selectedTeam.id : 0,
  });
};

const setPriority = priority => {
  store.dispatch('setCurrentChatPriority', {
    priority,
    conversationId: conversationId.value,
  });
  store.dispatch('assignPriority', {
    conversationId: conversationId.value,
    priority,
  });
};

const toggleLabel = title => {
  const current = props.chat.labels || [];
  const labels = current.includes(title)
    ? current.filter(label => label !== title)
    : [...current, title];
  store.dispatch('conversationLabels/update', {
    conversationId: conversationId.value,
    labels,
  });
};

const chipClass =
  'inline-flex gap-1.5 items-center px-2.5 h-[1.875rem] text-[0.8125rem] rounded-lg border transition-colors border-n-weak bg-n-slate-2 hover:bg-n-slate-3';
</script>

<template>
  <div
    class="flex flex-wrap gap-2 items-center px-4 py-2 border-b border-n-weak bg-n-slate-1"
  >
    <DropdownContainer>
      <template #trigger="{ toggle }">
        <button type="button" :class="chipClass" @click="toggle">
          <span class="text-n-slate-11">
            {{ t('CONVERSATION_FIELDS_BAR.STATUS') }}
          </span>
          <b class="inline-flex gap-1.5 items-center font-semibold">
            <span
              class="rounded-full size-1.5"
              :class="STATUS_DOTS[chat.status]"
            />
            {{ statusLabel(chat.status) }}
          </b>
          <span class="i-lucide-chevron-down size-3.5 text-n-slate-10" />
        </button>
      </template>
      <DropdownBody class="top-9 z-50 min-w-40 ltr:left-0 rtl:right-0">
        <DropdownItem
          v-for="status in STATUS_OPTIONS"
          :key="status"
          :label="statusLabel(status)"
          :click="() => setStatus(status)"
        />
      </DropdownBody>
    </DropdownContainer>

    <span :class="chipClass" class="!px-0 !pe-1 !ps-2.5">
      <span class="text-n-slate-11">
        {{ t('CONVERSATION_FIELDS_BAR.ASSIGNEE') }}
      </span>
      <HeaderAssignee :chat="chat" />
    </span>

    <DropdownContainer>
      <template #trigger="{ toggle }">
        <button type="button" :class="chipClass" @click="toggle">
          <span class="text-n-slate-11">
            {{ t('CONVERSATION_FIELDS_BAR.TEAM') }}
          </span>
          <b class="font-semibold truncate max-w-28">
            {{ team?.name || t('TEAMS_SETTINGS.LIST.NONE') }}
          </b>
          <span class="i-lucide-chevron-down size-3.5 text-n-slate-10" />
        </button>
      </template>
      <DropdownBody
        class="top-9 z-50 min-w-44 max-h-64 overflow-y-auto ltr:left-0 rtl:right-0"
      >
        <DropdownItem
          :label="t('TEAMS_SETTINGS.LIST.NONE')"
          :click="() => setTeam(null)"
        />
        <DropdownItem
          v-for="option in teams"
          :key="option.id"
          :label="option.name"
          :click="() => setTeam(option)"
        />
      </DropdownBody>
    </DropdownContainer>

    <DropdownContainer>
      <template #trigger="{ toggle }">
        <button type="button" :class="chipClass" @click="toggle">
          <span class="text-n-slate-11">
            {{ t('CONVERSATION_FIELDS_BAR.PRIORITY') }}
          </span>
          <b class="font-semibold">{{ priorityLabel(chat.priority) }}</b>
          <span class="i-lucide-chevron-down size-3.5 text-n-slate-10" />
        </button>
      </template>
      <DropdownBody class="top-9 z-50 min-w-40 ltr:left-0 rtl:right-0">
        <DropdownItem
          v-for="priority in PRIORITY_OPTIONS"
          :key="priority || 'none'"
          :label="priorityLabel(priority)"
          :click="() => setPriority(priority)"
        />
      </DropdownBody>
    </DropdownContainer>

    <span
      v-for="label in activeLabels"
      :key="label.title"
      class="inline-flex gap-1.5 items-center px-2 h-5 text-xs font-medium rounded-full bg-n-blue-3 text-n-blue-11"
    >
      <span
        class="rounded-full size-1.5"
        :style="{ backgroundColor: label.color }"
      />
      {{ label.title }}
    </span>

    <DropdownContainer>
      <template #trigger="{ toggle }">
        <button
          type="button"
          class="inline-flex gap-1 items-center px-2.5 h-6 text-xs font-medium rounded-full border border-dashed transition-colors border-n-strong text-n-slate-11 hover:bg-n-slate-3"
          @click="toggle"
        >
          <span class="i-lucide-plus size-3" />
          {{ t('CONVERSATION_FIELDS_BAR.ADD_LABEL') }}
        </button>
      </template>
      <DropdownBody
        class="top-8 z-50 min-w-44 max-h-64 overflow-y-auto ltr:left-0 rtl:right-0"
      >
        <DropdownItem
          v-for="label in accountLabels"
          :key="label.id"
          :label="label.title"
          :icon="chat.labels?.includes(label.title) ? 'i-lucide-check' : ''"
          preserve-open
          :click="() => toggleLabel(label.title)"
        />
      </DropdownBody>
    </DropdownContainer>
  </div>
</template>
