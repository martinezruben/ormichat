<script setup>
import { ComboboxTrigger } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <ComboboxTrigger v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </ComboboxTrigger>
</template>
