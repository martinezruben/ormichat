<script setup>
import { computed } from 'vue';
import { useAccount } from 'dashboard/composables/useAccount';
import { useI18n } from 'vue-i18n';

import SectionLayout from './SectionLayout.vue';

const { t } = useI18n();
const { currentAccount } = useAccount();

const getAccountId = computed(() => currentAccount.value?.id?.toString());
</script>

<template>
  <SectionLayout
    icon="i-lucide-hash"
    icon-tone="bg-n-slate-3 text-n-slate-12"
    :title="t('GENERAL_SETTINGS.FORM.ACCOUNT_ID.TITLE')"
    :description="t('GENERAL_SETTINGS.FORM.ACCOUNT_ID.NOTE')"
  >
    <woot-code :script="getAccountId" />
  </SectionLayout>
</template>
