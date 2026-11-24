<script setup>
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useMapGetter } from 'dashboard/composables/store';
import { messageStamp } from 'shared/helpers/timeHelper';

const props = defineProps({
  contact: {
    type: Object,
    required: true,
  },
});

const { t } = useI18n();
const chat = useMapGetter('getSelectedChat');

const items = computed(() => [
  {
    key: 'since',
    label: t('CONVERSATION_SIDEBAR.PROFILE.SINCE'),
    value: props.contact.created_at
      ? messageStamp(props.contact.created_at, 'MMM yyyy')
      : '—',
  },
  {
    key: 'channel',
    label: t('CONVERSATION_SIDEBAR.PROFILE.CHANNEL'),
    value: chat.value.meta?.channel?.replace('Channel::', '') || '—',
  },
  {
    key: 'seen',
    label: t('CONVERSATION_SIDEBAR.PROFILE.LAST_SEEN'),
    value: props.contact.last_activity_at
      ? messageStamp(props.contact.last_activity_at, 'LLL d, h:mm a')
      : '—',
  },
]);
</script>

<template>
  <div class="grid grid-cols-2 gap-2">
    <div
      v-for="item in items"
      :key="item.key"
      class="flex flex-col min-w-0 px-2.5 py-2 border rounded-lg border-n-weak bg-n-slate-2"
    >
      <span class="text-xs text-n-slate-10 truncate">{{ item.label }}</span>
      <span class="text-sm font-semibold text-n-slate-12 truncate">
        {{ item.value }}
      </span>
    </div>
  </div>
</template>
