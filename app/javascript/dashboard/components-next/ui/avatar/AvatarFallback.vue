<script setup>
import { AvatarFallback } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <AvatarFallback
    v-slot="slotProps"
    v-bind="$attrs"
    :class="
      cn(
        'flex size-full items-center justify-center rounded-full bg-muted text-xs font-medium text-muted-foreground',
        $props.class
      )
    "
  >
    <slot v-bind="slotProps" />
  </AvatarFallback>
</template>
