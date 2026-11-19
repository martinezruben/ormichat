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
  icon: {
    type: String,
    default: '',
  },
  description: {
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
        <div class="flex flex-row gap-3 items-start">
          <span
            v-if="icon"
            aria-hidden="true"
            class="inline-flex flex-none justify-center items-center rounded-[0.625rem] size-9 bg-n-blue-3 text-n-brand"
          >
            <span class="size-[1.125rem]" :class="icon" />
          </span>
          <div class="flex flex-col gap-1">
            <div class="flex flex-row gap-2 items-center">
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
            <p v-if="description" class="m-0 text-[0.8125rem] text-n-slate-11">
              {{ description }}
            </p>
          </div>
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
