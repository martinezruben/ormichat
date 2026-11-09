<script setup>
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });

const model = defineModel({ type: [String, Number], default: '' });
</script>

<template>
  <textarea
    v-bind="$attrs"
    v-model="model"
    :class="
      cn(
        'min-h-16 py-2 flex w-full rounded-lg border border-input bg-transparent px-3 py-1 text-sm text-foreground shadow-sm transition-colors placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50',
        $props.class
      )
    "
  />
</template>
