<script setup>
import { DropdownMenuGroup } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <DropdownMenuGroup v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </DropdownMenuGroup>
</template>
