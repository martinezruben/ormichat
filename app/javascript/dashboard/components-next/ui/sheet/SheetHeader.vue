<script setup>
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});
</script>

<template>
  <div :class="cn('flex flex-col gap-1.5', $props.class)">
    <slot />
  </div>
</template>
