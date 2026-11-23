<script setup>
import { computed } from 'vue';
import { useMapGetter } from 'dashboard/composables/store';
import {
  dynamicTime,
  shortTimestamp,
  formatDuration,
} from 'shared/helpers/timeHelper';

const chat = useMapGetter('getSelectedChat');

const startedAgo = computed(() =>
  shortTimestamp(dynamicTime(chat.value.created_at))
);
const lastActivityAgo = computed(() =>
  shortTimestamp(dynamicTime(chat.value.timestamp))
);
const firstResponse = computed(() => {
  const { first_reply_created_at: firstReplyAt, created_at: createdAt } =
    chat.value;
  if (!firstReplyAt) return '—';
  return formatDuration(Math.max(firstReplyAt - createdAt, 0)) || '—';
});

const stats = computed(() => [
  { key: 'started', label: 'STARTED', value: startedAgo.value },
  { key: 'first', label: 'FIRST_RESPONSE', value: firstResponse.value },
  { key: 'last', label: 'LAST_ACTIVITY', value: lastActivityAgo.value },
]);
</script>

<template>
  <div class="grid grid-cols-3 gap-2">
    <div
      v-for="stat in stats"
      :key="stat.key"
      class="flex flex-col gap-0.5 min-w-0 px-2.5 py-2 border rounded-xl border-n-weak bg-n-slate-2"
    >
      <span
        class="text-base font-semibold tabular-nums text-n-slate-12 truncate"
      >
        {{ stat.value }}
      </span>
      <span class="text-xs text-n-slate-10 truncate">
        {{ $t(`CONVERSATION_SIDEBAR.STATS.${stat.label}`) }}
      </span>
    </div>
  </div>
</template>
