<script setup>
import { computed, onUnmounted } from 'vue';
import { useToggle } from '@vueuse/core';
import { useStore } from 'vuex';
import { useAlert } from 'dashboard/composables';
import { useI18n } from 'vue-i18n';
import { emitter } from 'shared/helpers/mitt';
import { copyTextToClipboard } from 'shared/helpers/clipboard';
import { conversationUrl, frontendURL } from 'dashboard/helper/URLHelper';
import EmailTranscriptModal from './EmailTranscriptModal.vue';
import ResolveAction from '../../buttons/ResolveAction.vue';
import ButtonV4 from 'dashboard/components-next/button/Button.vue';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from 'dashboard/components-next/ui/dropdown-menu';
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from 'dashboard/components-next/ui/tooltip';

import {
  CMD_MUTE_CONVERSATION,
  CMD_SEND_TRANSCRIPT,
  CMD_UNMUTE_CONVERSATION,
} from 'dashboard/helper/commandbar/events';

// No props needed as we're getting currentChat from the store directly
const store = useStore();
const { t } = useI18n();

const [showEmailActionsModal, toggleEmailModal] = useToggle(false);

const currentChat = computed(() => store.getters.getSelectedChat);

const mute = () => {
  store.dispatch('muteConversation', currentChat.value.id);
  useAlert(t('CONTACT_PANEL.MUTED_SUCCESS'));
};

const unmute = () => {
  store.dispatch('unmuteConversation', currentChat.value.id);
  useAlert(t('CONTACT_PANEL.UNMUTED_SUCCESS'));
};

const copyLink = async () => {
  const path = conversationUrl({
    accountId: store.getters.getCurrentAccountId,
    id: currentChat.value.id,
  });
  await copyTextToClipboard(`${window.location.origin}${frontendURL(path)}`);
  useAlert(t('CONVERSATION.HEADER.COPY_LINK_SUCCESS'));
};

emitter.on(CMD_MUTE_CONVERSATION, mute);
emitter.on(CMD_UNMUTE_CONVERSATION, unmute);
emitter.on(CMD_SEND_TRANSCRIPT, toggleEmailModal);

onUnmounted(() => {
  emitter.off(CMD_MUTE_CONVERSATION, mute);
  emitter.off(CMD_UNMUTE_CONVERSATION, unmute);
  emitter.off(CMD_SEND_TRANSCRIPT, toggleEmailModal);
});
</script>

<template>
  <div class="relative flex items-center gap-2 actions--container">
    <ResolveAction
      :conversation-id="currentChat.id"
      :status="currentChat.status"
    />
    <DropdownMenu>
      <Tooltip>
        <TooltipTrigger as-child>
          <DropdownMenuTrigger as-child>
            <ButtonV4
              size="sm"
              variant="ghost"
              color="slate"
              icon="i-lucide-more-vertical"
              class="rounded-md data-[state=open]:bg-n-alpha-2"
              :aria-label="$t('CONVERSATION.HEADER.MORE_ACTIONS')"
            />
          </DropdownMenuTrigger>
        </TooltipTrigger>
        <TooltipContent>
          {{ $t('CONVERSATION.HEADER.MORE_ACTIONS') }}
        </TooltipContent>
      </Tooltip>
      <DropdownMenuContent align="end" class="w-60">
        <DropdownMenuItem v-if="!currentChat.muted" @select="mute">
          <span class="i-lucide-volume-off size-4 shrink-0" />
          {{ $t('CONTACT_PANEL.MUTE_CONTACT') }}
        </DropdownMenuItem>
        <DropdownMenuItem v-else @select="unmute">
          <span class="i-lucide-volume-1 size-4 shrink-0" />
          {{ $t('CONTACT_PANEL.UNMUTE_CONTACT') }}
        </DropdownMenuItem>
        <DropdownMenuItem @select="toggleEmailModal">
          <span class="i-lucide-share size-4 shrink-0" />
          {{ $t('CONTACT_PANEL.SEND_TRANSCRIPT') }}
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuItem @select="copyLink">
          <span class="i-lucide-link size-4 shrink-0" />
          {{ $t('CONVERSATION.HEADER.COPY_LINK') }}
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
    <EmailTranscriptModal
      v-if="showEmailActionsModal"
      :show="showEmailActionsModal"
      :current-chat="currentChat"
      @cancel="toggleEmailModal"
    />
  </div>
</template>
