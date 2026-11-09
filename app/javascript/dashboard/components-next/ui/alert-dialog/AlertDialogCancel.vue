<script setup>
import { AlertDialogCancel } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <AlertDialogCancel
    v-slot="slotProps"
    v-bind="$attrs"
    :class="
      cn(
        'inline-flex h-9 items-center justify-center rounded-lg px-4 text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 border border-input bg-background hover:bg-accent',
        $props.class
      )
    "
  >
    <slot v-bind="slotProps" />
  </AlertDialogCancel>
</template>
