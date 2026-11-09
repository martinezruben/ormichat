<script setup>
import { HoverCardRoot } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <HoverCardRoot v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </HoverCardRoot>
</template>
