<script setup>
import { SelectContent, SelectPortal, SelectViewport } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <SelectPortal>
    <SelectContent
      position="popper"
      :side-offset="4"
      v-bind="$attrs"
      :class="
        cn(
          'z-[10001] min-w-[8rem] overflow-hidden rounded-lg border border-border bg-popover p-1 text-popover-foreground shadow-md outline-none max-h-72 min-w-[var(--reka-select-trigger-width)]',
          $props.class
        )
      "
    >
      <SelectViewport>
        <slot />
      </SelectViewport>
    </SelectContent>
  </SelectPortal>
</template>
