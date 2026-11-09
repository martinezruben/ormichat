<script setup>
import { ComboboxAnchor } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <ComboboxAnchor v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </ComboboxAnchor>
</template>
