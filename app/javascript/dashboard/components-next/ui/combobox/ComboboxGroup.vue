<script setup>
import { ComboboxGroup } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <ComboboxGroup v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </ComboboxGroup>
</template>
