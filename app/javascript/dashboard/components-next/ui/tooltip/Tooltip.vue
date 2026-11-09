<script setup>
import { TooltipRoot } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <TooltipRoot v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </TooltipRoot>
</template>
