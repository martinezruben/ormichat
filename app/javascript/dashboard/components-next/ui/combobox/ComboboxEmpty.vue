<script setup>
import { ComboboxEmpty } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <ComboboxEmpty
    v-slot="slotProps"
    v-bind="$attrs"
    :class="cn('py-6 text-center text-sm text-muted-foreground', $props.class)"
  >
    <slot v-bind="slotProps" />
  </ComboboxEmpty>
</template>
