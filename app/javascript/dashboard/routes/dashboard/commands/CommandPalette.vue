<script setup>
import { computed, ref, watch, nextTick } from 'vue';
import { useEventListener } from '@vueuse/core';
import { useI18n } from 'vue-i18n';
import CommandDialog from 'dashboard/components-next/ui/command/CommandDialog.vue';
import CommandInput from 'dashboard/components-next/ui/command/CommandInput.vue';
import CommandList from 'dashboard/components-next/ui/command/CommandList.vue';
import CommandGroup from 'dashboard/components-next/ui/command/CommandGroup.vue';
import CommandItem from 'dashboard/components-next/ui/command/CommandItem.vue';
import CommandEmpty from 'dashboard/components-next/ui/command/CommandEmpty.vue';

const props = defineProps({
  actions: { type: Array, default: () => [] },
  placeholder: { type: String, default: '' },
});

const emit = defineEmits(['change', 'selected', 'closed']);

const KEY_HINTS = { navigate: '↑↓', select: '↵', back: '⌫', close: 'Esc' };

const { t } = useI18n();

const isOpen = ref(false);
const search = ref('');
const currentRoot = ref(null);

const matchesSearch = (action, query) =>
  action.title?.toLowerCase().includes(query) ||
  action.keywords?.toLowerCase().includes(query);

// At the root a search looks through every command, inside a submenu only
// through that submenu's own commands.
const matches = computed(() => {
  const query = search.value.trim().toLowerCase();
  return props.actions.filter(action => {
    if (query && !matchesSearch(action, query)) return false;
    if (!currentRoot.value && query) return true;
    return (action.parent || null) === currentRoot.value;
  });
});

const groups = computed(() => {
  const sections = new Map();
  matches.value.forEach(action => {
    const key = action.section || '';
    sections.set(key, [...(sections.get(key) || []), action]);
  });
  return [...sections].map(([heading, actions]) => ({ heading, actions }));
});

const rootAction = computed(() =>
  props.actions.find(action => action.id === currentRoot.value)
);

const open = ({ parent = null } = {}) => {
  search.value = '';
  currentRoot.value = parent;
  isOpen.value = true;
};

const close = () => {
  isOpen.value = false;
};

const onOpenChange = value => {
  if (value) {
    isOpen.value = true;
    return;
  }
  search.value = '';
  currentRoot.value = null;
  isOpen.value = false;
  emit('closed');
};

const goBack = () => {
  currentRoot.value = rootAction.value?.parent || null;
  search.value = '';
};

const onBackspace = event => {
  if (search.value || !currentRoot.value) return;
  event.preventDefault();
  goBack();
};

const onSelect = action => {
  emit('selected', action);

  if (action.children?.length) {
    currentRoot.value = action.id;
    search.value = '';
  }

  if (action.handler) {
    const result = action.handler(action);
    if (!result?.keepOpen) onOpenChange(false);
  }
};

watch(search, async () => {
  await nextTick();
  emit('change', { search: search.value, actions: matches.value });
});

useEventListener(document, 'keydown', event => {
  if (!(event.metaKey || event.ctrlKey) || event.key.toLowerCase() !== 'k') {
    return;
  }
  // The reply box handles this shortcut itself while the editor has focus.
  if (event.defaultPrevented) return;
  event.preventDefault();
  if (isOpen.value) onOpenChange(false);
  else open();
});

defineExpose({ open, close });
</script>

<template>
  <CommandDialog
    :open="isOpen"
    :title="t('COMMAND_BAR.TITLE')"
    @update:open="onOpenChange"
  >
    <CommandInput
      v-model="search"
      :placeholder="placeholder"
      @keydown.backspace="onBackspace"
    >
      <button
        v-if="rootAction"
        type="button"
        class="flex shrink-0 items-center gap-1 rounded-md bg-secondary px-2 py-1 text-xs font-medium text-secondary-foreground hover:bg-accent"
        :title="t('COMMAND_BAR.FOOTER.BACK')"
        @click="goBack"
      >
        <span class="i-lucide-arrow-left size-3" />
        {{ rootAction.title }}
      </button>
    </CommandInput>
    <CommandList>
      <CommandEmpty v-if="!matches.length">
        {{ t('COMMAND_BAR.NO_RESULTS') }}
      </CommandEmpty>
      <CommandGroup
        v-for="group in groups"
        :key="group.heading"
        :heading="group.heading"
      >
        <CommandItem
          v-for="action in group.actions"
          :key="action.id"
          :value="action.id"
          @select="onSelect(action)"
        >
          <span
            v-if="action.icon"
            v-dompurify-html="action.icon"
            class="flex shrink-0 text-muted-foreground"
          />
          <span class="truncate">{{ action.title }}</span>
          <span
            v-if="action.children?.length"
            class="i-lucide-chevron-right ms-auto size-4 text-muted-foreground rtl:rotate-180"
          />
        </CommandItem>
      </CommandGroup>
    </CommandList>
    <div
      class="flex items-center gap-4 border-t border-border bg-muted px-4 py-2 text-xs text-muted-foreground"
    >
      <span>
        {{ KEY_HINTS.navigate }} {{ t('COMMAND_BAR.FOOTER.NAVIGATE') }}
      </span>
      <span>{{ KEY_HINTS.select }} {{ t('COMMAND_BAR.FOOTER.SELECT') }}</span>
      <span v-if="rootAction">
        {{ KEY_HINTS.back }} {{ t('COMMAND_BAR.FOOTER.BACK') }}
      </span>
      <span class="ms-auto">
        {{ KEY_HINTS.close }} {{ t('COMMAND_BAR.FOOTER.CLOSE') }}
      </span>
    </div>
  </CommandDialog>
</template>
