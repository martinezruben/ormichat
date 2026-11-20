<script setup>
import { computed, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { getLastMessage } from 'dashboard/helper/conversationHelper';
import Avatar from 'next/avatar/Avatar.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';
import MessagePreview from './MessagePreview.vue';
import InboxName from '../InboxName.vue';
import TimeAgo from 'dashboard/components/ui/TimeAgo.vue';
import CardLabels from './conversationCardComponents/CardLabels.vue';
import CardPriorityIcon from 'dashboard/components-next/Conversation/ConversationCard/CardPriorityIcon.vue';
import UnreadBadge from 'dashboard/components-next/Conversation/ConversationCard/UnreadBadge.vue';
import SLACardLabel from './components/SLACardLabel.vue';
import VoiceCallStatus from './VoiceCallStatus.vue';
import Checkbox from 'dashboard/components-next/checkbox/Checkbox.vue';
import CardQuickActions from './CardQuickActions.vue';
import { useUISettings } from 'dashboard/composables/useUISettings';

const props = defineProps({
  chat: { type: Object, required: true },
  currentContact: { type: Object, required: true },
  assignee: { type: Object, default: () => ({}) },
  inbox: { type: Object, default: () => ({}) },
  selected: { type: Boolean, default: false },
  isActiveChat: { type: Boolean, default: false },
  showAssignee: { type: Boolean, default: false },
  showInboxName: { type: Boolean, default: false },
  hideThumbnail: { type: Boolean, default: false },
  compact: { type: Boolean, default: false },
  showQuickActions: { type: Boolean, default: false },
  isAssignedToMe: { type: Boolean, default: false },
});

const emit = defineEmits([
  'click',
  'contextmenu',
  'selectConversation',
  'deSelectConversation',
  'resolve',
  'reopen',
  'assignToMe',
]);

const { t } = useI18n();
const hovered = ref(false);

const STATUS_CLASSES = {
  open: 'bg-n-teal-3 text-n-teal-11',
  pending: 'bg-n-amber-3 text-n-amber-11',
  resolved: 'bg-n-slate-3 text-n-slate-11',
  snoozed: 'bg-n-iris-3 text-n-iris-11',
};
const statusClass = computed(
  () => STATUS_CLASSES[props.chat.status] || STATUS_CLASSES.open
);
const statusLabel = computed(() =>
  t(`CHAT_LIST.CHAT_STATUS_FILTER_ITEMS.${props.chat.status}.TEXT`)
);

const unreadCount = computed(() => props.chat.unread_count);
const hasUnread = computed(() => unreadCount.value > 0);
const lastMessageInChat = computed(() => getLastMessage(props.chat));

const voiceCallData = computed(() => {
  const last = lastMessageInChat.value;
  if (last?.content_type !== 'voice_call' || !last.call) {
    return { status: null, direction: null };
  }
  return {
    status: last.call.status,
    direction: last.call.direction === 'outgoing' ? 'outbound' : 'inbound',
  };
});

const isAgentBotAssignee = computed(
  () => props.chat?.meta?.assignee_type === 'AgentBot'
);

const hasSlaPolicyId = computed(
  () => props.chat?.applied_sla?.id && !props.currentContact?.blocked
);

const { uiSettings } = useUISettings();
const isCompactList = computed(
  () => !!uiSettings.value.conversation_list_compact
);

const showLabelsSection = computed(() => {
  if (isCompactList.value) return false;
  return props.chat.labels?.length > 0 || hasSlaPolicyId.value;
});

const messagePreviewClass = computed(() => {
  return [
    hasUnread.value ? 'font-medium text-n-slate-12' : 'text-n-slate-11',
    !props.compact && hasUnread.value ? 'ltr:pr-4 rtl:pl-4' : '',
    props.compact && hasUnread.value ? 'ltr:pr-6 rtl:pl-6' : '',
  ];
});

const onThumbnailHover = () => {
  hovered.value = !props.hideThumbnail;
};

const onThumbnailLeave = () => {
  hovered.value = false;
};

const onSelectConversation = checked => {
  if (checked) {
    emit('selectConversation', props.chat.id, props.inbox.id);
  } else {
    emit('deSelectConversation', props.chat.id, props.inbox.id);
  }
};

const selectedModel = computed({
  get: () => props.selected,
  set: value => onSelectConversation(value),
});

watch(
  () => props.chat.id,
  () => {
    hovered.value = false;
  }
);
</script>

<template>
  <div
    class="relative flex items-start flex-grow-0 flex-shrink-0 gap-3 mb-0.5 w-auto max-w-full cursor-pointer conversation rounded-[0.875rem] hover:bg-n-slate-2 group"
    :class="{
      'active animate-card-select !bg-n-blue-3': isActiveChat,
      'selected !bg-n-slate-3': selected,
      'px-2 py-2': compact,
      'px-3 py-3': !compact,
    }"
    @click="$emit('click', $event)"
    @contextmenu="$emit('contextmenu', $event)"
  >
    <div
      class="relative"
      @mouseenter="onThumbnailHover"
      @mouseleave="onThumbnailLeave"
    >
      <Avatar
        v-if="!hideThumbnail"
        :name="currentContact.name"
        :src="currentContact.thumbnail"
        :size="42"
        :status="currentContact.availability_status"
        hide-offline-status
      >
        <template #overlay="{ size }">
          <label
            v-if="hovered || selected"
            class="flex items-center justify-center rounded-full cursor-pointer absolute inset-0 z-10 backdrop-blur-[2px]"
            :style="{ width: `${size}px`, height: `${size}px` }"
            @click.stop
          >
            <Checkbox v-model="selectedModel" />
          </label>
        </template>
      </Avatar>
    </div>
    <CardQuickActions
      v-if="showQuickActions"
      :is-resolved="chat.status === 'resolved'"
      :is-assigned-to-me="isAssignedToMe"
      @resolve="$emit('resolve')"
      @reopen="$emit('reopen')"
      @assign-to-me="$emit('assignToMe')"
    />
    <div class="flex-1 min-w-0 border-line">
      <div class="flex gap-2 items-center min-w-0">
        <h4
          class="flex-1 m-0 min-w-0 text-sm capitalize truncate conversation--user text-n-slate-12"
          :class="hasUnread ? 'font-semibold' : 'font-medium'"
        >
          {{ currentContact.name }}
        </h4>
        <CardPriorityIcon
          :priority="chat.priority"
          class="flex-shrink-0 !size-3.5"
        />
        <span
          class="flex-shrink-0 text-xs font-normal leading-4 text-n-slate-11"
          :class="{ '!text-n-blue-11 !font-semibold': hasUnread }"
        >
          <TimeAgo
            :last-activity-timestamp="chat.timestamp"
            :created-at-timestamp="chat.created_at"
            :conversation-id="chat.id"
          />
        </span>
      </div>
      <div v-if="!isCompactList" class="flex gap-2 items-center mt-0.5 min-w-0">
        <VoiceCallStatus
          v-if="voiceCallData.status"
          key="voice-status-row"
          :status="voiceCallData.status"
          :direction="voiceCallData.direction"
          :message-preview-class="messagePreviewClass"
        />
        <MessagePreview
          v-else-if="lastMessageInChat"
          key="message-preview"
          :message="lastMessageInChat"
          class="flex-1 min-w-0 h-5 text-[0.8125rem] leading-5 !m-0"
          :class="messagePreviewClass"
        />
        <p
          v-else
          key="no-messages"
          class="overflow-hidden flex-1 m-0 min-w-0 h-5 text-[0.8125rem] leading-5 whitespace-nowrap text-n-slate-11 text-ellipsis"
          :class="messagePreviewClass"
        >
          <fluent-icon
            size="16"
            class="-mt-0.5 align-middle inline-block text-n-slate-10"
            icon="info"
          />
          <span class="mx-0.5">
            {{ $t(`CHAT_LIST.NO_MESSAGES`) }}
          </span>
        </p>
        <UnreadBadge v-if="hasUnread" :count="unreadCount" class="flex-none" />
      </div>
      <div
        v-if="!isCompactList"
        class="flex flex-wrap gap-1.5 items-center mt-1.5 min-w-0"
      >
        <InboxName
          v-if="showInboxName"
          :inbox="inbox"
          class="px-1.5 h-[1.125rem] rounded-full bg-n-slate-3 !text-xs max-w-32"
        />
        <span
          class="inline-flex gap-1.5 items-center px-2 h-5 text-xs font-medium rounded-full"
          :class="statusClass"
        >
          <span class="rounded-full size-1.5 bg-current" />
          {{ statusLabel }}
        </span>
        <span
          v-if="showAssignee && assignee.name"
          class="inline-flex gap-1 items-center text-xs font-medium truncate text-n-slate-11"
        >
          <Icon
            :icon="isAgentBotAssignee ? 'i-lucide-bot' : 'i-lucide-user-round'"
            class="flex-shrink-0 size-3"
          />
          <span class="truncate">{{ assignee.name }}</span>
        </span>
      </div>
      <CardLabels
        v-if="showLabelsSection"
        :conversation-labels="chat.labels"
        class="mx-0 mt-1.5 mb-0"
      >
        <template v-if="hasSlaPolicyId" #before>
          <SLACardLabel :chat="chat" class="ltr:mr-1 rtl:ml-1" />
        </template>
      </CardLabels>
    </div>
  </div>
</template>
