<script setup>
import { SelectRoot } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <SelectRoot v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </SelectRoot>
</template>
