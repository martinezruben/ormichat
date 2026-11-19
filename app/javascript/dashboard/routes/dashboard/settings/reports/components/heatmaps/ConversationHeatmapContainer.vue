<script setup>
import BaseHeatmapContainer from './BaseHeatmapContainer.vue';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();
</script>

<template>
  <BaseHeatmapContainer
    metric="conversations_count"
    :title="t('OVERVIEW_REPORTS.CONVERSATION_HEATMAP.HEADER')"
    :description="t('OVERVIEW_REPORTS.CONVERSATION_HEATMAP.DESCRIPTION')"
    icon="i-lucide-chart-no-axes-column"
    download-title="conversation_heatmap"
    store-getter="getAccountConversationHeatmapData"
    store-action="fetchAccountConversationHeatmap"
    download-action="downloadAccountConversationHeatmap"
    ui-flag-key="isFetchingAccountConversationsHeatmap"
  />
</template>
