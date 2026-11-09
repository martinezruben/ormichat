<script setup>
import { AlertDialogAction } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <AlertDialogAction
    v-slot="slotProps"
    v-bind="$attrs"
    :class="
      cn(
        'inline-flex h-9 items-center justify-center rounded-lg px-4 text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 bg-primary text-primary-foreground hover:bg-primary/90',
        $props.class
      )
    "
  >
    <slot v-bind="slotProps" />
  </AlertDialogAction>
</template>
