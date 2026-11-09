<script setup>
import { Toggle } from 'reka-ui';
import { cn } from '../lib/utils';
import { toggleVariants } from './variants';

defineProps({
  variant: { type: String, default: 'default' },
  size: { type: String, default: 'default' },
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <Toggle
    v-slot="slotProps"
    v-bind="$attrs"
    :class="cn(toggleVariants({ variant, size }), $props.class)"
  >
    <slot v-bind="slotProps" />
  </Toggle>
</template>
