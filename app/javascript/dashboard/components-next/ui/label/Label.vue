<script setup>
import { Label } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <Label
    v-slot="slotProps"
    v-bind="$attrs"
    :class="
      cn(
        'text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70',
        $props.class
      )
    "
  >
    <slot v-bind="slotProps" />
  </Label>
</template>
