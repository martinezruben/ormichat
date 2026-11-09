<script setup>
import { SelectSeparator } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <SelectSeparator
    v-slot="slotProps"
    v-bind="$attrs"
    :class="cn('-mx-1 my-1 h-px bg-border', $props.class)"
  >
    <slot v-bind="slotProps" />
  </SelectSeparator>
</template>
