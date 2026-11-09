<script setup>
import { ListboxContent } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});
</script>

<template>
  <ListboxContent
    :class="
      cn('max-h-[22rem] overflow-y-auto overflow-x-hidden p-2', $props.class)
    "
  >
    <slot />
  </ListboxContent>
</template>
