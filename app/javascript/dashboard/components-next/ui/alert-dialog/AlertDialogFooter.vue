<script setup>
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});
</script>

<template>
  <div
    :class="
      cn('flex flex-col-reverse gap-2 sm:flex-row sm:justify-end', $props.class)
    "
  >
    <slot />
  </div>
</template>
