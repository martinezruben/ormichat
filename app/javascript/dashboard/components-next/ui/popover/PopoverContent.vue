<script setup>
import { PopoverPortal, PopoverContent } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <PopoverPortal>
    <PopoverContent
      :side-offset="4"
      align="center"
      v-bind="$attrs"
      :class="
        cn(
          'z-[10001] w-72 rounded-lg border border-border bg-popover p-4 text-popover-foreground shadow-md outline-none',
          $props.class
        )
      "
    >
      <slot />
    </PopoverContent>
  </PopoverPortal>
</template>
