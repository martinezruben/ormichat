<script setup>
import { DropdownMenuSeparator } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <DropdownMenuSeparator
    v-slot="slotProps"
    v-bind="$attrs"
    :class="cn('-mx-1 my-1 h-px bg-border', $props.class)"
  >
    <slot v-bind="slotProps" />
  </DropdownMenuSeparator>
</template>
