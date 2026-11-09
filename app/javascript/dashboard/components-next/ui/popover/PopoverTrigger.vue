<script setup>
import { PopoverTrigger } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <PopoverTrigger v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </PopoverTrigger>
</template>
