<script setup>
import { useI18n } from 'vue-i18n';

defineProps({
  title: { type: String, required: true },
  description: { type: String, required: true },
  hideContent: { type: Boolean, default: false },
  beta: { type: Boolean, default: false },
  icon: { type: String, default: '' },
  iconTone: { type: String, default: 'bg-n-blue-3 text-n-brand' },
});
const { t } = useI18n();
</script>

<template>
  <section
    class="grid grid-cols-1 p-6 mt-6 rounded-xl border shadow-sm bg-n-solid-1 border-n-weak [interpolate-size:allow-keywords]"
    :class="{ 'gap-5': !hideContent }"
  >
    <header class="grid grid-cols-4">
      <div
        v-if="
          title || beta || $slots.title || description || $slots.description
        "
        class="col-span-3"
      >
        <span
          v-if="icon"
          aria-hidden="true"
          class="inline-flex justify-center items-center mb-3 rounded-[0.625rem] size-9"
          :class="iconTone"
        >
          <span class="size-[1.125rem]" :class="icon" />
        </span>
        <h4
          v-if="title || beta || $slots.title"
          class="flex gap-2 items-center m-0 text-base font-semibold text-n-slate-12"
        >
          <slot name="title">{{ title }}</slot>
          <div
            v-if="beta"
            v-tooltip.top="t('GENERAL.BETA_DESCRIPTION')"
            class="text-xs uppercase text-n-iris-11 border border-1 border-n-iris-10 leading-none rounded-lg px-1 py-0.5"
          >
            {{ t('GENERAL.BETA') }}
          </div>
        </h4>
        <p
          v-if="description || $slots.description"
          class="mt-1 mb-0 text-[0.8125rem] leading-normal text-n-slate-11"
        >
          <slot name="description">{{ description }}</slot>
        </p>
      </div>
      <div class="col-span-1">
        <slot name="headerActions" />
      </div>
    </header>
    <div
      class="transition-[height] duration-300 ease-in-out text-n-slate-12"
      :class="{ 'overflow-hidden h-0': hideContent, 'h-auto': !hideContent }"
    >
      <slot />
    </div>
  </section>
</template>
