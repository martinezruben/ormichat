<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue';
import { useStore } from 'dashboard/composables/store';
import { useI18n } from 'vue-i18n';
import { useVuelidate } from '@vuelidate/core';
import { required, minLength } from '@vuelidate/validators';
import { useAlert } from 'dashboard/composables';
import {
  AVAILABLE_CUSTOM_ROLE_PERMISSIONS,
  MANAGE_ALL_CONVERSATION_PERMISSIONS,
  CONVERSATION_UNASSIGNED_PERMISSIONS,
  CONVERSATION_PARTICIPATING_PERMISSIONS,
} from 'dashboard/constants/permissions.js';
import {
  SIDEBAR_MENU_CATALOG,
  ALL_SIDEBAR_MENU_ITEM_KEYS,
} from 'dashboard/constants/sidebarMenuCatalog.js';

import Button from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  mode: {
    type: String,
    default: 'add',
    validator: value => ['add', 'edit'].includes(value),
  },
  selectedRole: {
    type: Object,
    default: () => ({}),
  },
});

const emit = defineEmits(['close']);

const store = useStore();
const { t } = useI18n();

const name = ref('');
const description = ref('');
const selectedPermissions = ref([]);
const selectedMenuItems = ref([...ALL_SIDEBAR_MENU_ITEM_KEYS]);

const nameInput = ref(null);

const addCustomRole = reactive({
  showLoading: false,
  message: '',
});

const rules = computed(() => ({
  name: { required, minLength: minLength(2) },
  description: { required },
  selectedPermissions: { required, minLength: minLength(1) },
}));

const v$ = useVuelidate(rules, { name, description, selectedPermissions });

const resetForm = () => {
  name.value = '';
  description.value = '';
  selectedPermissions.value = [];
  selectedMenuItems.value = [...ALL_SIDEBAR_MENU_ITEM_KEYS];
  v$.value.$reset();
};

const populateEditForm = () => {
  name.value = props.selectedRole.name || '';
  description.value = props.selectedRole.description || '';
  selectedPermissions.value = props.selectedRole.permissions || [];
  // Empty means "unrestricted" — reflect that as every box checked.
  const visibleMenuItems = props.selectedRole.visible_menu_items || [];
  selectedMenuItems.value = visibleMenuItems.length
    ? visibleMenuItems
    : [...ALL_SIDEBAR_MENU_ITEM_KEYS];
};

const isItemChecked = key => selectedMenuItems.value.includes(key);

// Group headers (Conversation, Reports, Settings...) have no route of their
// own — the live sidebar hides them automatically once every child is
// hidden, so their checkbox here is a pure "select/deselect all children"
// convenience; only leaf keys (a childless top-level item, or a child
// within a group) are ever stored in selectedMenuItems.
const isSectionChecked = section =>
  !!section.children?.length &&
  section.children.every(child => isItemChecked(child.key));

const isSectionIndeterminate = section => {
  if (!section.children?.length) return false;
  const checkedCount = section.children.filter(child =>
    isItemChecked(child.key)
  ).length;
  return checkedCount > 0 && checkedCount < section.children.length;
};

const toggleKey = (key, checked) => {
  if (checked) {
    if (!selectedMenuItems.value.includes(key)) {
      selectedMenuItems.value = [...selectedMenuItems.value, key];
    }
  } else {
    selectedMenuItems.value = selectedMenuItems.value.filter(k => k !== key);
  }
};

const toggleSection = (section, checked) => {
  if (section.children?.length) {
    section.children.forEach(child => toggleKey(child.key, checked));
  } else {
    toggleKey(section.key, checked);
  }
};

watch(
  selectedPermissions,
  (newValue, oldValue) => {
    // Check if manage all conversation permission is added or removed
    const hasAddedManageAllConversation =
      newValue.includes(MANAGE_ALL_CONVERSATION_PERMISSIONS) &&
      !oldValue.includes(MANAGE_ALL_CONVERSATION_PERMISSIONS);
    const hasRemovedManageAllConversation =
      oldValue.includes(MANAGE_ALL_CONVERSATION_PERMISSIONS) &&
      !newValue.includes(MANAGE_ALL_CONVERSATION_PERMISSIONS);

    if (hasAddedManageAllConversation) {
      // If manage all conversation permission is added,
      // then add unassigned and participating permissions automatically
      selectedPermissions.value = [
        ...new Set([
          ...selectedPermissions.value,
          CONVERSATION_UNASSIGNED_PERMISSIONS,
          CONVERSATION_PARTICIPATING_PERMISSIONS,
        ]),
      ];
    } else if (hasRemovedManageAllConversation) {
      // If manage all conversation permission is removed,
      // then only remove manage all conversation permission
      selectedPermissions.value = selectedPermissions.value.filter(
        p => p !== MANAGE_ALL_CONVERSATION_PERMISSIONS
      );
    }
  },
  { deep: true }
);

onMounted(() => {
  if (props.mode === 'edit') {
    populateEditForm();
  }
  // Focus the name input when mounted
  nameInput.value?.focus();
});

const getTranslationKey = base => {
  return props.mode === 'edit'
    ? `CUSTOM_ROLE.EDIT.${base}`
    : `CUSTOM_ROLE.ADD.${base}`;
};

const modalTitle = computed(() => t(getTranslationKey('TITLE')));
const modalDescription = computed(() => t(getTranslationKey('DESC')));
const submitButtonText = computed(() => t(getTranslationKey('SUBMIT')));

const handleCustomRole = async () => {
  v$.value.$touch();
  if (v$.value.$invalid) return;

  addCustomRole.showLoading = true;
  try {
    const roleData = {
      name: name.value,
      description: description.value,
      permissions: selectedPermissions.value,
      // Everything selected means unrestricted — store [] rather than the
      // full list so newly added menu items aren't silently hidden later.
      visible_menu_items:
        selectedMenuItems.value.length === ALL_SIDEBAR_MENU_ITEM_KEYS.length
          ? []
          : selectedMenuItems.value,
    };

    if (props.mode === 'edit') {
      await store.dispatch('customRole/updateCustomRole', {
        id: props.selectedRole.id,
        ...roleData,
      });
      useAlert(t('CUSTOM_ROLE.EDIT.API.SUCCESS_MESSAGE'));
    } else {
      await store.dispatch('customRole/createCustomRole', roleData);
      useAlert(t('CUSTOM_ROLE.ADD.API.SUCCESS_MESSAGE'));
    }

    resetForm();
    emit('close');
  } catch (error) {
    const errorMessage =
      error?.message || t(`CUSTOM_ROLE.FORM.API.ERROR_MESSAGE`);
    useAlert(errorMessage);
  } finally {
    addCustomRole.showLoading = false;
  }
};

const isSubmitDisabled = computed(
  () => v$.value.$invalid || addCustomRole.showLoading
);
</script>

<template>
  <div class="flex flex-col h-auto overflow-auto">
    <woot-modal-header
      :header-title="modalTitle"
      :header-content="modalDescription"
    />
    <form class="flex flex-col w-full" @submit.prevent="handleCustomRole">
      <div class="w-full">
        <label :class="{ error: v$.name.$error }">
          {{ $t('CUSTOM_ROLE.FORM.NAME.LABEL') }}
          <input
            ref="nameInput"
            v-model.trim="name"
            type="text"
            :placeholder="$t('CUSTOM_ROLE.FORM.NAME.PLACEHOLDER')"
            @blur="v$.name.$touch"
          />
        </label>
      </div>

      <div class="w-full">
        <label :class="{ error: v$.description.$error }">
          {{ $t('CUSTOM_ROLE.FORM.DESCRIPTION.LABEL') }}

          <textarea
            v-model="description"
            :rows="3"
            :placeholder="$t('CUSTOM_ROLE.FORM.DESCRIPTION.PLACEHOLDER')"
            @blur="v$.description.$touch"
          />
        </label>
      </div>

      <div class="w-full">
        <label :class="{ 'text-n-ruby-9': v$.selectedPermissions.$error }">
          {{ $t('CUSTOM_ROLE.FORM.PERMISSIONS.LABEL') }}
        </label>
        <div class="flex flex-col gap-2.5 mb-4 mt-2">
          <div
            v-for="permission in AVAILABLE_CUSTOM_ROLE_PERMISSIONS"
            :key="permission"
            class="flex items-center"
          >
            <input
              :id="permission"
              v-model="selectedPermissions"
              type="checkbox"
              :value="permission"
              name="permissions"
              class="ltr:mr-2 rtl:ml-2"
            />
            <label :for="permission" class="text-sm font-normal">
              {{ $t(`CUSTOM_ROLE.PERMISSIONS.${permission.toUpperCase()}`) }}
            </label>
          </div>
        </div>
      </div>

      <div class="w-full">
        <label>
          {{ $t('CUSTOM_ROLE.FORM.MENU_ITEMS.LABEL') }}
        </label>
        <p class="text-xs text-n-slate-11 mt-0.5 mb-2">
          {{ $t('CUSTOM_ROLE.FORM.MENU_ITEMS.DESCRIPTION') }}
        </p>
        <div
          class="flex flex-col gap-3 mb-4 mt-2 max-h-64 overflow-y-auto pr-2"
        >
          <div
            v-for="section in SIDEBAR_MENU_CATALOG"
            :key="section.key"
            class="flex flex-col gap-1.5"
          >
            <div class="flex items-center">
              <input
                :id="`menu-${section.key}`"
                type="checkbox"
                class="ltr:mr-2 rtl:ml-2"
                :checked="
                  section.children?.length
                    ? isSectionChecked(section)
                    : isItemChecked(section.key)
                "
                :indeterminate="isSectionIndeterminate(section)"
                @change="toggleSection(section, $event.target.checked)"
              />
              <label :for="`menu-${section.key}`" class="text-sm font-medium">
                {{ $t(section.labelKey) }}
              </label>
            </div>
            <div
              v-if="section.children?.length"
              class="flex flex-col gap-1.5 ltr:pl-6 rtl:pr-6"
            >
              <div
                v-for="child in section.children"
                :key="child.key"
                class="flex items-center"
              >
                <input
                  :id="`menu-${child.key}`"
                  type="checkbox"
                  class="ltr:mr-2 rtl:ml-2"
                  :checked="isItemChecked(child.key)"
                  @change="toggleKey(child.key, $event.target.checked)"
                />
                <label :for="`menu-${child.key}`" class="text-sm font-normal">
                  {{ $t(child.labelKey) }}
                </label>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="flex flex-row justify-end w-full gap-2 px-0 py-2">
        <Button
          faded
          slate
          type="reset"
          :label="$t('CUSTOM_ROLE.FORM.CANCEL_BUTTON_TEXT')"
          @click.prevent="emit('close')"
        />
        <Button
          type="submit"
          :label="submitButtonText"
          :disabled="isSubmitDisabled"
          :is-loading="addCustomRole.showLoading"
        />
      </div>
    </form>
  </div>
</template>
