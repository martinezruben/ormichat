<script setup>
import { AvatarImage } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <AvatarImage
    v-slot="slotProps"
    v-bind="$attrs"
    :class="cn('aspect-square size-full object-cover', $props.class)"
  >
    <slot v-bind="slotProps" />
  </AvatarImage>
</template>
