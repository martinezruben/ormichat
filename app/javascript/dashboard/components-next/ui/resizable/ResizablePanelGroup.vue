<script setup>
import { SplitterGroup } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <SplitterGroup
    v-slot="slotProps"
    v-bind="$attrs"
    :class="
      cn('flex size-full data-[orientation=vertical]:flex-col', $props.class)
    "
  >
    <slot v-bind="slotProps" />
  </SplitterGroup>
</template>
