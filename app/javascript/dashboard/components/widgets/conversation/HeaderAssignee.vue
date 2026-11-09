<script setup>
import { computed, ref } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import { useAgentsList } from 'dashboard/composables/useAgentsList';
import Avatar from 'next/avatar/Avatar.vue';
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from 'dashboard/components-next/ui/popover';
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from 'dashboard/components-next/ui/tooltip';
import Command from 'dashboard/components-next/ui/command/Command.vue';
import CommandInput from 'dashboard/components-next/ui/command/CommandInput.vue';
import CommandList from 'dashboard/components-next/ui/command/CommandList.vue';
import CommandItem from 'dashboard/components-next/ui/command/CommandItem.vue';
import CommandEmpty from 'dashboard/components-next/ui/command/CommandEmpty.vue';

const props = defineProps({
  chat: { type: Object, required: true },
});

const store = useStore();
const { t } = useI18n();
const { agentsList } = useAgentsList(true, { includeAgentBots: true });

const isOpen = ref(false);
const search = ref('');

const assignee = computed(() => props.chat.meta?.assignee);
const assigneeType = computed(() => props.chat.meta?.assignee_type || 'User');

const filteredAgents = computed(() => {
  const query = search.value.trim().toLowerCase();
  return agentsList.value.filter(
    agent =>
      !query ||
      agent.name?.toLowerCase().includes(query) ||
      agent.email?.toLowerCase().includes(query)
  );
});

const agentKey = agent => `${agent.assignee_type || 'User'}-${agent.id}`;

const isSelected = agent =>
  assignee.value?.id === agent.id &&
  assigneeType.value === (agent.assignee_type || 'User');

const assign = agent => {
  const type = agent ? agent.assignee_type || 'User' : null;
  store.dispatch('setCurrentChatAssignee', {
    conversationId: props.chat.id,
    assignee: agent,
    assigneeType: type,
  });
  store
    .dispatch('assignAgent', {
      conversationId: props.chat.id,
      agentId: agent ? agent.id : null,
      assigneeType: type,
    })
    .then(() => useAlert(t('CONVERSATION.CHANGE_AGENT')));
};

const onSelect = agent => {
  // Picking the current assignee again unassigns the conversation.
  assign(isSelected(agent) ? null : agent);
  isOpen.value = false;
  search.value = '';
};
</script>

<template>
  <Popover v-model:open="isOpen">
    <Tooltip>
      <TooltipTrigger as-child>
        <PopoverTrigger as-child>
          <button
            type="button"
            class="inline-flex h-7 max-w-44 items-center gap-1.5 rounded-lg px-2 text-sm font-medium text-n-slate-12 outline-none hover:bg-n-alpha-2 focus-visible:ring-2 focus-visible:ring-ring data-[state=open]:bg-n-alpha-2"
            :aria-label="t('CONVERSATION.HEADER.ASSIGNEE.LABEL')"
          >
            <Avatar
              v-if="assignee"
              :name="assignee.name"
              :src="assignee.thumbnail"
              :size="20"
              rounded-full
            />
            <span
              v-else
              class="i-lucide-user-round-plus size-4 text-n-slate-11"
            />
            <span class="truncate" :class="{ 'text-n-slate-11': !assignee }">
              {{
                assignee
                  ? assignee.name
                  : t('CONVERSATION.HEADER.ASSIGNEE.UNASSIGNED')
              }}
            </span>
            <span
              class="i-lucide-chevron-down size-3.5 shrink-0 text-n-slate-11"
            />
          </button>
        </PopoverTrigger>
      </TooltipTrigger>
      <TooltipContent>
        {{ t('CONVERSATION.HEADER.ASSIGNEE.LABEL') }}
      </TooltipContent>
    </Tooltip>
    <PopoverContent align="end" class="w-64 p-0">
      <Command class="max-h-80 bg-transparent">
        <CommandInput
          v-model="search"
          :placeholder="t('CONVERSATION.HEADER.ASSIGNEE.SEARCH')"
        />
        <CommandList>
          <CommandEmpty v-if="!filteredAgents.length">
            {{ t('CONVERSATION.HEADER.ASSIGNEE.EMPTY') }}
          </CommandEmpty>
          <CommandItem
            v-for="agent in filteredAgents"
            :key="agentKey(agent)"
            :value="agentKey(agent)"
            @select="onSelect(agent)"
          >
            <Avatar
              :name="agent.name"
              :src="agent.thumbnail"
              :size="20"
              :status="agent.availability_status"
              rounded-full
            />
            <span class="truncate">{{ agent.name }}</span>
            <span
              v-if="isSelected(agent)"
              class="i-lucide-check ms-auto size-4 shrink-0 text-primary"
            />
          </CommandItem>
        </CommandList>
      </Command>
    </PopoverContent>
  </Popover>
</template>
