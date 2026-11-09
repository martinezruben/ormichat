<script setup>
import {
  DialogClose,
  DialogContent,
  DialogOverlay,
  DialogPortal,
} from 'reka-ui';
import { cn } from '../lib/utils';
import { sheetVariants } from './variants';

defineProps({
  side: { type: String, default: 'end' },
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <DialogPortal>
    <DialogOverlay class="fixed inset-0 z-[9999] bg-[rgba(var(--overlay))]" />
    <DialogContent
      v-bind="$attrs"
      :class="cn(sheetVariants({ side }), $props.class)"
    >
      <slot />
      <DialogClose
        class="absolute end-4 top-4 rounded-sm opacity-70 transition-opacity hover:opacity-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
      >
        <span class="i-lucide-x size-4" />
      </DialogClose>
    </DialogContent>
  </DialogPortal>
</template>
