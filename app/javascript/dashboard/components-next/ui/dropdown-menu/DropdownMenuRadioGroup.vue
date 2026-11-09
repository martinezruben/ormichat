<script setup>
import { DropdownMenuRadioGroup } from 'reka-ui';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <DropdownMenuRadioGroup v-slot="slotProps" v-bind="$attrs">
    <slot v-bind="slotProps" />
  </DropdownMenuRadioGroup>
</template>
