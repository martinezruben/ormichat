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
import ContactPanelProfile from './ContactPanelProfile.vue';
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
const HEALTH_KEYS = ['seguro', 'estado_receta'];
const PREFERENCE_KEYS = ['consentimiento_contacto'];
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

const missingCount = computed(
  () =>
    [
      contact.value.email,
      contact.value.phone_number,
      contactAdditionalAttributes.value.address,
    ].filter(value => !value).length
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
    <ContactInfo :contact="contact" :channel-type="channelType" />
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
        <kbd
          v-if="!isSearching"
          class="absolute px-1.5 text-xs border rounded end-2 top-1.5 border-n-weak text-n-slate-11"
        >
          /
        </kbd>
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
    <div class="flex flex-col gap-3 p-3 min-w-0 bg-n-surface-2">
      <ContactPanelSection
        v-if="isVisible('summary', `${SECTION}.CONTACT_DETAILS`)"
        icon="i-lucide-user"
        :title="$t(`${SECTION}.CONTACT_DETAILS`)"
        :count="`${3 - missingCount} / 3`"
      >
        <ContactInfo mode="details" :contact="contact" />
      </ContactPanelSection>
      <ContactPanelSection
        v-if="isVisible('summary', 'CONVERSATION_SIDEBAR.HEALTH')"
        icon="i-lucide-shield-plus"
        :title="$t('CONVERSATION_SIDEBAR.HEALTH')"
      >
        <CustomAttributes
          attribute-type="contact_attribute"
          attribute-from="conversation_contact_health"
          :contact-id="contact.id"
          :only-keys="HEALTH_KEYS"
          :empty-state-message="
            $t('CONVERSATION_CUSTOM_ATTRIBUTES.NO_RECORDS_FOUND')
          "
        />
      </ContactPanelSection>
      <ContactPanelSection
        v-if="isVisible('summary', `${SECTION}.CONTACT_NOTES`)"
        icon="i-lucide-notebook-pen"
        :title="$t(`${SECTION}.CONTACT_NOTES`)"
      >
        <ContactNotes :contact-id="contactId" />
      </ContactPanelSection>

      <ConversationStats v-if="!isSearching && activeTab === 'conversation'" />
      <ContactPanelSection
        v-if="isVisible('conversation', `${SECTION}.CONVERSATION_ACTIONS`)"
        icon="i-lucide-sliders-horizontal"
        :title="$t(`${SECTION}.CONVERSATION_ACTIONS`)"
      >
        <ConversationAction
          :conversation-id="conversationId"
          layout="grid"
          :show-labels="false"
        />
        <div class="flex flex-col gap-1.5">
          <span class="text-xs font-medium text-n-slate-11">
            {{ $t(`${SECTION}.CONVERSATION_LABELS`) }}
          </span>
          <ConversationLabels :conversation-id="conversationId" />
        </div>
      </ContactPanelSection>
      <ConversationAISummary
        v-if="!isSearching && activeTab === 'conversation'"
        :conversation-id="conversationId"
      />
      <ContactPanelSection
        v-if="
          isVisible('conversation', 'CONVERSATION_PARTICIPANTS.SIDEBAR_TITLE')
        "
        icon="i-lucide-users"
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
        <ContactPanelSection
          icon="i-lucide-zap"
          :title="$t(`${SECTION}.MACROS`)"
        >
          <MacrosList :conversation-id="conversationId" />
        </ContactPanelSection>
      </woot-feature-toggle>
      <ContactPanelSection
        v-if="isVisible('conversation', `${SECTION}.CONVERSATION_INFO`)"
        icon="i-lucide-info"
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
        icon="i-lucide-link"
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
        icon="i-lucide-shopping-bag"
        :title="$t(`${SECTION}.SHOPIFY_ORDERS`)"
      >
        <ShopifyOrdersList :contact-id="contactId" />
      </ContactPanelSection>

      <ContactPanelSection
        v-if="isVisible('contact', `${SECTION}.CONTACT_ATTRIBUTES`)"
        icon="i-lucide-list-checks"
        :title="$t(`${SECTION}.CONTACT_ATTRIBUTES`)"
      >
        <CustomAttributes
          attribute-type="contact_attribute"
          attribute-from="conversation_contact_panel"
          :contact-id="contact.id"
          :except-keys="[...HEALTH_KEYS, ...PREFERENCE_KEYS]"
          :empty-state-message="
            $t('CONVERSATION_CUSTOM_ATTRIBUTES.NO_RECORDS_FOUND')
          "
        />
      </ContactPanelSection>
      <ContactPanelSection
        v-if="isVisible('contact', 'CONVERSATION_SIDEBAR.PROFILE_TITLE')"
        icon="i-lucide-id-card"
        :title="$t('CONVERSATION_SIDEBAR.PROFILE_TITLE')"
      >
        <ContactPanelProfile :contact="contact" />
      </ContactPanelSection>
      <ContactPanelSection
        v-if="isVisible('contact', 'CONVERSATION_SIDEBAR.PREFERENCES')"
        icon="i-lucide-heart"
        :title="$t('CONVERSATION_SIDEBAR.PREFERENCES')"
      >
        <CustomAttributes
          attribute-type="contact_attribute"
          attribute-from="conversation_contact_preferences"
          :contact-id="contact.id"
          :only-keys="PREFERENCE_KEYS"
          :empty-state-message="
            $t('CONVERSATION_CUSTOM_ATTRIBUTES.NO_RECORDS_FOUND')
          "
        />
      </ContactPanelSection>

      <ContactPanelSection
        v-if="isVisible('activity', 'CONVERSATION_SIDEBAR.TABS.ACTIVITY')"
        icon="i-lucide-clock"
        :title="$t('CONVERSATION_SIDEBAR.TABS.ACTIVITY')"
      >
        <ContactPanelTimeline />
      </ContactPanelSection>
      <ContactPanelSection
        v-if="
          contact.id &&
          isVisible('activity', `${SECTION}.PREVIOUS_CONVERSATION`)
        "
        icon="i-lucide-messages-square"
        :title="$t(`${SECTION}.PREVIOUS_CONVERSATION`)"
      >
        <ContactConversations
          :contact-id="contact.id"
          :conversation-id="conversationId"
        />
      </ContactPanelSection>
      <ContactPanelSection
        v-if="isVisible('activity', `${SECTION}.SHARED_FILES`)"
        icon="i-lucide-paperclip"
        :title="$t(`${SECTION}.SHARED_FILES`)"
      >
        <SharedFiles />
      </ContactPanelSection>
    </div>
  </div>
</template>
