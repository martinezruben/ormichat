<script setup>
defineProps({
  title: {
    type: String,
    required: true,
  },
  icon: {
    type: String,
    default: 'i-lucide-layout-list',
  },
  count: {
    type: [Number, String],
    default: null,
  },
});
</script>

<template>
  <section
    class="flex flex-col min-w-0 border rounded-xl border-n-weak bg-n-surface-1 shadow-sm"
  >
    <header
      class="flex items-center gap-2 px-3 py-2.5 border-b border-n-weak min-w-0"
    >
      <span
        class="flex items-center justify-center rounded-md size-6 shrink-0 bg-n-iris-3 text-n-iris-11"
      >
        <span class="size-3.5" :class="icon" />
      </span>
      <h3 class="flex-1 m-0 text-sm font-semibold truncate text-n-slate-12">
        {{ title }}
      </h3>
      <span
        v-if="count !== null"
        class="px-1.5 text-xs font-medium rounded-full bg-n-alpha-2 text-n-slate-11"
      >
        {{ count }}
      </span>
      <slot name="action" />
    </header>
    <div class="flex flex-col gap-3 p-3 min-w-0">
      <slot />
    </div>
  </section>
</template>
