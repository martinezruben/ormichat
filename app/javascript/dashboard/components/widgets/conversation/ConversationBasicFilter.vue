<script setup>
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useToggle } from '@vueuse/core';
import { vOnClickOutside } from '@vueuse/components';
import { useUISettings } from 'dashboard/composables/useUISettings';
import { useMapGetter, useStore } from 'dashboard/composables/store.js';
import wootConstants from 'dashboard/constants/globals';
import SelectMenu from 'dashboard/components-next/selectmenu/SelectMenu.vue';
import Switch from 'dashboard/components-next/switch/Switch.vue';

defineProps({
  isOnExpandedLayout: {
    type: Boolean,
    required: true,
  },
});

const emit = defineEmits(['changeFilter']);

const store = useStore();
const { t } = useI18n();

const { uiSettings, updateUISettings } = useUISettings();

const isCompactList = computed({
  get: () => !!uiSettings.value.conversation_list_compact,
  set: value => updateUISettings({ conversation_list_compact: value }),
});

const chatStatusFilter = useMapGetter('getChatStatusFilter');
const chatSortFilter = useMapGetter('getChatSortFilter');

const [showActionsDropdown, toggleDropdown] = useToggle();

const currentStatusFilter = computed(() => {
  return chatStatusFilter.value || wootConstants.STATUS_TYPE.OPEN;
});

const currentSortBy = computed(() => {
  return (
    chatSortFilter.value || wootConstants.SORT_BY_TYPE.LAST_ACTIVITY_AT_DESC
  );
});

const chatStatusOptions = computed(() => [
  {
    label: t('CHAT_LIST.CHAT_STATUS_FILTER_ITEMS.open.TEXT'),
    value: 'open',
  },
  {
    label: t('CHAT_LIST.CHAT_STATUS_FILTER_ITEMS.resolved.TEXT'),
    value: 'resolved',
  },
  {
    label: t('CHAT_LIST.CHAT_STATUS_FILTER_ITEMS.pending.TEXT'),
    value: 'pending',
  },
  {
    label: t('CHAT_LIST.CHAT_STATUS_FILTER_ITEMS.snoozed.TEXT'),
    value: 'snoozed',
  },
  {
    label: t('CHAT_LIST.CHAT_STATUS_FILTER_ITEMS.all.TEXT'),
    value: 'all',
  },
]);

const chatSortOptions = computed(() => [
  {
    label: t('CHAT_LIST.SORT_ORDER_ITEMS.last_activity_at_asc.TEXT'),
    value: 'last_activity_at_asc',
  },
  {
    label: t('CHAT_LIST.SORT_ORDER_ITEMS.last_activity_at_desc.TEXT'),
    value: 'last_activity_at_desc',
  },
  {
    label: t('CHAT_LIST.SORT_ORDER_ITEMS.created_at_desc.TEXT'),
    value: 'created_at_desc',
  },
  {
    label: t('CHAT_LIST.SORT_ORDER_ITEMS.created_at_asc.TEXT'),
    value: 'created_at_asc',
  },
  {
    label: t('CHAT_LIST.SORT_ORDER_ITEMS.unread.TEXT'),
    value: 'unread',
  },
  {
    label: t('CHAT_LIST.SORT_ORDER_ITEMS.priority_desc.TEXT'),
    value: 'priority_desc',
  },
  {
    label: t('CHAT_LIST.SORT_ORDER_ITEMS.priority_asc.TEXT'),
    value: 'priority_asc',
  },
  {
    label: t('CHAT_LIST.SORT_ORDER_ITEMS.priority_desc_created_at_asc.TEXT'),
    value: 'priority_desc_created_at_asc',
  },
  {
    label: t('CHAT_LIST.SORT_ORDER_ITEMS.waiting_since_asc.TEXT'),
    value: 'waiting_since_asc',
  },
  {
    label: t('CHAT_LIST.SORT_ORDER_ITEMS.waiting_since_desc.TEXT'),
    value: 'waiting_since_desc',
  },
]);

const activeChatStatusLabel = computed(
  () =>
    chatStatusOptions.value.find(m => m.value === chatStatusFilter.value)
      ?.label || ''
);

const activeChatSortLabel = computed(
  () =>
    chatSortOptions.value.find(m => m.value === chatSortFilter.value)?.label ||
    ''
);

const STATUS_DOTS = {
  open: 'bg-n-teal-9',
  pending: 'bg-n-amber-9',
  resolved: 'bg-n-slate-9',
  snoozed: 'bg-n-iris-9',
};

const chips = computed(() => [
  {
    key: 'status',
    label: t('CHAT_LIST.CHAT_SORT.STATUS'),
    value: activeChatStatusLabel.value,
    dot: STATUS_DOTS[currentStatusFilter.value],
  },
  {
    key: 'order',
    label: t('CHAT_LIST.CHAT_SORT.ORDER_BY'),
    value: activeChatSortLabel.value,
    dot: null,
  },
]);

const saveSelectedFilter = (type, value) => {
  updateUISettings({
    conversations_filter_by: {
      status: type === 'status' ? value : currentStatusFilter.value,
      order_by: type === 'sort' ? value : currentSortBy.value,
    },
  });
};

const handleStatusChange = value => {
  emit('changeFilter', value, 'status');
  store.dispatch('setChatStatusFilter', value);
  saveSelectedFilter('status', value);
};

const handleSortChange = value => {
  emit('changeFilter', value, 'sort');
  store.dispatch('setChatSortFilter', value);
  saveSelectedFilter('sort', value);
};
</script>

<template>
  <div class="relative flex gap-2 px-4 pb-2">
    <button
      v-for="chip in chips"
      :key="chip.key"
      type="button"
      class="inline-flex gap-1.5 items-center px-2.5 h-[1.875rem] text-[0.8125rem] rounded-lg border transition-colors border-n-weak bg-n-slate-2 hover:bg-n-slate-3"
      @click="toggleDropdown()"
    >
      <span class="whitespace-nowrap text-n-slate-11">{{ chip.label }}</span>
      <span v-if="chip.dot" class="rounded-full size-1.5" :class="chip.dot" />
      <b class="font-semibold truncate max-w-[5.5rem] text-n-slate-12">
        {{ chip.value }}
      </b>
      <span class="i-lucide-chevron-down size-3.5 text-n-slate-10" />
    </button>
    <div
      v-if="showActionsDropdown"
      v-on-click-outside="() => toggleDropdown()"
      class="mt-1 bg-n-solid-1 shadow-lg border border-n-weak w-72 rounded-xl p-4 absolute z-40 top-full"
      :class="{
        'ltr:left-0 rtl:right-0': !isOnExpandedLayout,
        'ltr:right-0 rtl:left-0': isOnExpandedLayout,
      }"
    >
      <div class="flex items-center justify-between last:mt-4 gap-2">
        <span class="text-sm truncate text-n-slate-12">
          {{ $t('CHAT_LIST.CHAT_SORT.STATUS') }}
        </span>
        <SelectMenu
          :model-value="chatStatusFilter"
          :options="chatStatusOptions"
          :label="activeChatStatusLabel"
          :sub-menu-position="isOnExpandedLayout ? 'left' : 'right'"
          @update:model-value="handleStatusChange"
        />
      </div>
      <div class="flex items-center justify-between last:mt-4 gap-2">
        <span class="text-sm truncate text-n-slate-12">
          {{ $t('CHAT_LIST.CHAT_SORT.ORDER_BY') }}
        </span>
        <SelectMenu
          :model-value="chatSortFilter"
          :options="chatSortOptions"
          :label="activeChatSortLabel"
          :sub-menu-position="isOnExpandedLayout ? 'left' : 'right'"
          @update:model-value="handleSortChange"
        />
      </div>
      <label class="flex items-center justify-between mt-4 gap-2">
        <span class="text-sm truncate text-n-slate-12">
          {{ $t('CHAT_LIST.CHAT_SORT.COMPACT_VIEW') }}
        </span>
        <Switch v-model="isCompactList" />
      </label>
    </div>
  </div>
</template>
