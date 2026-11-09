<script setup>
import { SelectValue } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <SelectValue v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </SelectValue>
</template>
