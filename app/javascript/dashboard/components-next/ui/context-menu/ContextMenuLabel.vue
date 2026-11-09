<script setup>
import { ContextMenuLabel } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <ContextMenuLabel
    v-slot="slotProps"
    v-bind="$attrs"
    :class="
      cn('px-2 py-1.5 text-xs font-medium text-muted-foreground', $props.class)
    "
  >
    <slot v-bind="slotProps" />
  </ContextMenuLabel>
</template>
