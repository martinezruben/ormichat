<script setup>
import { DialogDescription } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <DialogDescription
    v-slot="slotProps"
    v-bind="$attrs"
    :class="cn('text-sm text-muted-foreground', $props.class)"
  >
    <slot v-bind="slotProps" />
  </DialogDescription>
</template>
