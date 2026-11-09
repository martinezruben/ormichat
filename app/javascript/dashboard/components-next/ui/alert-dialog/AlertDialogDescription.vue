<script setup>
import { AlertDialogDescription } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <AlertDialogDescription
    v-slot="slotProps"
    v-bind="$attrs"
    :class="cn('text-sm text-muted-foreground', $props.class)"
  >
    <slot v-bind="slotProps" />
  </AlertDialogDescription>
</template>
