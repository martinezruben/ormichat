<script setup>
import { SplitterResizeHandle } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <SplitterResizeHandle
    v-bind="$attrs"
    :class="
      cn(
        'relative flex w-px shrink-0 items-center justify-center bg-border transition-colors',
        'after:absolute after:inset-y-0 after:start-1/2 after:w-2 after:-translate-x-1/2 rtl:after:translate-x-1/2',
        'hover:bg-ring data-[state=drag]:bg-ring',
        'data-[orientation=vertical]:h-px data-[orientation=vertical]:w-full',
        'data-[orientation=vertical]:after:inset-x-0 data-[orientation=vertical]:after:inset-y-auto data-[orientation=vertical]:after:start-0 data-[orientation=vertical]:after:top-1/2 data-[orientation=vertical]:after:h-2 data-[orientation=vertical]:after:w-full data-[orientation=vertical]:after:-translate-y-1/2 data-[orientation=vertical]:after:translate-x-0',
        $props.class
      )
    "
  />
</template>
