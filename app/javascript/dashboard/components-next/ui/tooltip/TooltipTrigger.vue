<script setup>
import { TooltipTrigger } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <TooltipTrigger v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </TooltipTrigger>
</template>
