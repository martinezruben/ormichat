<script setup>
import { AvatarRoot } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <AvatarRoot
    v-slot="slotProps"
    v-bind="$attrs"
    :class="
      cn(
        'relative flex size-8 shrink-0 overflow-hidden rounded-full',
        $props.class
      )
    "
  >
    <slot v-bind="slotProps" />
  </AvatarRoot>
</template>
