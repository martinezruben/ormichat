<script setup>
defineProps({
  title: {
    type: String,
    required: true,
  },
});
</script>

<template>
  <section class="flex flex-col gap-2.5">
    <h3
      class="m-0 text-xs font-semibold tracking-wider uppercase text-n-slate-11"
    >
      {{ title }}
    </h3>
    <slot />
  </section>
</template>
