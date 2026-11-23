<script setup>
import { computed, watch, onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import {
  useMapGetter,
  useFunctionGetter,
  useStore,
} from 'dashboard/composables/store';
import { useAccount } from 'dashboard/composables/useAccount';
import { useUISettings } from 'dashboard/composables/useUISettings';
import { FEATURE_FLAGS } from 'dashboard/featureFlags';

import ContactPanelSection from './ContactPanelSection.vue';
import ContactPanelTimeline from './ContactPanelTimeline.vue';
import ConversationLabels from './labels/LabelBox.vue';
import ContactConversations from './ContactConversations.vue';
import ConversationAction from './ConversationAction.vue';
import ConversationParticipant from './ConversationParticipant.vue';
import ContactInfo from './contact/ContactInfo.vue';
import ConversationStats from './contact/ConversationStats.vue';
import ConversationAISummary from './contact/ConversationAISummary.vue';
import ContactNotes from './contact/ContactNotes.vue';
import ConversationInfo from './ConversationInfo.vue';
import CustomAttributes from './customAttributes/CustomAttributes.vue';
import SharedFiles from './SharedFiles.vue';
import MacrosList from './Macros/List.vue';
import ShopifyOrdersList from 'dashboard/components/widgets/conversation/ShopifyOrdersList.vue';
import SidebarActionsHeader from 'dashboard/components-next/SidebarActionsHeader.vue';
import LinearIssuesList from 'dashboard/components/widgets/conversation/linear/IssuesList.vue';
import LinearSetupCTA from 'dashboard/components/widgets/conversation/linear/LinearSetupCTA.vue';

const props = defineProps({
  conversationId: {
    type: [Number, String],
    required: true,
  },
  inboxId: {
    type: Number,
    default: undefined,
  },
});

const { updateUISettings } = useUISettings();
const { t } = useI18n();

const TABS = [
  { key: 'summary', label: 'CONVERSATION_SIDEBAR.TABS.SUMMARY' },
  { key: 'conversation', label: 'CONVERSATION_SIDEBAR.TABS.CONVERSATION' },
  { key: 'contact', label: 'CONVERSATION_SIDEBAR.TABS.CONTACT' },
  { key: 'activity', label: 'CONVERSATION_SIDEBAR.TABS.ACTIVITY' },
];

const activeTab = ref(TABS[0].key);
const SECTION = 'CONVERSATION_SIDEBAR.ACCORDION';
const query = ref('');

const normalize = text =>
  String(text)
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase();

const selectTab = key => {
  query.value = '';
  activeTab.value = key;
};

const isSearching = computed(() => query.value.trim() !== '');

// Sections are shown by tab, or across all tabs when their title matches the search
const isVisible = (tab, titleKey) => {
  if (!isSearching.value) return activeTab.value === tab;
  return normalize(t(titleKey)).includes(normalize(query.value.trim()));
};

const shopifyIntegration = useFunctionGetter(
  'integrations/getIntegration',
  'shopify'
);

const isShopifyFeatureEnabled = computed(
  () => shopifyIntegration.value.enabled
);

const { isCloudFeatureEnabled } = useAccount();

const isLinearFeatureEnabled = computed(() =>
  isCloudFeatureEnabled(FEATURE_FLAGS.LINEAR)
);

const linearIntegration = useFunctionGetter(
  'integrations/getIntegration',
  'linear'
);

const isLinearClientIdConfigured = computed(() => {
  return !!linearIntegration.value?.id;
});

const isLinearConnected = computed(
  () => linearIntegration.value?.enabled || false
);

const store = useStore();
const currentChat = useMapGetter('getSelectedChat');
const conversationId = computed(() => props.conversationId);
const conversationMetadataGetter = useMapGetter(
  'conversationMetadata/getConversationMetadata'
);
const currentConversationMetaData = computed(() =>
  conversationMetadataGetter.value(conversationId.value)
);
const conversationAdditionalAttributes = computed(
  () => currentConversationMetaData.value.additional_attributes || {}
);

const channelType = computed(() => currentChat.value.meta?.channel);

const contactGetter = useMapGetter('contacts/getContact');
const contactId = computed(() => currentChat.value.meta?.sender?.id);
const contact = computed(() => contactGetter.value(contactId.value));
const contactAdditionalAttributes = computed(
  () => contact.value.additional_attributes || {}
);

const getContactDetails = () => {
  if (contactId.value) {
    store.dispatch('contacts/show', { id: contactId.value });
  }
};

watch(contactId, (newContactId, prevContactId) => {
  if (newContactId && newContactId !== prevContactId) {
    getContactDetails();
  }
});

const closeContactPanel = () => {
  updateUISettings({
    is_contact_sidebar_open: false,
    is_copilot_panel_open: false,
  });
};

onMounted(() => {
  getContactDetails();
  store.dispatch('attributes/get', 0);
  // Load integrations to ensure linear integration state is available
  store.dispatch('integrations/get', 'linear');
});
</script>

<template>
  <div class="w-full min-w-0 overflow-x-hidden">
    <SidebarActionsHeader
      :title="$t('CONVERSATION.SIDEBAR.CONTACT')"
      @close="closeContactPanel"
    />
    <ContactInfo
      :contact="contact"
      :channel-type="channelType"
      @go-contact="selectTab('contact')"
    />
    <div
      class="sticky top-0 z-10 flex flex-col gap-2 px-3 pt-2 border-b bg-n-surface-1 border-n-weak"
    >
      <div class="relative">
        <span
          class="absolute i-lucide-search size-4 start-2.5 top-2 text-n-slate-10"
        />
        <input
          v-model="query"
          type="search"
          :aria-label="$t('CONVERSATION_SIDEBAR.SEARCH_PLACEHOLDER')"
          :placeholder="$t('CONVERSATION_SIDEBAR.SEARCH_PLACEHOLDER')"
          class="!m-0 !h-8 w-full !text-sm !ps-8 !rounded-lg"
        />
      </div>
      <div role="tablist" class="flex gap-0.5">
        <button
          v-for="tab in TABS"
          :key="tab.key"
          type="button"
          role="tab"
          :aria-selected="!isSearching && activeTab === tab.key"
          class="flex-1 min-w-0 px-1 py-2 text-xs font-medium truncate transition-colors"
          :class="
            !isSearching && activeTab === tab.key
              ? 'shadow-[inset_0_-2px_0_0] shadow-n-brand text-n-slate-12'
              : 'text-n-slate-11 hover:text-n-slate-12'
          "
          @click="selectTab(tab.key)"
        >
          {{ $t(tab.label) }}
        </button>
      </div>
    </div>
    <div class="flex flex-col gap-5 px-3 py-4 min-w-0">
      <template v-if="!isSearching && activeTab === 'summary'">
        <ConversationStats />
      </template>
      <ContactPanelSection
        v-if="isVisible('summary', 'CONVERSATION_SIDEBAR.QUICK_ACTIONS')"
        :title="$t('CONVERSATION_SIDEBAR.QUICK_ACTIONS')"
      >
        <ConversationAction
          :conversation-id="conversationId"
          layout="grid"
          :show-labels="false"
        />
      </ContactPanelSection>
      <ContactPanelSection
        v-if="isVisible('summary', `${SECTION}.CONVERSATION_LABELS`)"
        :title="$t(`${SECTION}.CONVERSATION_LABELS`)"
      >
        <ConversationLabels :conversation-id="conversationId" />
      </ContactPanelSection>
      <ConversationAISummary
        v-if="!isSearching && activeTab === 'summary'"
        :conversation-id="conversationId"
      />
      <ContactPanelSection
        v-if="isVisible('summary', `${SECTION}.CONTACT_NOTES`)"
        :title="$t(`${SECTION}.CONTACT_NOTES`)"
      >
        <ContactNotes :contact-id="contactId" />
      </ContactPanelSection>
      <ContactPanelSection
        v-if="isVisible('conversation', `${SECTION}.CONVERSATION_ACTIONS`)"
        :title="$t(`${SECTION}.CONVERSATION_ACTIONS`)"
      >
        <ConversationAction
          :conversation-id="conversationId"
          :show-labels="false"
        />
      </ContactPanelSection>
      <ContactPanelSection
        v-if="
          activeTab === 'conversation' &&
          !isSearching &&
          isVisible('conversation', `${SECTION}.CONVERSATION_LABELS`)
        "
        :title="$t(`${SECTION}.CONVERSATION_LABELS`)"
      >
        <ConversationLabels :conversation-id="conversationId" />
      </ContactPanelSection>
      <ContactPanelSection
        v-if="
          isVisible('conversation', 'CONVERSATION_PARTICIPANTS.SIDEBAR_TITLE')
        "
        :title="$t('CONVERSATION_PARTICIPANTS.SIDEBAR_TITLE')"
      >
        <ConversationParticipant
          :conversation-id="conversationId"
          :inbox-id="inboxId"
        />
      </ContactPanelSection>
      <woot-feature-toggle
        v-if="isVisible('conversation', `${SECTION}.MACROS`)"
        feature-key="macros"
      >
        <ContactPanelSection :title="$t(`${SECTION}.MACROS`)">
          <MacrosList :conversation-id="conversationId" />
        </ContactPanelSection>
      </woot-feature-toggle>
      <ContactPanelSection
        v-if="isVisible('conversation', `${SECTION}.CONVERSATION_INFO`)"
        :title="$t(`${SECTION}.CONVERSATION_INFO`)"
      >
        <ConversationInfo
          :conversation-attributes="conversationAdditionalAttributes"
          :contact-attributes="contactAdditionalAttributes"
        />
      </ContactPanelSection>
      <ContactPanelSection
        v-if="
          isLinearFeatureEnabled &&
          isLinearClientIdConfigured &&
          isVisible('conversation', `${SECTION}.LINEAR_ISSUES`)
        "
        :title="$t(`${SECTION}.LINEAR_ISSUES`)"
      >
        <LinearSetupCTA v-if="!isLinearConnected" />
        <LinearIssuesList v-else :conversation-id="conversationId" />
      </ContactPanelSection>
      <ContactPanelSection
        v-if="
          isShopifyFeatureEnabled &&
          isVisible('conversation', `${SECTION}.SHOPIFY_ORDERS`)
        "
        :title="$t(`${SECTION}.SHOPIFY_ORDERS`)"
      >
        <ShopifyOrdersList :contact-id="contactId" />
      </ContactPanelSection>
      <ContactPanelSection
        v-if="isVisible('contact', `${SECTION}.CONTACT_DETAILS`)"
        :title="$t(`${SECTION}.CONTACT_DETAILS`)"
      >
        <ContactInfo mode="details" :contact="contact" />
      </ContactPanelSection>
      <ContactPanelSection
        v-if="isVisible('contact', `${SECTION}.CONTACT_ATTRIBUTES`)"
        :title="$t(`${SECTION}.CONTACT_ATTRIBUTES`)"
      >
        <CustomAttributes
          attribute-type="contact_attribute"
          attribute-from="conversation_contact_panel"
          :contact-id="contact.id"
          :empty-state-message="
            $t('CONVERSATION_CUSTOM_ATTRIBUTES.NO_RECORDS_FOUND')
          "
        />
      </ContactPanelSection>
      <ContactPanelSection
        v-if="isVisible('activity', 'CONVERSATION_SIDEBAR.TABS.ACTIVITY')"
        :title="$t('CONVERSATION_SIDEBAR.TABS.ACTIVITY')"
      >
        <ContactPanelTimeline />
      </ContactPanelSection>
      <ContactPanelSection
        v-if="
          contact.id &&
          isVisible('activity', `${SECTION}.PREVIOUS_CONVERSATION`)
        "
        :title="$t(`${SECTION}.PREVIOUS_CONVERSATION`)"
      >
        <ContactConversations
          :contact-id="contact.id"
          :conversation-id="conversationId"
        />
      </ContactPanelSection>
      <ContactPanelSection
        v-if="isVisible('activity', `${SECTION}.SHARED_FILES`)"
        :title="$t(`${SECTION}.SHARED_FILES`)"
      >
        <SharedFiles />
      </ContactPanelSection>
    </div>
  </div>
</template>
