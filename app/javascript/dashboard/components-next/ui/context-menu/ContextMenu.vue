<script setup>
import { ContextMenuRoot } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <ContextMenuRoot v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </ContextMenuRoot>
</template>
