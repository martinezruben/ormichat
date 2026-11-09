<script setup>
import { AlertDialogTitle } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <AlertDialogTitle
    v-slot="slotProps"
    v-bind="$attrs"
    :class="cn('text-base font-semibold', $props.class)"
  >
    <slot v-bind="slotProps" />
  </AlertDialogTitle>
</template>
