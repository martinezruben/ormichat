<script setup>
import { ToggleGroupRoot } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <ToggleGroupRoot
    v-slot="slotProps"
    v-bind="$attrs"
    :class="cn('flex items-center justify-center gap-1', $props.class)"
  >
    <slot v-bind="slotProps" />
  </ToggleGroupRoot>
</template>
