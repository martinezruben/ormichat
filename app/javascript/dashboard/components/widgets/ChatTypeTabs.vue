<script setup>
import { computed } from 'vue';
import { useKeyboardEvents } from 'dashboard/composables/useKeyboardEvents';
import wootConstants from 'dashboard/constants/globals';

const props = defineProps({
  items: {
    type: Array,
    default: () => [],
  },
  activeTab: {
    type: String,
    default: wootConstants.ASSIGNEE_TYPE.ME,
  },
});

const emit = defineEmits(['chatTabChange']);

const activeTabIndex = computed(() => {
  return props.items.findIndex(item => item.key === props.activeTab);
});

const onTabChange = selectedTabIndex => {
  if (selectedTabIndex >= 0 && selectedTabIndex < props.items.length) {
    const selectedItem = props.items[selectedTabIndex];
    if (selectedItem.key !== props.activeTab) {
      emit('chatTabChange', selectedItem.key);
    }
  }
};

const keyboardEvents = {
  'Alt+KeyN': {
    action: () => {
      if (props.activeTab === wootConstants.ASSIGNEE_TYPE.ALL) {
        onTabChange(0);
      } else {
        const nextIndex = (activeTabIndex.value + 1) % props.items.length;
        onTabChange(nextIndex);
      }
    },
  },
};

useKeyboardEvents(keyboardEvents);
</script>

<template>
  <div class="px-4 pt-3 pb-2">
    <div
      role="tablist"
      class="flex gap-0.5 p-[0.1875rem] rounded-[0.625rem] bg-n-slate-3"
    >
      <button
        v-for="(item, index) in items"
        :key="item.key"
        type="button"
        role="tab"
        :aria-selected="index === activeTabIndex"
        class="flex flex-1 gap-1 justify-center items-center px-1 h-[1.875rem] min-w-0 text-xs font-medium rounded-[0.4375rem] transition-colors"
        :class="
          index === activeTabIndex
            ? 'bg-n-solid-1 text-n-slate-12 shadow-sm'
            : 'text-n-slate-11 hover:text-n-slate-12'
        "
        @click="onTabChange(index)"
      >
        <span class="truncate">{{ item.name }}</span>
        <span
          class="px-1 min-w-4 text-center rounded-full text-[0.6875rem] tabular-nums bg-n-slate-6 text-n-slate-12/80"
        >
          {{ item.count }}
        </span>
      </button>
    </div>
  </div>
</template>
