<script setup>
import { PopoverRoot } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <PopoverRoot v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </PopoverRoot>
</template>
