<script setup>
import { DialogRoot } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <DialogRoot v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </DialogRoot>
</template>
