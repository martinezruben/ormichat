<script setup>
import { TooltipProvider } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <TooltipProvider v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </TooltipProvider>
</template>
