<script setup>
import { SelectGroup } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <SelectGroup v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </SelectGroup>
</template>
