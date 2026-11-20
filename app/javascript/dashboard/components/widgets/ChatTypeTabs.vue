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
  <div class="px-4 pt-1 pb-2">
    <div role="tablist" class="flex flex-wrap gap-1.5">
      <button
        v-for="(item, index) in items"
        :key="item.key"
        type="button"
        role="tab"
        :aria-selected="index === activeTabIndex"
        class="inline-flex gap-1.5 justify-center items-center px-3 h-7 text-[0.8125rem] font-medium rounded-full border transition-colors"
        :class="
          index === activeTabIndex
            ? 'bg-n-blue-3 border-n-blue-6 text-n-blue-11'
            : 'bg-n-solid-1 border-n-weak text-n-slate-11 hover:text-n-slate-12'
        "
        @click="onTabChange(index)"
      >
        {{ item.name }}
        <span
          class="px-1.5 min-w-4 text-center rounded-full text-[0.6875rem] tabular-nums"
          :class="
            index === activeTabIndex
              ? 'bg-n-blue-5 text-n-blue-11'
              : 'bg-n-slate-3 text-n-slate-12/80'
          "
        >
          {{ item.count }}
        </span>
      </button>
    </div>
  </div>
</template>
