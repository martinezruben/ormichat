<script setup>
import { ContextMenuRadioGroup } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <ContextMenuRadioGroup v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </ContextMenuRadioGroup>
</template>
