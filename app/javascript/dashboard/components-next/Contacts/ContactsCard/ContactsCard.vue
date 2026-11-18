<script setup>
import { ref, computed, watch } from 'vue';
import { useI18n } from 'vue-i18n';

import ContactsForm from 'dashboard/components-next/Contacts/ContactsForm/ContactsForm.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import Avatar from 'dashboard/components-next/avatar/Avatar.vue';
import Flag from 'dashboard/components-next/flag/Flag.vue';
import ContactDeleteSection from 'dashboard/components-next/Contacts/ContactsCard/ContactDeleteSection.vue';
import Checkbox from 'dashboard/components-next/checkbox/Checkbox.vue';
import countries from 'shared/constants/countries';

const props = defineProps({
  id: { type: Number, required: true },
  name: { type: String, default: '' },
  email: { type: String, default: '' },
  companyId: { type: [Number, String], default: '' },
  additionalAttributes: { type: Object, default: () => ({}) },
  phoneNumber: { type: String, default: '' },
  thumbnail: { type: String, default: '' },
  availabilityStatus: { type: String, default: null },
  isExpanded: { type: Boolean, default: false },
  isUpdating: { type: Boolean, default: false },
  selectable: { type: Boolean, default: false },
  isSelected: { type: Boolean, default: false },
});

const emit = defineEmits([
  'toggle',
  'updateContact',
  'showContact',
  'select',
  'avatarHover',
]);

const { t } = useI18n();

const contactsFormRef = ref(null);
const editDialogRef = ref(null);

const getInitialContactData = () => ({
  id: props.id,
  name: props.name,
  email: props.email,
  companyId: props.companyId,
  phoneNumber: props.phoneNumber,
  additionalAttributes: props.additionalAttributes,
});

const contactData = ref(getInitialContactData());

const isFormInvalid = computed(() => contactsFormRef.value?.isFormInvalid);

const countriesMap = computed(() => {
  return countries.reduce((acc, country) => {
    acc[country.id] = country;
    return acc;
  }, {});
});

const countryDetails = computed(() => {
  const attributes = props.additionalAttributes || {};
  const { country, countryCode, city } = attributes;

  if (!country && !countryCode) return null;

  const activeCountry =
    countriesMap.value[country] || countriesMap.value[countryCode];

  if (!activeCountry) return null;

  return {
    countryCode: activeCountry.id,
    city: city ? `${city},` : null,
    name: activeCountry.name,
  };
});

const formattedLocation = computed(() => {
  if (!countryDetails.value) return '';

  return [countryDetails.value.city, countryDetails.value.name]
    .filter(Boolean)
    .join(' ');
});

const handleFormUpdate = updatedData => {
  Object.assign(contactData.value, updatedData);
};

const handleUpdateContact = () => {
  emit('updateContact', contactData.value);
};

const onClickExpand = () => {
  emit('toggle');
  contactData.value = getInitialContactData();
};

watch(
  () => props.isExpanded,
  isExpanded =>
    isExpanded ? editDialogRef.value?.open() : editDialogRef.value?.close()
);

const onDialogClose = () => {
  if (props.isExpanded) emit('toggle');
};

const onClickViewDetails = () => emit('showContact', props.id);

const toggleSelect = checked => {
  emit('select', checked);
};

const handleAvatarHover = isHovered => {
  emit('avatarHover', isHovered);
};
</script>

<template>
  <div
    class="grid grid-cols-[minmax(0,1fr)_auto] md:grid-cols-[minmax(0,2fr)_minmax(0,1.2fr)_minmax(0,1.4fr)_minmax(0,1fr)_4.5rem] gap-4 items-center px-5 py-3 transition-colors hover:bg-n-slate-2"
    :class="{ 'bg-n-blue-3/50': isSelected }"
  >
    <div class="flex gap-3 items-center min-w-0">
      <div
        class="relative"
        @mouseenter="handleAvatarHover(true)"
        @mouseleave="handleAvatarHover(false)"
      >
        <Avatar
          :name="name"
          :src="thumbnail"
          :size="36"
          :status="availabilityStatus"
          hide-offline-status
        >
          <template v-if="selectable" #overlay="{ size }">
            <label
              class="flex items-center justify-center rounded-full cursor-pointer absolute inset-0 z-10 backdrop-blur-[2px] border border-n-weak"
              :style="{ width: `${size}px`, height: `${size}px` }"
              @click.stop
            >
              <Checkbox
                :model-value="isSelected"
                @change="event => toggleSelect(event.target.checked)"
              />
            </label>
          </template>
        </Avatar>
      </div>
      <div class="min-w-0">
        <button
          type="button"
          class="block max-w-full text-sm font-semibold text-start truncate text-n-slate-12 hover:underline"
          @click="onClickViewDetails"
        >
          {{ name }}
        </button>
        <div
          v-if="email"
          class="text-[0.8125rem] truncate text-n-slate-11"
          :title="email"
        >
          {{ email }}
        </div>
      </div>
    </div>
    <div
      class="hidden md:block text-[0.8125rem] tabular-nums truncate text-n-slate-12/80"
    >
      {{ phoneNumber }}
    </div>
    <div
      class="hidden md:flex gap-1.5 items-center min-w-0 text-[0.8125rem] text-n-slate-12/80"
    >
      <template v-if="countryDetails">
        <Flag :country="countryDetails.countryCode" class="size-3.5 shrink-0" />
        <span class="truncate">{{ formattedLocation }}</span>
      </template>
    </div>
    <div class="hidden min-w-0 md:block">
      <span
        v-if="additionalAttributes?.companyName"
        class="inline-flex items-center px-2 max-w-full h-[1.375rem] text-xs font-medium truncate rounded-md border bg-n-blue-3 border-n-blue-6 text-n-blue-11"
      >
        {{ additionalAttributes.companyName }}
      </span>
    </div>
    <div class="flex gap-0.5 justify-end">
      <Button
        v-tooltip.top="t('CONTACTS_LAYOUT.CARD.VIEW_DETAILS')"
        icon="i-lucide-arrow-up-right"
        variant="ghost"
        color="slate"
        size="sm"
        @click="onClickViewDetails"
      />
      <Button
        v-tooltip.top="t('CONTACTS_LAYOUT.CARD.EDIT_DETAILS_FORM.TITLE')"
        icon="i-lucide-pen-line"
        variant="ghost"
        color="slate"
        size="sm"
        @click="onClickExpand"
      />
    </div>
    <Dialog
      ref="editDialogRef"
      width="3xl"
      :title="t('CONTACTS_LAYOUT.CARD.EDIT_DETAILS_FORM.TITLE')"
      :description="t('CONTACTS_LAYOUT.CARD.EDIT_DETAILS_FORM.DESCRIPTION')"
      :confirm-button-label="
        t('CONTACTS_LAYOUT.CARD.EDIT_DETAILS_FORM.UPDATE_BUTTON')
      "
      :is-loading="isUpdating"
      :disable-confirm-button="isUpdating || isFormInvalid"
      @confirm="handleUpdateContact"
      @close="onDialogClose"
    >
      <ContactsForm
        v-if="isExpanded"
        ref="contactsFormRef"
        :contact-data="contactData"
        @update="handleFormUpdate"
      />
      <ContactDeleteSection
        v-if="isExpanded"
        :selected-contact="{ id: props.id, name: props.name }"
      />
    </Dialog>
  </div>
</template>
