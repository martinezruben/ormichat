<script setup>
import { ref, watch } from 'vue';
import { useCaptain } from 'dashboard/composables/useCaptain';
import NextButton from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  conversationId: {
    type: [Number, String],
    required: true,
  },
});

const { captainTasksEnabled, summarizeConversation } = useCaptain();

const summary = ref('');
const isLoading = ref(false);

const summarize = async () => {
  isLoading.value = true;
  const { message } = await summarizeConversation();
  summary.value = message;
  isLoading.value = false;
};

watch(
  () => props.conversationId,
  () => {
    summary.value = '';
  }
);
</script>

<template>
  <div
    v-if="captainTasksEnabled"
    class="flex flex-col gap-2 p-3 mx-4 mb-3 border rounded-xl border-n-iris-6 bg-n-iris-2"
  >
    <div class="flex items-center gap-2">
      <span class="i-ph-sparkle-fill size-4 text-n-iris-11" />
      <span class="flex-1 text-sm font-medium text-n-iris-11">
        {{ $t('CONVERSATION.AI_SUMMARY.TITLE') }}
      </span>
      <NextButton
        :label="
          summary
            ? $t('CONVERSATION.AI_SUMMARY.REFRESH')
            : $t('CONVERSATION.AI_SUMMARY.GENERATE')
        "
        :is-loading="isLoading"
        slate
        faded
        xs
        @click="summarize"
      />
    </div>
    <p
      v-if="summary"
      class="mb-0 text-sm whitespace-pre-line text-n-slate-12"
      data-clarity-mask="True"
    >
      {{ summary }}
    </p>
    <p v-else class="mb-0 text-xs text-n-slate-11">
      {{ $t('CONVERSATION.AI_SUMMARY.HINT') }}
    </p>
  </div>
</template>
