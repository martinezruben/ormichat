<script setup>
import { ContextMenuGroup } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <ContextMenuGroup v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </ContextMenuGroup>
</template>
