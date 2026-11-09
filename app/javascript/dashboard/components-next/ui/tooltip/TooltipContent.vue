<script setup>
import { TooltipPortal, TooltipContent } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <TooltipPortal>
    <TooltipContent
      :side-offset="4"
      v-bind="$attrs"
      :class="
        cn(
          'z-[10001] max-w-xs rounded-md bg-foreground px-3 py-1.5 text-xs text-background',
          $props.class
        )
      "
    >
      <slot />
    </TooltipContent>
  </TooltipPortal>
</template>
