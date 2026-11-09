<script setup>
import { TabsContent } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <TabsContent
    v-slot="slotProps"
    v-bind="$attrs"
    :class="
      cn(
        'mt-2 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring',
        $props.class
      )
    "
  >
    <slot v-bind="slotProps" />
  </TabsContent>
</template>
