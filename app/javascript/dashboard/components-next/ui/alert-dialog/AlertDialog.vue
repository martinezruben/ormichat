<script setup>
import { AlertDialogRoot } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <AlertDialogRoot v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </AlertDialogRoot>
</template>
