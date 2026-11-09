<script setup>
import { DropdownMenuTrigger } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <DropdownMenuTrigger v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </DropdownMenuTrigger>
</template>
