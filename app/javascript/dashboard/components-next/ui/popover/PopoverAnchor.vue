<script setup>
import { PopoverAnchor } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <PopoverAnchor v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </PopoverAnchor>
</template>
