<script setup>
import { DropdownMenuSub } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <DropdownMenuSub v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </DropdownMenuSub>
</template>
