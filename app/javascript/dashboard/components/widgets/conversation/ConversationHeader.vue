<script setup>
import { computed, ref } from 'vue';
import { useRoute } from 'vue-router';
import { useStore } from 'vuex';
import { useElementSize } from '@vueuse/core';
import BackButton from '../BackButton.vue';
import InboxName from '../InboxName.vue';
import MoreActions from './MoreActions.vue';
import HeaderAssignee from './HeaderAssignee.vue';
import Avatar from 'next/avatar/Avatar.vue';
import NextButton from 'dashboard/components-next/button/Button.vue';
import {
  HoverCard,
  HoverCardContent,
  HoverCardTrigger,
} from 'dashboard/components-next/ui/hover-card';
import SLACardLabel from './components/SLACardLabel.vue';
import ConversationCallButton from './ConversationCallButton.vue';
import wootConstants from 'dashboard/constants/globals';
import { conversationListPageURL } from 'dashboard/helper/URLHelper';
import { snoozedReopenTime } from 'dashboard/helper/snoozeHelpers';
import { emitter } from 'shared/helpers/mitt';
import { CMD_OPEN_COMMAND_BAR } from 'dashboard/helper/commandbar/events';
import { useInbox } from 'dashboard/composables/useInbox';
import { useAlert } from 'dashboard/composables';
import { useI18n } from 'vue-i18n';
import { copyTextToClipboard } from 'shared/helpers/clipboard';

const props = defineProps({
  chat: {
    type: Object,
    default: () => ({}),
  },
  showBackButton: {
    type: Boolean,
    default: false,
  },
});

const { t } = useI18n();
const store = useStore();
const route = useRoute();
const conversationHeader = ref(null);
const { width } = useElementSize(conversationHeader);
const { isAWebWidgetInbox } = useInbox();

const currentChat = computed(() => store.getters.getSelectedChat);
const accountId = computed(() => store.getters.getCurrentAccountId);

const chatMetadata = computed(() => props.chat.meta);

const backButtonUrl = computed(() => {
  const {
    params: { inbox_id: inboxId, label, teamId, id: customViewId },
    name,
  } = route;

  const conversationTypeMap = {
    conversation_through_mentions: 'mention',
    conversation_through_participating: 'participating',
    conversation_through_unattended: 'unattended',
  };
  return conversationListPageURL({
    accountId: accountId.value,
    inboxId,
    label,
    teamId,
    conversationType: conversationTypeMap[name],
    customViewId,
  });
});

const isHMACVerified = computed(() => {
  if (!isAWebWidgetInbox.value) {
    return true;
  }
  return chatMetadata.value.hmac_verified;
});

const currentContact = computed(() =>
  store.getters['contacts/getContact'](props.chat.meta.sender.id)
);

const isSnoozed = computed(
  () => currentChat.value.status === wootConstants.STATUS_TYPE.SNOOZED
);

const snoozedDisplayText = computed(() => {
  const { snoozed_until: snoozedUntil } = currentChat.value;
  if (snoozedUntil) {
    return `${t('CONVERSATION.HEADER.SNOOZED_UNTIL')} ${snoozedReopenTime(snoozedUntil)}`;
  }
  return t('CONVERSATION.HEADER.SNOOZED_UNTIL_NEXT_REPLY');
});

const inbox = computed(() => {
  const { inbox_id: inboxId } = props.chat;
  return store.getters['inboxes/getInbox'](inboxId);
});

const hasMultipleInboxes = computed(
  () => store.getters['inboxes/getInboxes'].length > 1
);

const STATUS_STYLES = {
  open: { dot: 'bg-n-teal-9', text: 'text-n-teal-11' },
  pending: { dot: 'bg-n-amber-9', text: 'text-n-amber-11' },
  resolved: { dot: 'bg-n-slate-9', text: 'text-n-slate-11' },
};

const statusStyle = computed(() => STATUS_STYLES[props.chat.status]);

const currentUser = computed(() => store.getters.getCurrentUser);
const isAssignedToMe = computed(
  () => props.chat.meta?.assignee?.id === currentUser.value.id
);
const isOpen = computed(
  () => props.chat.status === wootConstants.STATUS_TYPE.OPEN
);

const assignToMe = () => {
  store.dispatch('setCurrentChatAssignee', {
    conversationId: props.chat.id,
    assignee: currentUser.value,
    assigneeType: 'User',
  });
  store.dispatch('assignAgent', {
    conversationId: props.chat.id,
    agentId: currentUser.value.id,
  });
};

const openSnoozeModal = () => {
  emitter.emit(CMD_OPEN_COMMAND_BAR, { parent: 'snooze_conversation' });
};

const hasSlaPolicyId = computed(
  () => props.chat?.applied_sla?.id && !currentContact.value?.blocked
);

const copyConversationId = async () => {
  try {
    await copyTextToClipboard(String(props.chat.id));
    useAlert(t('CONVERSATION.HEADER.COPY_ID_SUCCESS'));
  } catch (error) {
    // error
  }
};
</script>

<template>
  <div
    ref="conversationHeader"
    class="flex flex-col gap-3 items-center justify-between flex-1 w-full min-w-0 xl:flex-row px-3 pt-3 pb-2 h-24 xl:h-12"
  >
    <div
      class="flex items-center justify-start w-full xl:w-auto max-w-full min-w-0 xl:flex-1"
    >
      <BackButton
        v-if="showBackButton"
        :back-url="backButtonUrl"
        class="me-2"
      />
      <HoverCard :open-delay="300">
        <HoverCardTrigger as-child>
          <div class="shrink-0">
            <Avatar
              :name="currentContact.name"
              :src="currentContact.thumbnail"
              :size="32"
              :status="currentContact.availability_status"
              hide-offline-status
            />
          </div>
        </HoverCardTrigger>
        <HoverCardContent align="start" class="w-72">
          <div class="flex items-center gap-3">
            <Avatar
              :name="currentContact.name"
              :src="currentContact.thumbnail"
              :size="40"
              :status="currentContact.availability_status"
              hide-offline-status
            />
            <div class="flex min-w-0 flex-col">
              <span class="truncate text-sm font-medium text-n-slate-12">
                {{ currentContact.name }}
              </span>
              <span
                v-if="currentContact.email"
                class="truncate text-xs text-n-slate-11"
              >
                {{ currentContact.email }}
              </span>
              <span
                v-if="currentContact.phone_number"
                class="truncate text-xs text-n-slate-11"
              >
                {{ currentContact.phone_number }}
              </span>
            </div>
          </div>
        </HoverCardContent>
      </HoverCard>
      <div class="flex flex-col items-start min-w-0 ms-2 overflow-hidden">
        <div class="flex flex-row items-center max-w-full gap-1 p-0 m-0">
          <span
            class="text-sm font-medium font-heading truncate leading-tight text-n-slate-12"
          >
            {{ currentContact.name }}
          </span>
          <fluent-icon
            v-if="!isHMACVerified"
            v-tooltip="$t('CONVERSATION.UNVERIFIED_SESSION')"
            size="14"
            class="text-n-amber-10 my-0 mx-0 min-w-[14px] flex-shrink-0"
            icon="warning"
          />
        </div>

        <div
          class="flex items-center gap-1 overflow-hidden text-xs conversation--header--actions text-n-slate-11 text-ellipsis whitespace-nowrap"
        >
          <button
            type="button"
            class="truncate text-label-small text-n-slate-11 hover:text-n-slate-12 !p-0 cucursor-pointer"
            @click="copyConversationId"
          >
            {{ `#${chat.id}` }}
          </button>
          <span v-if="hasMultipleInboxes">•</span>
          <InboxName v-if="hasMultipleInboxes" :inbox="inbox" class="!mx-0" />
          <span v-if="statusStyle">•</span>
          <span
            v-if="statusStyle"
            class="inline-flex items-center gap-1 font-medium"
            :class="statusStyle.text"
          >
            <span class="size-1.5 rounded-full" :class="statusStyle.dot" />
            {{ $t(`CONVERSATION.STATUS_LABEL.${chat.status.toUpperCase()}`) }}
          </span>
          <span v-if="isSnoozed">•</span>
          <span v-if="isSnoozed" class="font-medium text-n-amber-10">
            {{ snoozedDisplayText }}
          </span>
        </div>
      </div>
    </div>
    <div
      class="flex flex-row items-center justify-start xl:justify-end flex-shrink-0 gap-2 w-full xl:w-auto header-actions-wrap"
    >
      <SLACardLabel
        v-if="hasSlaPolicyId"
        :chat="chat"
        show-extended-info
        :parent-width="width"
        class="hidden md:flex"
      />
      <HeaderAssignee :chat="chat" />
      <NextButton
        v-if="!isAssignedToMe"
        :label="$t('CONVERSATION.ASSIGN_TO_ME')"
        icon="i-lucide-user-round"
        slate
        faded
        sm
        class="hidden lg:inline-flex"
        @click="assignToMe"
      />
      <NextButton
        v-if="isOpen"
        :label="$t('CONVERSATION.RESOLVE_DROPDOWN.SNOOZE_UNTIL')"
        icon="i-lucide-clock"
        slate
        faded
        sm
        class="hidden lg:inline-flex"
        @click="openSnoozeModal"
      />
      <ConversationCallButton :inbox="inbox" :chat="currentChat" />
      <MoreActions :conversation-id="currentChat.id" />
    </div>
  </div>
</template>
