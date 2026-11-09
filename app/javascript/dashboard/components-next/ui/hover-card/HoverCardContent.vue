<script setup>
import { HoverCardPortal, HoverCardContent } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <HoverCardPortal>
    <HoverCardContent
      :side-offset="4"
      align="center"
      v-bind="$attrs"
      :class="
        cn(
          'z-[10001] w-64 rounded-lg border border-border bg-popover p-4 text-popover-foreground shadow-md outline-none',
          $props.class
        )
      "
    >
      <slot />
    </HoverCardContent>
  </HoverCardPortal>
</template>
