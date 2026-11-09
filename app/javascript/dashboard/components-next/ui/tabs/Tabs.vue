<script setup>
import { TabsRoot } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <TabsRoot v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </TabsRoot>
</template>
