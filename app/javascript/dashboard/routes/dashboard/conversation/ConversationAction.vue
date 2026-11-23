<!-- eslint-disable vue/v-slot-style -->
<script>
import { mapGetters } from 'vuex';
import { useAlert } from 'dashboard/composables';
import { useAgentsList } from 'dashboard/composables/useAgentsList';
import MultiselectDropdown from 'shared/components/ui/MultiselectDropdown.vue';
import ConversationLabels from './labels/LabelBox.vue';
import {
  CONVERSATION_PRIORITY,
  CONVERSATION_STATUS,
} from '../../../../shared/constants/messages';
import { CONVERSATION_EVENTS } from '../../../helper/AnalyticsHelper/events';
import { useTrack } from 'dashboard/composables';
import NextButton from 'dashboard/components-next/button/Button.vue';

export default {
  components: {
    MultiselectDropdown,
    ConversationLabels,
    NextButton,
  },
  props: {
    conversationId: {
      type: [Number, String],
      required: true,
    },
    layout: {
      type: String,
      default: 'rows',
    },
    showLabels: {
      type: Boolean,
      default: true,
    },
  },
  setup() {
    const { agentsList } = useAgentsList(true, { includeAgentBots: true });
    return {
      agentsList,
    };
  },
  data() {
    return {
      statusOptions: [
        CONVERSATION_STATUS.OPEN,
        CONVERSATION_STATUS.PENDING,
        CONVERSATION_STATUS.RESOLVED,
      ].map(status => ({
        id: status,
        name: this.$t(`CONVERSATION.STATUS_LABEL.${status.toUpperCase()}`),
      })),
      priorityOptions: [
        {
          id: null,
          name: this.$t('CONVERSATION.PRIORITY.OPTIONS.NONE'),
          icon: 'i-woot-priority-empty',
        },
        {
          id: CONVERSATION_PRIORITY.URGENT,
          name: this.$t('CONVERSATION.PRIORITY.OPTIONS.URGENT'),
          icon: 'i-woot-priority-urgent',
        },
        {
          id: CONVERSATION_PRIORITY.HIGH,
          name: this.$t('CONVERSATION.PRIORITY.OPTIONS.HIGH'),
          icon: 'i-woot-priority-high',
        },
        {
          id: CONVERSATION_PRIORITY.MEDIUM,
          name: this.$t('CONVERSATION.PRIORITY.OPTIONS.MEDIUM'),
          icon: 'i-woot-priority-medium',
        },
        {
          id: CONVERSATION_PRIORITY.LOW,
          name: this.$t('CONVERSATION.PRIORITY.OPTIONS.LOW'),
          icon: 'i-woot-priority-low',
        },
      ],
    };
  },
  computed: {
    ...mapGetters({
      currentChat: 'getSelectedChat',
      currentUser: 'getCurrentUser',
      teams: 'teams/getTeams',
    }),
    hasAnAssignedTeam() {
      return !!this.currentChat?.meta?.team;
    },
    teamsList() {
      if (this.hasAnAssignedTeam) {
        return [
          { id: 0, name: this.$t('TEAMS_SETTINGS.LIST.NONE') },
          ...this.teams,
        ];
      }
      return this.teams;
    },
    assignedAgent: {
      get() {
        const assignee = this.currentChat.meta.assignee;
        return (
          assignee && {
            ...assignee,
            assignee_type: this.currentChat.meta.assignee_type || 'User',
          }
        );
      },
      set(agent) {
        const agentId = agent ? agent.id : null;
        const assigneeType = agent ? agent.assignee_type || 'User' : null;
        this.$store.dispatch('setCurrentChatAssignee', {
          conversationId: this.currentChat.id,
          assignee: agent,
          assigneeType,
        });
        this.$store
          .dispatch('assignAgent', {
            conversationId: this.currentChat.id,
            agentId,
            assigneeType,
          })
          .then(() => {
            useAlert(this.$t('CONVERSATION.CHANGE_AGENT'));
          });
      },
    },
    assignedTeam: {
      get() {
        return this.currentChat.meta.team;
      },
      set(team) {
        const conversationId = this.currentChat.id;
        const teamId = team ? team.id : 0;
        this.$store.dispatch('setCurrentChatTeam', { team, conversationId });
        this.$store
          .dispatch('assignTeam', { conversationId, teamId })
          .then(() => {
            useAlert(this.$t('CONVERSATION.CHANGE_TEAM'));
          });
      },
    },
    assignedStatus() {
      return (
        this.statusOptions.find(opt => opt.id === this.currentChat.status) ||
        null
      );
    },
    assignedPriority: {
      get() {
        const selectedOption = this.priorityOptions.find(
          opt => opt.id === this.currentChat.priority
        );

        return selectedOption || this.priorityOptions[0];
      },
      set(priorityItem) {
        const conversationId = this.currentChat.id;
        const oldValue = this.currentChat?.priority;
        const priority = priorityItem.id;

        this.$store.dispatch('setCurrentChatPriority', {
          priority,
          conversationId,
        });
        this.$store
          .dispatch('assignPriority', { conversationId, priority })
          .then(() => {
            useTrack(CONVERSATION_EVENTS.CHANGE_PRIORITY, {
              oldValue,
              newValue: priority,
              from: 'Conversation Sidebar',
            });
            useAlert(
              this.$t('CONVERSATION.PRIORITY.CHANGE_PRIORITY.SUCCESSFUL', {
                priority: priorityItem.name,
                conversationId,
              })
            );
          });
      },
    },
    fieldClass() {
      return this.isGrid
        ? 'flex flex-col gap-1 min-w-0'
        : 'flex items-center justify-between gap-3';
    },
    labelClass() {
      return this.isGrid
        ? 'text-xs font-medium text-n-slate-11'
        : 'text-sm shrink-0 text-n-slate-11';
    },
    isGrid() {
      return this.layout === 'grid';
    },
    showSelfAssign() {
      if (!this.assignedAgent) {
        return true;
      }
      if (
        this.assignedAgent.id !== this.currentUser.id ||
        (this.assignedAgent.assignee_type || 'User') !== 'User'
      ) {
        return true;
      }
      return false;
    },
  },
  methods: {
    onSelfAssign() {
      const {
        account_id,
        availability_status,
        available_name,
        email,
        id,
        name,
        role,
        avatar_url,
      } = this.currentUser;
      const selfAssign = {
        account_id,
        availability_status,
        available_name,
        email,
        id,
        name,
        role,
        thumbnail: avatar_url,
      };
      this.assignedAgent = selfAssign;
    },
    onClickAssignAgent(selectedItem) {
      if (
        this.assignedAgent?.id === selectedItem.id &&
        (this.assignedAgent?.assignee_type || 'User') ===
          (selectedItem.assignee_type || 'User')
      ) {
        this.assignedAgent = null;
      } else {
        this.assignedAgent = selectedItem;
      }
    },

    onClickAssignTeam(selectedItemTeam) {
      if (this.assignedTeam && this.assignedTeam.id === selectedItemTeam.id) {
        this.assignedTeam = null;
      } else {
        this.assignedTeam = selectedItemTeam;
      }
    },

    onClickAssignStatus(selectedStatusItem) {
      if (selectedStatusItem.id === this.currentChat.status) return;
      this.$store
        .dispatch('toggleStatus', {
          conversationId: this.currentChat.id,
          status: selectedStatusItem.id,
        })
        .then(() => useAlert(this.$t('CONVERSATION.CHANGE_STATUS')));
    },

    onClickAssignPriority(selectedPriorityItem) {
      const isSamePriority =
        this.assignedPriority &&
        this.assignedPriority.id === selectedPriorityItem.id;

      this.assignedPriority = isSamePriority
        ? this.priorityOptions[0]
        : selectedPriorityItem;
    },
  },
};
</script>

<template>
  <div class="flex flex-col gap-3">
    <div class="grid gap-3" :class="isGrid ? 'grid-cols-2' : 'grid-cols-1'">
      <div :class="fieldClass">
        <span :class="labelClass">
          {{ $t('CONVERSATION_SIDEBAR.ASSIGNEE_LABEL') }}
        </span>
        <MultiselectDropdown
          class="flex-1 min-w-0"
          :options="agentsList"
          :selected-item="assignedAgent"
          :multiselector-title="$t('AGENT_MGMT.MULTI_SELECTOR.TITLE.AGENT')"
          :multiselector-placeholder="
            $t('AGENT_MGMT.MULTI_SELECTOR.PLACEHOLDER')
          "
          :no-search-result="
            $t('AGENT_MGMT.MULTI_SELECTOR.SEARCH.NO_RESULTS.AGENT')
          "
          :input-placeholder="
            $t('AGENT_MGMT.MULTI_SELECTOR.SEARCH.PLACEHOLDER.AGENT')
          "
          @select="onClickAssignAgent"
        />
      </div>
      <div :class="fieldClass">
        <span :class="labelClass">
          {{ $t('CONVERSATION_SIDEBAR.TEAM_LABEL') }}
        </span>
        <MultiselectDropdown
          class="flex-1 min-w-0"
          :options="teamsList"
          :selected-item="assignedTeam"
          show-emoji-icon
          :multiselector-title="$t('AGENT_MGMT.MULTI_SELECTOR.TITLE.TEAM')"
          :multiselector-placeholder="
            $t('AGENT_MGMT.MULTI_SELECTOR.PLACEHOLDER')
          "
          :no-search-result="
            $t('AGENT_MGMT.MULTI_SELECTOR.SEARCH.NO_RESULTS.TEAM')
          "
          :input-placeholder="
            $t('AGENT_MGMT.MULTI_SELECTOR.SEARCH.PLACEHOLDER.TEAM')
          "
          @select="onClickAssignTeam"
        />
      </div>
      <div :class="fieldClass">
        <span :class="labelClass">
          {{ $t('CONVERSATION.PRIORITY.TITLE') }}
        </span>
        <MultiselectDropdown
          class="flex-1 min-w-0"
          :options="priorityOptions"
          :selected-item="assignedPriority"
          :multiselector-title="$t('CONVERSATION.PRIORITY.TITLE')"
          :multiselector-placeholder="
            $t('CONVERSATION.PRIORITY.CHANGE_PRIORITY.SELECT_PLACEHOLDER')
          "
          :no-search-result="
            $t('CONVERSATION.PRIORITY.CHANGE_PRIORITY.NO_RESULTS')
          "
          :input-placeholder="
            $t('CONVERSATION.PRIORITY.CHANGE_PRIORITY.INPUT_PLACEHOLDER')
          "
          @select="onClickAssignPriority"
        />
      </div>
      <div :class="fieldClass">
        <span :class="labelClass">
          {{ $t('CONVERSATION_FIELDS_BAR.STATUS') }}
        </span>
        <MultiselectDropdown
          class="flex-1 min-w-0"
          :options="statusOptions"
          :selected-item="assignedStatus"
          :multiselector-title="$t('CONVERSATION_FIELDS_BAR.STATUS')"
          :multiselector-placeholder="
            $t('CONVERSATION.PRIORITY.CHANGE_PRIORITY.SELECT_PLACEHOLDER')
          "
          :no-search-result="
            $t('CONVERSATION.PRIORITY.CHANGE_PRIORITY.NO_RESULTS')
          "
          :input-placeholder="
            $t('CONVERSATION.PRIORITY.CHANGE_PRIORITY.INPUT_PLACEHOLDER')
          "
          @select="onClickAssignStatus"
        />
      </div>
    </div>
    <NextButton
      v-if="showSelfAssign"
      link
      xs
      icon="i-lucide-user-plus"
      class="!gap-1.5 self-start"
      :label="$t('CONVERSATION_SIDEBAR.SELF_ASSIGN')"
      @click="onSelfAssign"
    />
    <div v-if="showLabels" class="flex flex-col gap-1.5">
      <span class="text-sm text-n-slate-11">
        {{ $t('CONVERSATION_SIDEBAR.ACCORDION.CONVERSATION_LABELS') }}
      </span>
      <ConversationLabels :conversation-id="conversationId" />
    </div>
  </div>
</template>
