<script setup>
import { ComboboxContent, ComboboxPortal, ComboboxViewport } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <ComboboxPortal>
    <ComboboxContent
      position="popper"
      :side-offset="4"
      v-bind="$attrs"
      :class="
        cn(
          'z-[10001] min-w-[8rem] overflow-hidden rounded-lg border border-border bg-popover p-1 text-popover-foreground shadow-md outline-none max-h-72 w-[var(--reka-combobox-trigger-width)]',
          $props.class
        )
      "
    >
      <ComboboxViewport>
        <slot />
      </ComboboxViewport>
    </ComboboxContent>
  </ComboboxPortal>
</template>
