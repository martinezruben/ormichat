<script setup>
import { TooltipProvider, TooltipRoot } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <TooltipProvider :delay-duration="200">
    <TooltipRoot v-slot="slotProps" v-bind="$attrs">
      <slot v-bind="slotProps" />
    </TooltipRoot>
  </TooltipProvider>
</template>
