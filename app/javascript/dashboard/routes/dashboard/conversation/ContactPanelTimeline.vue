<script setup>
import { computed } from 'vue';
import { useMapGetter } from 'dashboard/composables/store';
import { messageStamp } from 'shared/helpers/timeHelper';
import { MESSAGE_TYPE } from 'shared/constants/messages';

const MAX_EVENTS = 8;

const chat = useMapGetter('getSelectedChat');

const events = computed(() =>
  (chat.value.messages || [])
    .filter(message => message.message_type === MESSAGE_TYPE.ACTIVITY)
    .slice(-MAX_EVENTS)
    .reverse()
);
</script>

<template>
  <ol v-if="events.length" class="m-0 p-0 list-none">
    <li v-for="event in events" :key="event.id" class="flex gap-2.5">
      <span class="flex flex-col items-center">
        <span class="mt-1.5 rounded-full size-2 bg-n-brand" />
        <span class="flex-1 w-px mt-1 bg-n-weak" />
      </span>
      <span class="flex flex-col min-w-0 pb-2.5">
        <span class="text-sm break-words text-n-slate-12">
          {{ event.content }}
        </span>
        <span class="text-xs text-n-slate-10">
          {{ messageStamp(event.created_at, 'LLL d, h:mm a') }}
        </span>
      </span>
    </li>
  </ol>
  <p v-else class="m-0 text-sm text-n-slate-11">
    {{ $t('CONVERSATION_SIDEBAR.NO_ACTIVITY') }}
  </p>
</template>
