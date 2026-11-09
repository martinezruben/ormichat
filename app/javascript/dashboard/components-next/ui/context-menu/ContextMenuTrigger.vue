<script setup>
import { ContextMenuTrigger } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <ContextMenuTrigger v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </ContextMenuTrigger>
</template>
