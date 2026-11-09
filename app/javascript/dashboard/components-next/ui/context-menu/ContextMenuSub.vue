<script setup>
import { ContextMenuSub } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <ContextMenuSub v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </ContextMenuSub>
</template>
