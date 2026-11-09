<script setup>
import { DropdownMenuSubTrigger } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <DropdownMenuSubTrigger
    v-bind="$attrs"
    :class="
      cn(
        'relative flex cursor-default select-none items-center gap-2 rounded-md px-2 py-1.5 text-sm outline-none data-[highlighted]:bg-accent data-[highlighted]:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50 [&_svg]:size-4 [&_svg]:shrink-0 data-[state=open]:bg-accent',
        $props.class
      )
    "
  >
    <slot />
    <span class="i-lucide-chevron-right ms-auto size-4 rtl:rotate-180" />
  </DropdownMenuSubTrigger>
</template>
