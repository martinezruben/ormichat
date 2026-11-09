<script setup>
import { Separator } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <Separator
    v-slot="slotProps"
    v-bind="$attrs"
    :class="
      cn(
        'shrink-0 bg-border data-[orientation=horizontal]:h-px data-[orientation=horizontal]:w-full data-[orientation=vertical]:h-full data-[orientation=vertical]:w-px',
        $props.class
      )
    "
  >
    <slot v-bind="slotProps" />
  </Separator>
</template>
