<script setup>
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});
</script>

<template>
  <span
    :class="
      cn('ms-auto text-xs tracking-widest text-muted-foreground', $props.class)
    "
  >
    <slot />
  </span>
</template>
