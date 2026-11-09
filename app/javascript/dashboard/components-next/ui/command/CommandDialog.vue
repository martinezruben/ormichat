<script setup>
import {
  DialogContent,
  DialogDescription,
  DialogOverlay,
  DialogPortal,
  DialogRoot,
  DialogTitle,
} from 'reka-ui';
import { cn } from '../lib/utils';
import Command from './Command.vue';

defineProps({
  open: { type: Boolean, default: false },
  title: { type: String, required: true },
  description: { type: String, default: '' },
  class: { type: [String, Array, Object], default: '' },
});

defineEmits(['update:open']);

defineOptions({ inheritAttrs: false });
</script>

<template>
  <DialogRoot :open="open" @update:open="$emit('update:open', $event)">
    <DialogPortal>
      <DialogOverlay class="fixed inset-0 z-[9999] bg-[rgba(var(--overlay))]" />
      <DialogContent
        :class="
          cn(
            'fixed start-1/2 top-[12vh] z-[10000] w-[calc(100%-2rem)] max-w-xl -translate-x-1/2 rtl:translate-x-1/2',
            'rounded-xl border border-border shadow-xl outline-none',
            $props.class
          )
        "
      >
        <DialogTitle class="sr-only">{{ title }}</DialogTitle>
        <DialogDescription class="sr-only">
          {{ description || title }}
        </DialogDescription>
        <Command class="max-h-[70vh]" v-bind="$attrs">
          <slot />
        </Command>
      </DialogContent>
    </DialogPortal>
  </DialogRoot>
</template>
