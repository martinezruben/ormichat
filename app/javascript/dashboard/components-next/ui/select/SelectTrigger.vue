<script setup>
import { SelectIcon, SelectTrigger } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <SelectTrigger
    v-bind="$attrs"
    :class="
      cn(
        'flex h-9 w-full items-center justify-between gap-2 whitespace-nowrap rounded-lg border border-input bg-transparent px-3 py-2 text-sm shadow-sm',
        'focus:outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50 data-[placeholder]:text-muted-foreground',
        $props.class
      )
    "
  >
    <slot />
    <SelectIcon as-child>
      <span class="i-lucide-chevrons-up-down size-4 shrink-0 opacity-50" />
    </SelectIcon>
  </SelectTrigger>
</template>
