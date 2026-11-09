<script setup>
import { DropdownMenuPortal, DropdownMenuContent } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <DropdownMenuPortal>
    <DropdownMenuContent
      :side-offset="4"
      v-bind="$attrs"
      :class="
        cn(
          'z-[10001] min-w-[8rem] overflow-hidden rounded-lg border border-border bg-popover p-1 text-popover-foreground shadow-md outline-none',
          $props.class
        )
      "
    >
      <slot />
    </DropdownMenuContent>
  </DropdownMenuPortal>
</template>
