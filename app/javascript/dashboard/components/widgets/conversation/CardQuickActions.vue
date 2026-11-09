<script setup>
import { useI18n } from 'vue-i18n';
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from 'dashboard/components-next/ui/tooltip';

defineProps({
  isResolved: { type: Boolean, default: false },
  isAssignedToMe: { type: Boolean, default: false },
});

defineEmits(['resolve', 'reopen', 'assignToMe']);

const { t } = useI18n();

const BUTTON_CLASS =
  'flex size-7 items-center justify-center rounded-md text-n-slate-11 outline-none hover:bg-n-alpha-2 hover:text-n-slate-12 focus-visible:ring-2 focus-visible:ring-ring';
</script>

<template>
  <div
    class="absolute end-2 top-1 z-[2] hidden items-center gap-0.5 rounded-lg border border-n-weak bg-n-surface-1 p-0.5 shadow-sm group-hover:flex group-focus-within:flex"
    @click.stop
  >
    <Tooltip v-if="!isAssignedToMe">
      <TooltipTrigger as-child>
        <button
          type="button"
          :class="BUTTON_CLASS"
          :aria-label="t('CONVERSATION.ASSIGN_TO_ME')"
          @click="$emit('assignToMe')"
        >
          <span class="i-lucide-user-round-plus size-4" />
        </button>
      </TooltipTrigger>
      <TooltipContent>{{ t('CONVERSATION.ASSIGN_TO_ME') }}</TooltipContent>
    </Tooltip>
    <Tooltip v-if="isResolved">
      <TooltipTrigger as-child>
        <button
          type="button"
          :class="BUTTON_CLASS"
          :aria-label="t('CONVERSATION.HEADER.REOPEN_ACTION')"
          @click="$emit('reopen')"
        >
          <span class="i-lucide-rotate-ccw size-4" />
        </button>
      </TooltipTrigger>
      <TooltipContent>
        {{ t('CONVERSATION.HEADER.REOPEN_ACTION') }}
      </TooltipContent>
    </Tooltip>
    <Tooltip v-else>
      <TooltipTrigger as-child>
        <button
          type="button"
          :class="BUTTON_CLASS"
          :aria-label="t('CONVERSATION.HEADER.RESOLVE_ACTION')"
          @click="$emit('resolve')"
        >
          <span class="i-lucide-check size-4" />
        </button>
      </TooltipTrigger>
      <TooltipContent>
        {{ t('CONVERSATION.HEADER.RESOLVE_ACTION') }}
      </TooltipContent>
    </Tooltip>
  </div>
</template>
