<script setup>
import { ListboxRoot } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});
</script>

<template>
  <ListboxRoot
    highlight-on-hover
    :class="
      cn(
        'flex size-full flex-col overflow-hidden rounded-xl bg-popover text-popover-foreground',
        $props.class
      )
    "
  >
    <slot />
  </ListboxRoot>
</template>
