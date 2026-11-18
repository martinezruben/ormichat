<script setup>
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStoreGetters } from 'dashboard/composables/store';

const getters = useStoreGetters();
const { t } = useI18n();
const globalConfig = computed(() => getters['globalConfig/get'].value);
const STEPS = [
  {
    key: 'ALL_CONVERSATION',
    to: 'settings_inbox_new',
    icon: 'i-lucide-inbox',
    tone: 'bg-n-blue-3 text-n-blue-11',
  },
  {
    key: 'TEAM_MEMBERS',
    to: 'settings_teams_new',
    icon: 'i-lucide-users',
    tone: 'bg-n-teal-3 text-n-teal-11',
  },
  {
    key: 'CANNED_RESPONSES',
    to: 'canned_list',
    icon: 'i-lucide-message-square-text',
    tone: 'bg-n-amber-3 text-n-amber-11',
  },
  {
    key: 'LABELS',
    to: 'labels_list',
    icon: 'i-lucide-tag',
    tone: 'bg-n-ruby-3 text-n-ruby-11',
  },
];

const currentUser = computed(() => getters.getCurrentUser.value);

const greetingMessage = computed(() => {
  const hours = new Date().getHours();
  let translationKey;
  if (hours < 12) {
    translationKey = 'ONBOARDING.GREETING_MORNING';
  } else if (hours < 18) {
    translationKey = 'ONBOARDING.GREETING_AFTERNOON';
  } else {
    translationKey = 'ONBOARDING.GREETING_EVENING';
  }
  return t(translationKey, {
    name: currentUser.value.name,
    installationName: globalConfig.value.installationName,
  });
});
</script>

<template>
  <div class="overflow-auto px-10 pt-8 pb-14 w-full h-full bg-n-surface-2">
    <div class="flex flex-col gap-6 mx-auto max-w-[51.25rem]">
      <div
        class="overflow-hidden relative p-8 text-white bg-gradient-to-br from-n-brand to-n-violet-9 rounded-2xl shadow-lg"
      >
        <span
          aria-hidden="true"
          class="absolute -top-20 rounded-full border-[2.5rem] size-[16.25rem] -end-[3.75rem] border-white/10"
        />
        <div class="relative max-w-[32.5rem]">
          <h1
            class="m-0 text-[1.75rem] font-semibold tracking-tight leading-tight"
          >
            {{ greetingMessage }}
          </h1>
          <p class="mt-2.5 mb-5 text-[0.9375rem] leading-relaxed text-white/90">
            {{
              $t('ONBOARDING.DESCRIPTION', {
                installationName: globalConfig.installationName,
              })
            }}
          </p>
          <router-link
            :to="{ name: 'settings_inbox_new' }"
            class="inline-flex gap-2 items-center px-4 h-[2.375rem] text-sm font-semibold bg-white rounded-lg shadow-md text-n-blue-11"
          >
            {{ $t('ONBOARDING.ALL_CONVERSATION.NEW_LINK') }}
            <span class="i-lucide-arrow-right size-4" />
          </router-link>
        </div>
      </div>
      <section
        class="overflow-hidden rounded-xl border shadow-sm bg-n-solid-1 border-n-weak"
      >
        <h2 class="p-5 m-0 text-base font-semibold text-n-slate-12">
          {{ $t('ONBOARDING.GETTING_STARTED') }}
        </h2>
        <div
          v-for="step in STEPS"
          :key="step.key"
          class="flex flex-wrap gap-4 items-center px-5 py-4 border-t transition-colors border-n-weak hover:bg-n-slate-2"
        >
          <span
            aria-hidden="true"
            class="inline-flex flex-none justify-center items-center rounded-[0.625rem] size-9"
            :class="step.tone"
          >
            <span class="size-[1.125rem]" :class="step.icon" />
          </span>
          <div class="flex-1 min-w-0 basis-72">
            <div class="text-sm font-semibold text-n-slate-12">
              {{ $t(`ONBOARDING.${step.key}.TITLE`) }}
            </div>
            <div class="mt-0.5 text-[0.8125rem] leading-normal text-n-slate-11">
              {{ $t(`ONBOARDING.${step.key}.DESCRIPTION`) }}
            </div>
          </div>
          <router-link
            :to="{ name: step.to }"
            class="inline-flex gap-2 items-center px-4 h-8 text-[0.8125rem] font-medium rounded-lg border shadow-sm transition-colors bg-n-solid-1 border-n-weak text-n-slate-12 hover:bg-n-slate-3"
          >
            {{ $t(`ONBOARDING.${step.key}.NEW_LINK`) }}
            <span class="i-lucide-arrow-right size-3.5" />
          </router-link>
        </div>
      </section>
    </div>
  </div>
</template>
