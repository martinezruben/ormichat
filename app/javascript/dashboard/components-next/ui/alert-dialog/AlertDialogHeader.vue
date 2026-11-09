<script setup>
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});
</script>

<template>
  <div :class="cn('flex flex-col gap-2 text-start', $props.class)">
    <slot />
  </div>
</template>
