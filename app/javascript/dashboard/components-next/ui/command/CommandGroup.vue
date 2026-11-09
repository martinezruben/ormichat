<script setup>
import { ListboxGroup, ListboxGroupLabel } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  heading: { type: String, default: '' },
  class: { type: [String, Array, Object], default: '' },
});
</script>

<template>
  <ListboxGroup :class="cn('overflow-hidden text-foreground', $props.class)">
    <ListboxGroupLabel
      v-if="heading"
      class="px-2 py-1.5 text-xs font-medium text-muted-foreground"
    >
      {{ heading }}
    </ListboxGroupLabel>
    <slot />
  </ListboxGroup>
</template>
