<script setup>
import Spinner from 'shared/components/Spinner.vue';

defineProps({
  header: {
    type: String,
    default: '',
  },
  isLoading: {
    type: Boolean,
    default: false,
  },
  loadingMessage: {
    type: String,
    default: '',
  },
  accentClass: {
    type: String,
    default: '',
  },
});
</script>

<template>
  <div
    class="flex flex-col flex-grow p-5 rounded-xl border shadow-sm text-n-slate-12 border-n-weak bg-n-solid-1 min-h-[10rem]"
    :class="accentClass"
  >
    <div
      class="card-header grid w-full mb-5 grid-cols-[repeat(auto-fit,minmax(max-content,50%))] gap-y-2"
    >
      <slot name="header">
        <div class="flex items-center gap-2 flex-row">
          <h2 class="m-0 text-base font-semibold text-n-slate-12">
            {{ header }}
          </h2>
          <span
            class="inline-flex gap-1.5 items-center px-2 h-[1.375rem] text-xs font-medium rounded-full border bg-n-teal-3 border-n-teal-6"
          >
            <span class="rounded-full bg-n-teal-9 size-1.5" />
            <span class="text-n-teal-11">
              {{ $t('OVERVIEW_REPORTS.LIVE') }}
            </span>
          </span>
        </div>
        <div class="flex flex-row items-center justify-end gap-2">
          <slot name="control" />
        </div>
      </slot>
    </div>
    <div
      v-if="!isLoading"
      class="card-body max-w-full w-full ml-auto mr-auto justify-between flex"
    >
      <slot />
    </div>
    <div
      v-else-if="isLoading"
      class="items-center flex text-base justify-center px-12 py-6"
    >
      <Spinner />
      <span class="text-n-slate-11">
        {{ loadingMessage }}
      </span>
    </div>
  </div>
</template>
