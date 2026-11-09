<script setup>
import { DialogTitle } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <DialogTitle
    v-slot="slotProps"
    v-bind="$attrs"
    :class="cn('text-base font-semibold text-foreground', $props.class)"
  >
    <slot v-bind="slotProps" />
  </DialogTitle>
</template>
