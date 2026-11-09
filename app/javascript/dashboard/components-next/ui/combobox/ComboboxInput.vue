<script setup>
import { ComboboxInput } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <ComboboxInput
    v-slot="slotProps"
    v-bind="$attrs"
    :class="
      cn(
        'h-9 w-full bg-transparent px-3 text-sm outline-none placeholder:text-muted-foreground',
        $props.class
      )
    "
  >
    <slot v-bind="slotProps" />
  </ComboboxInput>
</template>
