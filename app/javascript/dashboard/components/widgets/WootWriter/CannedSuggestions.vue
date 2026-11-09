<script setup>
import { computed, onMounted } from 'vue';
import { useStore } from 'vuex';
import { useMapGetter } from 'dashboard/composables/store';

const emit = defineEmits(['select']);

const MAX_SUGGESTIONS = 3;

const store = useStore();
const cannedResponses = useMapGetter('getCannedResponses');

const suggestions = computed(() =>
  cannedResponses.value.slice(0, MAX_SUGGESTIONS)
);

onMounted(() => {
  if (!cannedResponses.value.length) store.dispatch('getCannedResponse');
});
</script>

<template>
  <div
    v-if="suggestions.length"
    class="flex items-center gap-2 px-3 pb-1 overflow-x-auto"
  >
    <span
      class="flex items-center gap-1 text-xs font-semibold shrink-0 text-n-blue-11"
    >
      <span class="i-lucide-sparkles size-3.5" />
      {{ $t('CONVERSATION.REPLYBOX.SUGGESTED_REPLIES') }}
    </span>
    <button
      v-for="canned in suggestions"
      :key="canned.id"
      type="button"
      class="px-3 py-1 text-xs truncate border rounded-full max-w-48 shrink-0 border-n-weak bg-n-alpha-1 text-n-slate-11 hover:border-n-brand hover:text-n-blue-11"
      :title="canned.content"
      @click="emit('select', canned.content)"
    >
      {{ canned.short_code }}
    </button>
  </div>
</template>
