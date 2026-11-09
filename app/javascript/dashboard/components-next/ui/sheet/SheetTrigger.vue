<script setup>
import { DialogTrigger } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <DialogTrigger v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </DialogTrigger>
</template>
