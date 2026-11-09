<script setup>
import { HoverCardTrigger } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <HoverCardTrigger v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </HoverCardTrigger>
</template>
