<script setup>
import { ComboboxRoot } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <ComboboxRoot v-slot="slotProps" v-bind="$attrs" ignore-filter>
    <slot v-bind="slotProps" />
  </ComboboxRoot>
</template>
