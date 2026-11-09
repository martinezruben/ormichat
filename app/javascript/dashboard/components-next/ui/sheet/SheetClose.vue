<script setup>
import { DialogClose } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <DialogClose v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </DialogClose>
</template>
