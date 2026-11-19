<script setup>
import BaseHeatmapContainer from './BaseHeatmapContainer.vue';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();
</script>

<template>
  <BaseHeatmapContainer
    metric="resolutions_count"
    :title="t('OVERVIEW_REPORTS.RESOLUTION_HEATMAP.HEADER')"
    :description="t('OVERVIEW_REPORTS.RESOLUTION_HEATMAP.DESCRIPTION')"
    icon="i-lucide-circle-check"
    download-title="resolution_heatmap"
    store-getter="getAccountResolutionHeatmapData"
    store-action="fetchAccountResolutionHeatmap"
    ui-flag-key="isFetchingAccountResolutionsHeatmap"
    color-scheme="green"
  />
</template>
