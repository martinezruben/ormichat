<script setup>
import { TabsList } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <TabsList
    v-slot="slotProps"
    v-bind="$attrs"
    :class="
      cn(
        'inline-flex h-9 items-center justify-center rounded-lg bg-muted p-1 text-muted-foreground',
        $props.class
      )
    "
  >
    <slot v-bind="slotProps" />
  </TabsList>
</template>
