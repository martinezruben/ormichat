<script setup>
import { AlertDialogTrigger } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <AlertDialogTrigger v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </AlertDialogTrigger>
</template>
