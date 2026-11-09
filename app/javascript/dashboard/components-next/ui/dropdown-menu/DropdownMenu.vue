<script setup>
import { DropdownMenuRoot } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <DropdownMenuRoot v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </DropdownMenuRoot>
</template>
