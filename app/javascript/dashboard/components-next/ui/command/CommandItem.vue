<script setup>
import { ListboxItem } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});
</script>

<template>
  <ListboxItem
    :class="
      cn(
        'relative flex cursor-default select-none items-center gap-2 rounded-lg px-2 py-2 text-sm outline-none',
        'data-[highlighted]:bg-accent data-[highlighted]:text-accent-foreground',
        'data-[disabled]:pointer-events-none data-[disabled]:opacity-50',
        $props.class
      )
    "
  >
    <slot />
  </ListboxItem>
</template>
