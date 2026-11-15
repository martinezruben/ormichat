<script setup>
import { computed, nextTick, ref, watch } from 'vue';
import { useEmitter } from 'dashboard/composables/emitter';
import { BUS_EVENTS } from 'shared/constants/busEvents';
import { useKeyboardEvents } from 'dashboard/composables/useKeyboardEvents';
import NextButton from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  messages: {
    type: Array,
    default: () => [],
  },
});

const HIGHLIGHT_CLASSES = ['ring-2', 'ring-n-brand', 'rounded-xl'];
const HIGHLIGHT_DURATION_MS = 1500;

const isOpen = ref(false);
const query = ref('');
const currentIndex = ref(0);
const inputRef = ref(null);

const matches = computed(() => {
  const term = query.value.trim().toLowerCase();
  if (!term) return [];
  return props.messages
    .filter(message => message.content?.toLowerCase().includes(term))
    .map(message => message.id)
    .reverse();
});

const focusMatch = () => {
  const id = matches.value[currentIndex.value];
  const element = document.getElementById(`message${id}`);
  if (!element) return;
  element.scrollIntoView({ block: 'center' });
  element.classList.add(...HIGHLIGHT_CLASSES);
  setTimeout(
    () => element.classList.remove(...HIGHLIGHT_CLASSES),
    HIGHLIGHT_DURATION_MS
  );
};

const move = step => {
  const total = matches.value.length;
  if (!total) return;
  currentIndex.value = (currentIndex.value + step + total) % total;
  focusMatch();
};

const open = async () => {
  isOpen.value = true;
  await nextTick();
  inputRef.value?.focus();
};

const close = () => {
  isOpen.value = false;
  query.value = '';
};

watch(query, () => {
  currentIndex.value = 0;
  if (matches.value.length) focusMatch();
});

useEmitter(BUS_EVENTS.OPEN_CONVERSATION_SEARCH, open);

useKeyboardEvents({
  '$mod+KeyF': {
    action: event => {
      event.preventDefault();
      open();
    },
    allowOnFocusedInput: true,
  },
});
</script>

<template>
  <div
    v-if="isOpen"
    class="flex items-center gap-2 px-4 py-1.5 border-b border-n-weak bg-n-solid-1"
  >
    <span class="i-lucide-search size-4 text-n-slate-10" />
    <input
      ref="inputRef"
      v-model="query"
      class="flex-1 min-w-0 h-7 text-sm bg-transparent border-0 outline-none reset-base text-n-slate-12"
      :placeholder="$t('CONVERSATION.SEARCH_IN_CONVERSATION.PLACEHOLDER')"
      :aria-label="$t('CONVERSATION.SEARCH_IN_CONVERSATION.PLACEHOLDER')"
      @keydown.enter.exact.prevent="move(1)"
      @keydown.shift.enter.prevent="move(-1)"
      @keydown.esc.prevent="close"
    />
    <span v-if="query" class="text-xs tabular-nums text-n-slate-11">
      {{
        $t('CONVERSATION.SEARCH_IN_CONVERSATION.COUNT', {
          current: matches.length ? currentIndex + 1 : 0,
          total: matches.length,
        })
      }}
    </span>
    <NextButton
      icon="i-lucide-chevron-up"
      slate
      ghost
      xs
      :disabled="!matches.length"
      @click="move(1)"
    />
    <NextButton
      icon="i-lucide-chevron-down"
      slate
      ghost
      xs
      :disabled="!matches.length"
      @click="move(-1)"
    />
    <NextButton icon="i-lucide-x" slate ghost xs @click="close" />
  </div>
</template>
