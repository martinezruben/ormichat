<script setup>
import { SelectItem, SelectItemIndicator, SelectItemText } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <SelectItem
    v-bind="$attrs"
    :class="
      cn(
        'relative flex cursor-default select-none items-center gap-2 rounded-md px-2 py-1.5 text-sm outline-none data-[highlighted]:bg-accent data-[highlighted]:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50 [&_svg]:size-4 [&_svg]:shrink-0 pe-8',
        $props.class
      )
    "
  >
    <span class="absolute end-2 flex size-3.5 items-center justify-center">
      <SelectItemIndicator>
        <span class="i-lucide-check size-4" />
      </SelectItemIndicator>
    </span>
    <SelectItemText>
      <slot />
    </SelectItemText>
  </SelectItem>
</template>
