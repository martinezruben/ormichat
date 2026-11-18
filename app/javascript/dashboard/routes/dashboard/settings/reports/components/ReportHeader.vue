<script setup>
import BackButton from 'dashboard/components/widgets/BackButton.vue';

defineProps({
  headerTitle: {
    required: true,
    type: String,
  },
  headerDescription: {
    type: String,
    default: '',
  },
  hasBackButton: {
    type: Boolean,
    default: false,
  },
});
</script>

<template>
  <section class="flex flex-col gap-1 pt-8 pb-6">
    <div v-if="hasBackButton">
      <BackButton compact />
    </div>
    <div class="flex justify-between w-full gap-5">
      <div class="flex flex-col gap-2">
        <div class="flex flex-col gap-1.5 items-start">
          <h1
            class="flex items-center m-0 text-2xl font-semibold tracking-tight leading-tight text-n-slate-12 min-h-10"
          >
            {{ headerTitle }}
          </h1>
          <p
            v-if="headerDescription"
            class="mb-0 text-sm text-n-slate-11 line-clamp-5 sm:line-clamp-none"
          >
            {{ headerDescription }}
          </p>
        </div>
      </div>
      <div class="flex-shrink-0">
        <slot />
      </div>
    </div>
  </section>
</template>
