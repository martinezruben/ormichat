<script setup>
import { computed, onMounted, ref } from 'vue';
import { OVERVIEW_METRICS } from '../constants';
import { useToggle } from '@vueuse/core';

import MetricCard from './overview/MetricCard.vue';
import { useStore, useMapGetter } from 'dashboard/composables/store';
import { useLiveRefresh } from 'dashboard/composables/useLiveRefresh';
import DropdownMenu from 'dashboard/components-next/dropdown-menu/DropdownMenu.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import { useI18n } from 'vue-i18n';
const { t } = useI18n();

const uiFlags = useMapGetter('getOverviewUIFlags');
const agentStatus = useMapGetter('agents/getAgentStatus');
const accountConversationMetric = useMapGetter('getAccountConversationMetric');
const store = useStore();

const accounti18nKey = 'OVERVIEW_REPORTS.ACCOUNT_CONVERSATIONS';
const teams = useMapGetter('teams/getTeams');

const teamMenuList = computed(() => {
  return [
    { label: t('OVERVIEW_REPORTS.TEAM_CONVERSATIONS.ALL_TEAMS'), value: null },
    ...teams.value.map(team => ({ label: team.name, value: team.id })),
  ];
});

const METRIC_ICONS = {
  open: { icon: 'i-lucide-message-circle', tone: 'bg-n-blue-3 text-n-blue-11' },
  unattended: {
    icon: 'i-lucide-bell-ring',
    tone: 'bg-n-ruby-3 text-n-ruby-11',
  },
  unassigned: { icon: 'i-lucide-user-x', tone: 'bg-n-amber-3 text-n-amber-11' },
  pending: { icon: 'i-lucide-clock', tone: 'bg-n-slate-3 text-n-slate-12' },
  online: { icon: 'i-lucide-circle-check', tone: 'bg-n-teal-3 text-n-teal-11' },
  busy: { icon: 'i-lucide-circle-minus', tone: 'bg-n-amber-3 text-n-amber-11' },
  offline: {
    icon: 'i-lucide-circle-off',
    tone: 'bg-n-slate-3 text-n-slate-12',
  },
};

const buildMetrics = (values, i18nPrefix) =>
  Object.keys(values).map(key => ({
    key,
    name: t(`${i18nPrefix}.${OVERVIEW_METRICS[key]}`),
    value: values[key],
    ...METRIC_ICONS[key],
  }));

const agentStatusMetrics = computed(() =>
  buildMetrics(agentStatus.value, 'OVERVIEW_REPORTS.AGENT_STATUS')
);
const conversationMetrics = computed(() =>
  buildMetrics(accountConversationMetric.value, accounti18nKey)
);

const selectedTeam = ref(null);
const selectedTeamLabel = computed(() => {
  const team =
    teamMenuList.value.find(
      menuItem => menuItem.value === selectedTeam.value
    ) || {};
  return team.label;
});
const fetchData = () => {
  const params = {};
  if (selectedTeam.value) {
    params.team_id = selectedTeam.value;
  }
  store.dispatch('fetchAccountConversationMetric', params);
};

const { startRefetching } = useLiveRefresh(fetchData);
const [showDropdown, toggleDropdown] = useToggle();

const handleAction = ({ value }) => {
  toggleDropdown(false);
  selectedTeam.value = value;
  fetchData();
};

onMounted(() => {
  fetchData();
  startRefetching();
});
</script>

<template>
  <div class="flex flex-col items-center md:flex-row gap-4">
    <div
      class="flex-1 w-full max-w-full md:w-[65%] md:max-w-[65%] conversation-metric"
    >
      <MetricCard
        :header="t(`${accounti18nKey}.HEADER`)"
        accent-class="border-t-[3px] border-t-n-brand"
        :is-loading="uiFlags.isFetchingAccountConversationMetric"
        :loading-message="t(`${accounti18nKey}.LOADING_MESSAGE`)"
      >
        <template v-if="teams.length" #control>
          <div
            v-on-clickaway="() => toggleDropdown(false)"
            class="relative flex items-center group z-50"
          >
            <Button
              sm
              slate
              faded
              :label="selectedTeamLabel"
              class="capitalize rounded-md group-hover:bg-n-alpha-2"
              @click="toggleDropdown()"
            />
            <DropdownMenu
              v-if="showDropdown"
              :menu-items="teamMenuList"
              class="mt-1 ltr:right-0 rtl:left-0 xl:ltr:right-0 xl:rtl:left-0 top-full"
              label-class="capitalize"
              @action="handleAction($event)"
            />
          </div>
        </template>
        <div
          v-for="metric in conversationMetrics"
          :key="metric.key"
          class="flex flex-col flex-1 gap-2.5 min-w-0"
        >
          <h3
            class="inline-flex gap-2 items-center m-0 text-[0.8125rem] font-medium text-n-slate-11"
          >
            <span
              class="inline-flex justify-center items-center rounded-[0.4375rem] size-6"
              :class="metric.tone"
            >
              <span class="size-3.5" :class="metric.icon" />
            </span>
            {{ metric.name }}
          </h3>
          <p
            class="m-0 text-[2rem] font-semibold tracking-tight leading-none tabular-nums text-n-slate-12"
          >
            {{ metric.value }}
          </p>
        </div>
      </MetricCard>
    </div>
    <div class="flex-1 w-full max-w-full md:w-[35%] md:max-w-[35%]">
      <MetricCard
        :header="$t('OVERVIEW_REPORTS.AGENT_STATUS.HEADER')"
        accent-class="border-t-[3px] border-t-n-teal-9"
      >
        <div
          v-for="metric in agentStatusMetrics"
          :key="metric.key"
          class="flex flex-col flex-1 gap-2.5 min-w-0"
        >
          <h3
            class="inline-flex gap-2 items-center m-0 text-[0.8125rem] font-medium text-n-slate-11"
          >
            <span
              class="inline-flex justify-center items-center rounded-[0.4375rem] size-6"
              :class="metric.tone"
            >
              <span class="size-3.5" :class="metric.icon" />
            </span>
            {{ metric.name }}
          </h3>
          <p
            class="m-0 text-[2rem] font-semibold tracking-tight leading-none tabular-nums text-n-slate-12"
          >
            {{ metric.value }}
          </p>
        </div>
      </MetricCard>
    </div>
  </div>
</template>
