<script setup>
import { SplitterPanel } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <SplitterPanel v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </SplitterPanel>
</template>
