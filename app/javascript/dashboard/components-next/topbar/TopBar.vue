<script setup>
import { computed } from 'vue';
import { useRoute } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useAccount } from 'dashboard/composables/useAccount';
import { useMapGetter } from 'dashboard/composables/store';
import { useSidebarResize } from 'dashboard/components-next/sidebar/provider';
import { emitter } from 'shared/helpers/mitt';
import { CMD_OPEN_COMMAND_BAR } from 'dashboard/helper/commandbar/events';
import Avatar from 'dashboard/components-next/avatar/Avatar.vue';

const emit = defineEmits(['openKeyShortcutModal']);

const SEARCH_SHORTCUT = 'Ctrl K';

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
  products: 'SIDEBAR.PRODUCTS',
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
const currentUser = useMapGetter('getCurrentUser');
const currentUserAvailability = useMapGetter('getCurrentUserAvailability');

const openCommandBar = () => emitter.emit(CMD_OPEN_COMMAND_BAR);

const sectionLabel = computed(() => {
  const segment = route.path.match(/\/accounts\/\d+\/([^/]+)/)?.[1];
  const key = SECTION_LABELS[segment];
  return key ? t(key) : '';
});
</script>

<template>
  <header
    class="flex flex-none gap-3 items-center px-6 h-14 bg-n-surface-1 border-b border-n-weak md:h-[3.75rem] md:border md:shadow-sm"
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
    <h1
      class="flex-1 m-0 min-w-0 text-lg font-semibold tracking-tight truncate text-n-slate-12"
    >
      {{ sectionLabel || currentAccount?.name }}
    </h1>
    <button
      type="button"
      class="hidden gap-2 items-center px-3 w-full max-w-[21.25rem] h-9 text-sm rounded-lg border transition-colors sm:flex border-n-weak bg-n-solid-1 text-n-slate-11 hover:border-n-strong"
      @click="openCommandBar"
    >
      <span class="i-lucide-search size-4" />
      <span class="flex-1 text-start truncate">
        {{ t('TOP_BAR.SEARCH_PLACEHOLDER') }}
      </span>
      <kbd
        class="px-1.5 text-[0.6875rem] font-medium rounded-md border border-b-2 border-n-weak bg-n-slate-2 text-n-slate-11"
      >
        {{ SEARCH_SHORTCUT }}
      </kbd>
    </button>
    <button
      type="button"
      :aria-label="t('TOP_BAR.HELP')"
      class="inline-flex justify-center items-center rounded-lg transition-colors size-8 text-n-slate-11 hover:bg-n-slate-3 hover:text-n-slate-12"
      @click="emit('openKeyShortcutModal')"
    >
      <span class="i-lucide-circle-help size-4" />
    </button>
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
    <Avatar
      :size="34"
      :name="currentUser.available_name"
      :src="currentUser.avatar_url"
      :status="currentUserAvailability"
    />
  </header>
</template>
