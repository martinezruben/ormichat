<script setup>
import { ContextMenuPortal, ContextMenuContent } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <ContextMenuPortal>
    <ContextMenuContent
      v-bind="$attrs"
      :class="
        cn(
          'z-[10001] min-w-[8rem] overflow-hidden rounded-lg border border-border bg-popover p-1 text-popover-foreground shadow-md outline-none',
          $props.class
        )
      "
    >
      <slot />
    </ContextMenuContent>
  </ContextMenuPortal>
</template>
