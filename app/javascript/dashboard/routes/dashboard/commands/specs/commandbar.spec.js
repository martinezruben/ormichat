import { ref } from 'vue';
import { flushPromises, mount } from '@vue/test-utils';
import { emitter } from 'shared/helpers/mitt';
import {
  CMD_OPEN_COMMAND_BAR,
  CMD_SNOOZE_CONVERSATION,
} from 'dashboard/helper/commandbar/events';
import { GENERAL_EVENTS } from 'dashboard/helper/AnalyticsHelper/events';
import CommandBar from '../commandbar.vue';

vi.mock('../CommandPalette.vue', async () => {
  const { defineComponent, h } = await import('vue');
  return {
    /* eslint-disable vue/no-unused-properties, vue/require-default-prop, vue/no-unused-emit-declarations */
    default: defineComponent({
      name: 'CommandPalette',
      props: { actions: Array, placeholder: String },
      emits: ['change', 'selected', 'closed'],
      setup(_, { expose }) {
        expose({ open: vi.fn(), close: vi.fn() });
        return () => h('div');
      },
    }),
    /* eslint-enable vue/no-unused-properties, vue/require-default-prop, vue/no-unused-emit-declarations */
  };
});

vi.mock('dashboard/composables/emitter', async () => {
  const { onMounted, onBeforeUnmount } = await import('vue');
  const { emitter: bus } = await import('shared/helpers/mitt');
  return {
    useEmitter: (name, callback) => {
      onMounted(() => bus.on(name, callback));
      onBeforeUnmount(() => bus.off(name, callback));
    },
  };
});

const dispatch = vi.fn();
const track = vi.fn();

vi.mock('dashboard/composables/store', () => ({
  useStore: () => ({ dispatch }),
}));

vi.mock('dashboard/composables', () => ({
  useTrack: (...args) => track(...args),
}));

const hotKeySources = {
  goToAppearanceHotKeys: [{ id: 'appearance' }],
  inboxHotKeys: [{ id: 'inbox' }],
  goToCommandHotKeys: [{ id: 'goto' }],
  bulkActionsHotKeys: [
    { id: 'bulk' },
    { id: 'until_tomorrow', parent: 'bulk_action_snooze_conversation' },
  ],
  conversationHotKeys: [
    { id: 'conversation' },
    { id: 'until_tomorrow', parent: 'snooze_conversation' },
    { id: 'until_tomorrow', parent: 'snooze_notification' },
    { id: 'until_tomorrow', parent: 'other_menu' },
  ],
  macroHotKeys: [{ id: 'execute_a_macro' }],
};

const pendingAttributes = ref(null);

vi.mock('dashboard/composables/commands/useAppearanceHotKeys', () => ({
  useAppearanceHotKeys: () => ({
    goToAppearanceHotKeys: ref(hotKeySources.goToAppearanceHotKeys),
  }),
}));

vi.mock('dashboard/composables/commands/useInboxHotKeys', () => ({
  useInboxHotKeys: () => ({ inboxHotKeys: ref(hotKeySources.inboxHotKeys) }),
}));

vi.mock('dashboard/composables/commands/useGoToCommandHotKeys', () => ({
  useGoToCommandHotKeys: paywalled => ({
    goToCommandHotKeys: ref(
      paywalled?.value
        ? [{ id: 'goto_billing' }]
        : hotKeySources.goToCommandHotKeys
    ),
  }),
}));

vi.mock('dashboard/composables/commands/useBulkActionsHotKeys', () => ({
  useBulkActionsHotKeys: () => ({
    bulkActionsHotKeys: ref(hotKeySources.bulkActionsHotKeys),
  }),
}));

vi.mock('dashboard/composables/commands/useConversationHotKeys', () => ({
  useConversationHotKeys: () => ({
    conversationHotKeys: ref(hotKeySources.conversationHotKeys),
  }),
}));

vi.mock('dashboard/composables/commands/useMacroHotKeys', () => ({
  useMacroHotKeys: () => ({
    macroHotKeys: ref(hotKeySources.macroHotKeys),
    pendingAttributes,
    submitPendingAttributes: vi.fn(),
    dismissPendingAttributes: vi.fn(),
  }),
}));

const suggestion = {
  label: 'tomorrow',
  formattedDate: 'Feb 3, 9:00 AM',
  resolve: () => 'resolved-date',
};

vi.mock('dashboard/helper/snoozeHelpers', () => ({
  generateSnoozeSuggestions: vi.fn(search => (search ? [suggestion] : [])),
}));

describe('commandbar', () => {
  let wrapper;
  let palette;

  const mountCommandBar = async (props = {}) => {
    wrapper = mount(CommandBar, {
      props,
      global: { stubs: { ConversationResolveAttributesModal: true } },
    });
    await flushPromises();
    palette = wrapper.findComponent({ name: 'CommandPalette' });
    return wrapper;
  };

  const paletteActions = () => palette.props('actions');
  const commandIds = () => paletteActions().map(action => action.id);
  const placeholder = () => palette.props('placeholder');

  const presetSnoozeParents = () =>
    paletteActions()
      .filter(action => action.id === 'until_tomorrow')
      .map(action => action.parent)
      .sort();

  const emitChange = async (search, actions = []) => {
    palette.vm.$emit('change', { search, actions });
    await flushPromises();
  };

  const emitSelected = async action => {
    palette.vm.$emit('selected', action);
    await flushPromises();
  };

  const emitClosed = async () => {
    palette.vm.$emit('closed');
    await flushPromises();
  };

  beforeEach(() => {
    dispatch.mockClear();
    track.mockClear();
  });

  afterEach(() => {
    wrapper?.unmount();
  });

  describe('command data', () => {
    it('hands every hotkey source to the command palette on mount', async () => {
      await mountCommandBar();

      expect(commandIds()).toEqual(
        expect.arrayContaining([
          'appearance',
          'inbox',
          'goto',
          'bulk',
          'conversation',
          'execute_a_macro',
        ])
      );
    });

    it('keeps preset snooze options while there are no dynamic suggestions', async () => {
      await mountCommandBar();

      expect(presetSnoozeParents()).toEqual([
        'bulk_action_snooze_conversation',
        'other_menu',
        'snooze_conversation',
        'snooze_notification',
      ]);
    });
  });

  describe('when the account is paywalled', () => {
    it('offers only appearance and go-to commands', async () => {
      await mountCommandBar({ isPaywalled: true });

      expect(commandIds()).toEqual(['appearance', 'goto_billing']);
    });

    it('drops inbox, bulk action and conversation commands', async () => {
      await mountCommandBar({ isPaywalled: true });

      expect(commandIds()).not.toContain('inbox');
      expect(commandIds()).not.toContain('bulk');
      expect(commandIds()).not.toContain('conversation');
    });

    it('passes the paywalled state through to the go-to commands', async () => {
      await mountCommandBar({ isPaywalled: true });

      expect(commandIds()).toContain('goto_billing');
      expect(commandIds()).not.toContain('goto');
    });
  });

  describe('placeholder', () => {
    it('asks what the user is searching for by default', async () => {
      await mountCommandBar();

      expect(placeholder()).toBe('COMMAND_BAR.SEARCH_PLACEHOLDER');
    });

    it('switches to the snooze prompt inside a snooze menu', async () => {
      await mountCommandBar();

      emitter.emit(CMD_OPEN_COMMAND_BAR, { parent: 'snooze_conversation' });
      await flushPromises();

      expect(placeholder()).toBe('COMMAND_BAR.SNOOZE_PLACEHOLDER');
    });
  });

  describe('dynamic snooze suggestions', () => {
    const enterSnoozeMenu = () =>
      emitChange('', [{ id: 'until_tomorrow', parent: 'snooze_conversation' }]);

    it('builds a suggestion from the search inside a snooze menu', async () => {
      await mountCommandBar();
      await enterSnoozeMenu();
      await emitChange('tomorrow');

      expect(commandIds()).toContain('dynamic_snooze_0');
    });

    it('hides the preset snooze options once a suggestion exists', async () => {
      await mountCommandBar();
      await enterSnoozeMenu();
      await emitChange('tomorrow');

      expect(presetSnoozeParents()).toEqual(['other_menu']);
      expect(commandIds()).toContain('conversation');
    });

    it('ignores the search outside a snooze menu', async () => {
      await mountCommandBar();
      await emitChange('tomorrow', [{ id: 'goto', parent: null }]);

      expect(commandIds()).not.toContain('dynamic_snooze_0');
    });

    it('clears the suggestions when the search is emptied', async () => {
      await mountCommandBar();
      await enterSnoozeMenu();
      await emitChange('tomorrow');
      await emitChange('');

      expect(commandIds()).not.toContain('dynamic_snooze_0');
      expect(commandIds()).toContain('until_tomorrow');
    });

    it('leaves the snooze menu when actions span several parents', async () => {
      await mountCommandBar();
      await enterSnoozeMenu();
      await emitChange('tomorrow', [
        { id: 'until_tomorrow', parent: 'snooze_conversation' },
        { id: 'bulk', parent: 'bulk_action_snooze_conversation' },
      ]);

      expect(commandIds()).not.toContain('dynamic_snooze_0');
    });

    it('emits the resolved date when a suggestion is picked', async () => {
      const onSnooze = vi.fn();
      emitter.on(CMD_SNOOZE_CONVERSATION, onSnooze);

      await mountCommandBar();
      await enterSnoozeMenu();
      await emitChange('tomorrow');
      paletteActions()
        .find(action => action.id === 'dynamic_snooze_0')
        .handler();

      expect(onSnooze).toHaveBeenCalledWith('resolved-date');
      emitter.off(CMD_SNOOZE_CONVERSATION, onSnooze);
    });

    it('drops the suggestions when the bar closes', async () => {
      await mountCommandBar();
      await enterSnoozeMenu();
      await emitChange('tomorrow');
      await emitClosed();

      expect(commandIds()).not.toContain('dynamic_snooze_0');
      expect(placeholder()).toBe('COMMAND_BAR.SEARCH_PLACEHOLDER');
    });
  });

  describe('selecting a command', () => {
    it('tracks the selection', async () => {
      await mountCommandBar();
      await emitSelected({
        id: 'goto',
        title: 'Go to inbox',
        section: 'General',
      });

      expect(track).toHaveBeenCalledWith(GENERAL_EVENTS.COMMAND_BAR, {
        section: 'General',
        action: 'Go to inbox',
      });
    });

    it('enters a submenu when the command has children', async () => {
      await mountCommandBar();
      await emitSelected({
        id: 'snooze_conversation',
        children: ['until_tomorrow'],
      });

      expect(placeholder()).toBe('COMMAND_BAR.SNOOZE_PLACEHOLDER');
    });
  });

  describe('closing the bar', () => {
    it('clears the context menu conversation', async () => {
      await mountCommandBar();
      await emitClosed();

      expect(dispatch).toHaveBeenCalledWith('setContextMenuChatId', null);
    });

    it('keeps the context menu conversation for a custom snooze', async () => {
      await mountCommandBar();
      await emitSelected({ id: 'until_custom_time' });
      await emitClosed();

      expect(dispatch).not.toHaveBeenCalled();
    });
  });
});
