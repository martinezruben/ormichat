<script setup>
import { useAlert } from 'dashboard/composables';
import { computed, onMounted, ref } from 'vue';
import Avatar from 'next/avatar/Avatar.vue';
import { useI18n } from 'vue-i18n';
import { picoSearch } from '@chatwoot/pico-search';
import {
  useStoreGetters,
  useStore,
  useMapGetter,
} from 'dashboard/composables/store';

import AddAgent from './AddAgent.vue';
import EditAgent from './EditAgent.vue';
import BaseSettingsHeader from '../components/BaseSettingsHeader.vue';
import SettingsLayout from '../SettingsLayout.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const getters = useStoreGetters();
const store = useStore();
const { t } = useI18n();

const loading = ref({});
const showAddPopup = ref(false);
const showDeletePopup = ref(false);
const showEditPopup = ref(false);
const agentAPI = ref({ message: '' });
const currentAgent = ref({});
const searchQuery = ref('');
const roleFilter = ref('all');

const deleteConfirmText = computed(
  () => `${t('AGENT_MGMT.DELETE.CONFIRM.YES')} ${currentAgent.value.name}`
);
const deleteRejectText = computed(() => {
  return `${t('AGENT_MGMT.DELETE.CONFIRM.NO')} ${currentAgent.value.name}`;
});
const deleteMessage = computed(() => {
  return ` ${currentAgent.value.name}?`;
});

const agentList = computed(() => getters['agents/getAgents'].value);

const customRoles = useMapGetter('customRole/getCustomRoles');

const STATUS_DOT = {
  online: 'bg-n-teal-9',
  busy: 'bg-n-amber-9',
  offline: 'bg-n-slate-8',
};

const statusLabel = status =>
  t(
    `PROFILE_SETTINGS.FORM.AVAILABILITY.STATUS.${(status || 'offline').toUpperCase()}`
  );

const roleOptions = computed(() => [
  { value: 'all', label: t('AGENT_MGMT.ROLE_FILTER.ALL') },
  { value: 'administrator', label: t('AGENT_MGMT.AGENT_TYPES.ADMINISTRATOR') },
  { value: 'agent', label: t('AGENT_MGMT.AGENT_TYPES.AGENT') },
  ...customRoles.value.map(role => ({
    value: `custom_${role.id}`,
    label: role.name,
  })),
]);

const matchesRole = agent => {
  if (roleFilter.value === 'all') return true;
  if (agent.custom_role_id) {
    return roleFilter.value === `custom_${agent.custom_role_id}`;
  }
  return agent.role === roleFilter.value;
};

const filteredAgentList = computed(() => {
  const query = searchQuery.value.trim();
  const byRole = agentList.value.filter(matchesRole);
  if (!query) return byRole;
  return picoSearch(byRole, query, ['name', 'email']);
});

const uiFlags = computed(() => getters['agents/getUIFlags'].value);
const currentUserId = computed(() => getters.getCurrentUserID.value);

onMounted(() => {
  store.dispatch('agents/get');
  store.dispatch('customRole/getCustomRole');
});

const findCustomRole = agent =>
  customRoles.value.find(role => role.id === agent.custom_role_id);

const getAgentRoleName = agent => {
  if (!agent.custom_role_id) {
    return t(`AGENT_MGMT.AGENT_TYPES.${agent.role.toUpperCase()}`);
  }
  const customRole = findCustomRole(agent);
  return customRole ? customRole.name : '';
};

const getAgentRolePermissions = agent => {
  if (!agent.custom_role_id) {
    return [];
  }
  const customRole = findCustomRole(agent);
  return customRole?.permissions || [];
};

const verifiedAdministrators = computed(() => {
  return agentList.value.filter(
    agent => agent.role === 'administrator' && agent.confirmed
  );
});

const showEditAction = agent => {
  return currentUserId.value !== agent.id;
};

const showDeleteAction = agent => {
  if (currentUserId.value === agent.id) {
    return false;
  }

  if (!agent.confirmed) {
    return true;
  }

  if (agent.role === 'administrator') {
    return verifiedAdministrators.value.length !== 1;
  }
  return true;
};

const showAlertMessage = message => {
  loading.value[currentAgent.value.id] = false;
  currentAgent.value = {};
  agentAPI.value.message = message;
  useAlert(message);
};

const openAddPopup = () => {
  showAddPopup.value = true;
};
const hideAddPopup = () => {
  showAddPopup.value = false;
};

const openEditPopup = agent => {
  showEditPopup.value = true;
  currentAgent.value = agent;
};
const hideEditPopup = () => {
  showEditPopup.value = false;
};

const openDeletePopup = agent => {
  showDeletePopup.value = true;
  currentAgent.value = agent;
};
const closeDeletePopup = () => {
  showDeletePopup.value = false;
};

const deleteAgent = async id => {
  try {
    await store.dispatch('agents/delete', id);
    showAlertMessage(t('AGENT_MGMT.DELETE.API.SUCCESS_MESSAGE'));
  } catch (error) {
    showAlertMessage(t('AGENT_MGMT.DELETE.API.ERROR_MESSAGE'));
  }
};
const confirmDeletion = () => {
  loading.value[currentAgent.value.id] = true;
  closeDeletePopup();
  deleteAgent(currentAgent.value.id);
};
</script>

<template>
  <SettingsLayout
    :is-loading="uiFlags.isFetching"
    :loading-message="$t('AGENT_MGMT.LOADING')"
    :no-records-found="!agentList.length"
    :no-records-message="$t('AGENT_MGMT.LIST.404')"
  >
    <template #header>
      <BaseSettingsHeader
        v-model:search-query="searchQuery"
        :title="$t('AGENT_MGMT.HEADER')"
        :description="$t('AGENT_MGMT.DESCRIPTION')"
        :link-text="$t('AGENT_MGMT.LEARN_MORE')"
        :search-placeholder="$t('AGENT_MGMT.SEARCH_PLACEHOLDER')"
        feature-name="agents"
      >
        <template v-if="agentList?.length" #count>
          <span class="text-body-main text-n-slate-11">
            {{ $t('AGENT_MGMT.COUNT', { n: agentList.length }) }}
          </span>
        </template>
        <template #actions>
          <select
            v-model="roleFilter"
            :aria-label="$t('AGENT_MGMT.ROLE_FILTER.LABEL')"
            class="!mb-0 !w-auto h-8 text-sm"
          >
            <option
              v-for="option in roleOptions"
              :key="option.value"
              :value="option.value"
            >
              {{ option.label }}
            </option>
          </select>
          <Button
            :label="$t('AGENT_MGMT.HEADER_BTN_TXT')"
            icon="i-lucide-user-plus"
            @click="openAddPopup"
          />
        </template>
      </BaseSettingsHeader>
    </template>
    <template #body>
      <span
        v-if="!filteredAgentList.length && searchQuery"
        class="flex-1 flex items-center justify-center py-20 text-center text-body-main !text-base text-n-slate-11"
      >
        {{ $t('AGENT_MGMT.NO_RESULTS') }}
      </span>
      <div
        v-else
        class="overflow-hidden rounded-xl border shadow-sm bg-n-solid-1 border-n-weak"
      >
        <div class="divide-y divide-n-weak">
          <div
            v-for="(agent, index) in filteredAgentList"
            :key="agent.email"
            class="flex flex-row gap-4 justify-between items-center px-5 py-3 transition-colors hover:bg-n-slate-2"
          >
            <div class="flex gap-3 items-center min-w-0">
              <Avatar
                :src="agent.thumbnail"
                :name="agent.name"
                :status="agent.availability_status"
                :size="40"
                hide-offline-status
              />
              <div class="flex flex-col gap-0.5 items-start min-w-0">
                <span
                  class="flex gap-2 items-center text-sm font-semibold capitalize text-n-slate-12"
                >
                  {{ agent.name }}
                  <span
                    class="inline-flex gap-1 items-center px-2 h-[1.375rem] text-xs font-medium normal-case rounded-full border"
                    :class="
                      agent.confirmed
                        ? 'bg-n-teal-3 border-n-teal-6 text-n-teal-11'
                        : 'bg-n-amber-3 border-n-amber-6 text-n-amber-11'
                    "
                  >
                    <span
                      class="size-3"
                      :class="
                        agent.confirmed
                          ? 'i-lucide-badge-check'
                          : 'i-lucide-clock'
                      "
                    />
                    {{
                      agent.confirmed
                        ? $t('AGENT_MGMT.LIST.VERIFIED')
                        : $t('AGENT_MGMT.LIST.VERIFICATION_PENDING')
                    }}
                  </span>
                </span>
                <div class="flex items-center gap-2">
                  <span class="text-[0.8125rem] truncate text-n-slate-11">
                    {{ agent.email }}
                  </span>
                  <div class="w-px h-3 bg-n-strong rounded-lg" />
                  <span
                    class="inline-flex relative items-center px-2 h-[1.375rem] text-xs font-medium rounded-full border w-fit bg-n-blue-3 border-n-blue-6 text-n-blue-11"
                    :class="{
                      'hover:text-n-slate-12 group cursor-pointer':
                        agent.custom_role_id,
                    }"
                  >
                    {{ getAgentRoleName(agent) }}

                    <div
                      class="absolute ltr:left-0 rtl:right-0 z-10 hidden w-[300px] bg-n-alpha-3 backdrop-blur-[100px] rounded-xl outline outline-1 outline-n-container shadow-lg top-14 md:top-12"
                      :class="{ 'group-hover:block': agent.custom_role_id }"
                    >
                      <div class="flex flex-col gap-1 p-4">
                        <span class="text-heading-3 text-n-slate-12">
                          {{ $t('AGENT_MGMT.LIST.AVAILABLE_CUSTOM_ROLE') }}
                        </span>
                        <ul class="ltr:pl-4 rtl:pr-4 mb-0 list-disc">
                          <li
                            v-for="permission in getAgentRolePermissions(agent)"
                            :key="permission"
                            class="text-body-main text-n-slate-11"
                          >
                            {{
                              $t(
                                `CUSTOM_ROLE.PERMISSIONS.${permission.toUpperCase()}`
                              )
                            }}
                          </li>
                        </ul>
                      </div>
                    </div>
                  </span>
                </div>
              </div>
            </div>
            <div class="flex gap-3 justify-end items-center">
              <span
                class="hidden gap-1.5 items-center text-[0.8125rem] sm:inline-flex text-n-slate-12/80"
              >
                <span
                  class="rounded-full size-2"
                  :class="
                    STATUS_DOT[agent.availability_status] || 'bg-n-slate-8'
                  "
                />
                {{ statusLabel(agent.availability_status) }}
              </span>
              <Button
                v-if="showEditAction(agent)"
                v-tooltip.top="$t('AGENT_MGMT.EDIT.BUTTON_TEXT')"
                icon="i-woot-edit-pen"
                slate
                sm
                @click="openEditPopup(agent)"
              />
              <Button
                v-if="showDeleteAction(agent)"
                v-tooltip.top="$t('AGENT_MGMT.DELETE.BUTTON_TEXT')"
                icon="i-woot-bin"
                slate
                sm
                class="hover:enabled:text-n-ruby-11 hover:enabled:bg-n-ruby-2"
                :is-loading="loading[agent.id]"
                @click="openDeletePopup(agent, index)"
              />
            </div>
          </div>
        </div>
        <div
          class="px-5 py-3 text-[0.8125rem] border-t bg-n-surface-2 border-n-weak text-n-slate-11"
        >
          {{ $t('AGENT_MGMT.COUNT', { n: filteredAgentList.length }) }}
        </div>
      </div>
    </template>

    <woot-modal v-model:show="showAddPopup" :on-close="hideAddPopup">
      <AddAgent @close="hideAddPopup" />
    </woot-modal>

    <woot-modal v-model:show="showEditPopup" :on-close="hideEditPopup">
      <EditAgent
        v-if="showEditPopup"
        :id="currentAgent.id"
        :name="currentAgent.name"
        :provider="currentAgent.provider"
        :type="currentAgent.role"
        :email="currentAgent.email"
        :availability="currentAgent.availability_status"
        :custom-role-id="currentAgent.custom_role_id"
        @close="hideEditPopup"
      />
    </woot-modal>

    <woot-delete-modal
      v-model:show="showDeletePopup"
      :on-close="closeDeletePopup"
      :on-confirm="confirmDeletion"
      :title="$t('AGENT_MGMT.DELETE.CONFIRM.TITLE')"
      :message="$t('AGENT_MGMT.DELETE.CONFIRM.MESSAGE')"
      :message-value="deleteMessage"
      :confirm-text="deleteConfirmText"
      :reject-text="deleteRejectText"
    />
  </SettingsLayout>
</template>
