import { useConversationLabels } from '../useConversationLabels';
import { useStore, useStoreGetters } from 'dashboard/composables/store';

vi.mock('dashboard/composables/store');

describe('useConversationLabels', () => {
  let store;
  let getters;

  beforeEach(() => {
    store = {
      getters: {
        'conversationLabels/getConversationLabels': vi.fn(),
      },
      dispatch: vi.fn(),
    };
    getters = {
      getSelectedChat: { value: { id: 1 } },
      'labels/getLabels': {
        value: [
          { id: 1, title: 'Label 1', selectable: true },
          { id: 2, title: 'Label 2', selectable: true },
          { id: 3, title: 'Label 3', selectable: true },
          { id: 4, title: 'Automation', selectable: false },
        ],
      },
    };

    useStore.mockReturnValue(store);
    useStoreGetters.mockReturnValue(getters);
  });

  it('should return the correct computed properties', () => {
    store.getters['conversationLabels/getConversationLabels'].mockReturnValue([
      'Label 1',
      'Label 2',
    ]);
    const { accountLabels, savedLabels, activeLabels, inactiveLabels } =
      useConversationLabels();

    expect(accountLabels.value).toEqual(getters['labels/getLabels'].value);
    expect(savedLabels.value).toEqual(['Label 1', 'Label 2']);
    expect(activeLabels.value).toEqual([
      { id: 1, title: 'Label 1', selectable: true },
      { id: 2, title: 'Label 2', selectable: true },
    ]);
    expect(inactiveLabels.value).toEqual([
      { id: 3, title: 'Label 3', selectable: true },
    ]);
  });

  it('should update labels correctly', async () => {
    const { onUpdateLabels } = useConversationLabels();
    await onUpdateLabels(['Label 1', 'Label 3']);

    expect(store.dispatch).toHaveBeenCalledWith('conversationLabels/update', {
      conversationId: 1,
      labels: ['Label 1', 'Label 3'],
    });
  });

  it('should add a label to the conversation', () => {
    store.getters['conversationLabels/getConversationLabels'].mockReturnValue([
      'Label 1',
    ]);
    const { addLabelToConversation } = useConversationLabels();

    addLabelToConversation({ title: 'Label 2', selectable: true });

    expect(store.dispatch).toHaveBeenCalledWith('conversationLabels/update', {
      conversationId: 1,
      labels: ['Label 1', 'Label 2'],
    });
  });

  it('should remove a label from the conversation', () => {
    store.getters['conversationLabels/getConversationLabels'].mockReturnValue([
      'Label 1',
      'Label 2',
    ]);
    const { removeLabelFromConversation } = useConversationLabels();

    removeLabelFromConversation('Label 2');

    expect(store.dispatch).toHaveBeenCalledWith('conversationLabels/update', {
      conversationId: 1,
      labels: ['Label 1'],
    });
  });
});
