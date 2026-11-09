<script setup>
import { ListboxFilter } from 'reka-ui';
import { cn } from '../lib/utils';

defineProps({
  class: { type: [String, Array, Object], default: '' },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <div class="flex h-12 items-center gap-2 border-b border-border px-4">
    <span class="i-lucide-search size-4 shrink-0 text-muted-foreground" />
    <ListboxFilter
      v-bind="$attrs"
      auto-focus
      :class="
        cn(
          'h-full w-full bg-transparent text-base text-foreground outline-none placeholder:text-muted-foreground',
          $props.class
        )
      "
    />
    <slot />
  </div>
</template>
