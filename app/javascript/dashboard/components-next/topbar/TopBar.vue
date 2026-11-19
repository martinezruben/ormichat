<script setup>
import { computed } from 'vue';
import { useRoute } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useAccount } from 'dashboard/composables/useAccount';
import { useMapGetter } from 'dashboard/composables/store';
import { useSidebarResize } from 'dashboard/components-next/sidebar/provider';

const emit = defineEmits(['openKeyShortcutModal']);

const SECTION_LABELS = {
  dashboard: 'SIDEBAR.CONVERSATIONS',
  conversations: 'SIDEBAR.CONVERSATIONS',
  inbox: 'SIDEBAR.CONVERSATIONS',
  label: 'SIDEBAR.CONVERSATIONS',
  team: 'SIDEBAR.CONVERSATIONS',
  custom: 'SIDEBAR.CONVERSATIONS',
  mentions: 'SIDEBAR.CONVERSATIONS',
  participating: 'SIDEBAR.CONVERSATIONS',
  unattended: 'SIDEBAR.CONVERSATIONS',
  'inbox-view': 'SIDEBAR.INBOX',
  contacts: 'SIDEBAR.CONTACTS',
  companies: 'SIDEBAR.COMPANIES',
  reports: 'SIDEBAR.REPORTS',
  campaigns: 'SIDEBAR.CAMPAIGNS',
  settings: 'SIDEBAR.SETTINGS',
  profile: 'SIDEBAR.SETTINGS',
  captain: 'SIDEBAR.CAPTAIN',
  calls: 'SIDEBAR.CALLS',
  portals: 'SIDEBAR.HELP_CENTER.TITLE',
};

const route = useRoute();
const { t } = useI18n();
const { currentAccount, accountScopedRoute } = useAccount();
const { isCollapsed, toggleSidebar } = useSidebarResize();
const unreadCount = useMapGetter('notifications/getUnreadCount');

const sectionLabel = computed(() => {
  const segment = route.path.match(/\/accounts\/\d+\/([^/]+)/)?.[1];
  const key = SECTION_LABELS[segment];
  return key ? t(key) : '';
});
</script>

<template>
  <header
    class="flex flex-none gap-3 items-center px-6 h-14 border-b border-n-weak bg-n-surface-1"
  >
    <button
      type="button"
      :aria-label="t('TOP_BAR.TOGGLE_SIDEBAR')"
      :aria-expanded="!isCollapsed"
      class="hidden justify-center items-center -ms-2 rounded-lg transition-colors md:inline-flex size-8 text-n-slate-10 hover:bg-n-slate-3 hover:text-n-slate-12"
      @click="toggleSidebar"
    >
      <span class="i-lucide-panel-left size-4" />
    </button>
    <nav
      :aria-label="t('TOP_BAR.BREADCRUMB')"
      class="flex flex-1 gap-2 items-center min-w-0 text-sm"
    >
      <span class="truncate text-n-slate-11">{{ currentAccount?.name }}</span>
      <template v-if="sectionLabel">
        <span aria-hidden="true" class="text-n-slate-9">/</span>
        <span class="font-semibold truncate text-n-slate-12">
          {{ sectionLabel }}
        </span>
      </template>
    </nav>
    <router-link
      :to="accountScopedRoute('inbox_view')"
      :aria-label="t('SIDEBAR.NOTIFICATIONS')"
      class="inline-flex relative justify-center items-center rounded-lg transition-colors size-8 text-n-slate-11 hover:bg-n-slate-3 hover:text-n-slate-12"
    >
      <span class="i-lucide-bell size-4" />
      <span
        v-if="unreadCount"
        class="absolute top-1.5 rounded-full border-2 end-1.5 size-2 bg-n-ruby-9 border-n-surface-1"
      />
    </router-link>
    <button
      type="button"
      :aria-label="t('TOP_BAR.HELP')"
      class="inline-flex justify-center items-center rounded-lg transition-colors size-8 text-n-slate-11 hover:bg-n-slate-3 hover:text-n-slate-12"
      @click="emit('openKeyShortcutModal')"
    >
      <span class="i-lucide-circle-help size-4" />
    </button>
  </header>
</template>
