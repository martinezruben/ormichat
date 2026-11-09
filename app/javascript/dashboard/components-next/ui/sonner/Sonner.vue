<script setup>
import { Toaster } from 'vue-sonner';
import 'vue-sonner/style.css';

defineOptions({ inheritAttrs: false });
</script>

<template>
  <Toaster
    position="bottom-right"
    :toast-options="{
      classes: {
        toast:
          'group border border-border bg-popover text-popover-foreground shadow-lg rounded-lg',
        description: 'text-muted-foreground',
        actionButton: 'bg-primary text-primary-foreground',
        cancelButton: 'bg-muted text-muted-foreground',
      },
    }"
    v-bind="$attrs"
  />
</template>
