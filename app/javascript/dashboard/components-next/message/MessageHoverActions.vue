<script setup>
import { useI18n } from 'vue-i18n';
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from 'dashboard/components-next/ui/tooltip';

defineProps({
  canReply: { type: Boolean, default: false },
  canCopy: { type: Boolean, default: false },
});

defineEmits(['reply', 'copy', 'more']);

const { t } = useI18n();

const BUTTON_CLASS =
  'flex size-7 items-center justify-center rounded-md text-n-slate-11 outline-none hover:bg-n-alpha-2 hover:text-n-slate-12 focus-visible:ring-2 focus-visible:ring-ring';
</script>

<template>
  <div
    class="absolute -top-3 z-[2] hidden items-center gap-0.5 rounded-lg border border-n-weak bg-n-surface-1 p-0.5 shadow-sm group-hover/msg:flex group-focus-within/msg:flex"
  >
    <Tooltip v-if="canReply">
      <TooltipTrigger as-child>
        <button
          type="button"
          :class="BUTTON_CLASS"
          :aria-label="t('CONVERSATION.CONTEXT_MENU.REPLY_TO')"
          @click="$emit('reply')"
        >
          <span class="i-lucide-reply size-4" />
        </button>
      </TooltipTrigger>
      <TooltipContent>
        {{ t('CONVERSATION.CONTEXT_MENU.REPLY_TO') }}
      </TooltipContent>
    </Tooltip>
    <Tooltip v-if="canCopy">
      <TooltipTrigger as-child>
        <button
          type="button"
          :class="BUTTON_CLASS"
          :aria-label="t('CONVERSATION.CONTEXT_MENU.COPY')"
          @click="$emit('copy')"
        >
          <span class="i-lucide-copy size-4" />
        </button>
      </TooltipTrigger>
      <TooltipContent>{{ t('CONVERSATION.CONTEXT_MENU.COPY') }}</TooltipContent>
    </Tooltip>
    <Tooltip>
      <TooltipTrigger as-child>
        <button
          type="button"
          :class="BUTTON_CLASS"
          :aria-label="t('CONVERSATION.HEADER.MORE_ACTIONS')"
          @click="$emit('more', $event)"
        >
          <span class="i-lucide-more-horizontal size-4" />
        </button>
      </TooltipTrigger>
      <TooltipContent>
        {{ t('CONVERSATION.HEADER.MORE_ACTIONS') }}
      </TooltipContent>
    </Tooltip>
  </div>
</template>
