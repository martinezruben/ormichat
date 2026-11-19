<script setup>
defineProps({
  item: {
    type: Object,
    required: true,
  },
});
</script>

<template>
  <tr class="transition-colors hover:bg-n-slate-2">
    <slot :item="item" />
  </tr>
</template>
