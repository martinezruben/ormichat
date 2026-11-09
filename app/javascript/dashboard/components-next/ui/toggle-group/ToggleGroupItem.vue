<script setup>
import { ToggleGroupItem } from 'reka-ui';
import { cn } from '../lib/utils';
import { toggleVariants } from '../toggle/variants';

defineProps({
  variant: { type: String, default: 'default' },
  size: { type: String, default: 'default' },
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <ToggleGroupItem
    v-slot="slotProps"
    v-bind="$attrs"
    :class="cn(toggleVariants({ variant, size }), $props.class)"
  >
    <slot v-bind="slotProps" />
  </ToggleGroupItem>
</template>
