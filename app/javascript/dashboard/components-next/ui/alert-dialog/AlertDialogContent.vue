<script setup>
import {
  AlertDialogContent,
  AlertDialogOverlay,
  AlertDialogPortal,
} from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <AlertDialogPortal>
    <AlertDialogOverlay
      class="fixed inset-0 z-[9999] bg-[rgba(var(--overlay))]"
    />
    <AlertDialogContent
      v-bind="$attrs"
      :class="
        cn(
          'fixed start-1/2 top-1/2 z-[10000] grid w-[calc(100%-2rem)] max-w-lg -translate-x-1/2 -translate-y-1/2 gap-4 rounded-xl border border-border bg-background p-6 text-foreground shadow-lg outline-none rtl:translate-x-1/2',
          $props.class
        )
      "
    >
      <slot />
    </AlertDialogContent>
  </AlertDialogPortal>
</template>
