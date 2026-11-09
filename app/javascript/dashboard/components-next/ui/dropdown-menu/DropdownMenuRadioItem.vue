<script setup>
import { DropdownMenuRadioItem, DropdownMenuItemIndicator } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <DropdownMenuRadioItem
    v-bind="$attrs"
    :class="
      cn(
        'relative flex cursor-default select-none items-center gap-2 rounded-md px-2 py-1.5 text-sm outline-none data-[highlighted]:bg-accent data-[highlighted]:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50 [&_svg]:size-4 [&_svg]:shrink-0 ps-8',
        $props.class
      )
    "
  >
    <span class="absolute start-2 flex size-3.5 items-center justify-center">
      <DropdownMenuItemIndicator>
        <span class="i-lucide-circle size-2 fill-current" />
      </DropdownMenuItemIndicator>
    </span>
    <slot />
  </DropdownMenuRadioItem>
</template>
