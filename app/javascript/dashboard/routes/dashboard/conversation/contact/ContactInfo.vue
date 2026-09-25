<script>
import { mapGetters } from 'vuex';
import { useAlert } from 'dashboard/composables';
import {
  DuplicateContactException,
  ExceptionWithMessage,
} from 'shared/helpers/CustomErrors';
import { dynamicTime } from 'shared/helpers/timeHelper';
import { useAdmin } from 'dashboard/composables/useAdmin';
import ContactInfoRow from './ContactInfoRow.vue';
import Avatar from 'next/avatar/Avatar.vue';
import SocialIcons from './SocialIcons.vue';
import EditContact from './EditContact.vue';
import ContactMergeModal from 'dashboard/modules/contact/ContactMergeModal.vue';
import ContactDeleteModal from 'dashboard/modules/contact/ContactDeleteModal.vue';
import ComposeConversation from 'dashboard/components-next/NewConversation/ComposeConversation.vue';
import NextButton from 'dashboard/components-next/button/Button.vue';
import VoiceCallButton from 'dashboard/components-next/Contacts/VoiceCallButton.vue';
import InlineInput from 'dashboard/components-next/inline-input/InlineInput.vue';
import ImagePreviewDialog from 'dashboard/components-next/dialog/Dialog.vue';
import { buildMapsUrl } from 'shared/helpers/locationHelper';
import {
  getFileAttributeURL,
  isImageFileURL,
  isPdfFileURL,
  isValidURL,
} from 'dashboard/helper/URLHelper';

export default {
  components: {
    NextButton,
    ContactInfoRow,
    EditContact,
    Avatar,
    ComposeConversation,
    SocialIcons,
    ContactMergeModal,
    ContactDeleteModal,
    VoiceCallButton,
    InlineInput,
    ImagePreviewDialog,
  },
  props: {
    contact: {
      type: Object,
      default: () => ({}),
    },
    showAvatar: {
      type: Boolean,
      default: true,
    },
  },
  emits: ['panelClose'],
  setup() {
    const { isAdmin } = useAdmin();
    return {
      isAdmin,
    };
  },
  data() {
    return {
      showEditModal: false,
      isEditingName: false,
      editName: '',
      previewImageSrc: '',
      previewImageAlt: '',
    };
  },
  computed: {
    ...mapGetters({
      uiFlags: 'contacts/getUIFlags',
      currentChat: 'getSelectedChat',
      getAttributesByModel: 'attributes/getAttributesByModel',
    }),
    loadedCustomAttributes() {
      const values = this.contact.custom_attributes || {};
      return this.getAttributesByModel('contact_attribute')
        .map(attribute => ({
          key: attribute.attribute_key,
          label: attribute.attribute_display_name,
          type: attribute.attribute_display_type,
          value: values[attribute.attribute_key],
        }))
        .filter(({ type, value }) => {
          if (type === 'file') return !!getFileAttributeURL(value);
          return value !== undefined && value !== null && value !== '';
        })
        .map(attribute => ({
          ...attribute,
          fileURL:
            attribute.type === 'file'
              ? getFileAttributeURL(attribute.value)
              : '',
          linkURL:
            attribute.type === 'link' && isValidURL(attribute.value)
              ? attribute.value
              : '',
          displayValue: this.formatAttributeValue(attribute),
        }));
    },
    contactProfileLink() {
      return `/app/accounts/${this.$route.params.accountId}/contacts/${this.contact.id}`;
    },
    additionalAttributes() {
      return this.contact.additional_attributes || {};
    },
    countryFlagHtml() {
      const { country_code: countryCode } = this.additionalAttributes;
      if (!countryCode) return '';
      const code = countryCode.toLowerCase();
      return `<span class="fi fi-${code} size-3.5"></span>`;
    },
    rawLocation() {
      return (this.additionalAttributes.location || '').trim();
    },
    googleMapsUrl() {
      return buildMapsUrl(this.rawLocation);
    },
    locationLabel() {
      const { city, country } = this.additionalAttributes;
      const cityAndCountry = [city, country].filter(Boolean).join(', ');
      if (cityAndCountry) return cityAndCountry;
      if (this.googleMapsUrl) return this.$t('CONTACT_PANEL.VIEW_ON_MAPS');
      return this.rawLocation;
    },
    socialProfiles() {
      const {
        social_profiles: socialProfiles,
        screen_name: twitterScreenName,
        social_telegram_user_name: telegramUsername,
      } = this.additionalAttributes;

      const telegram = socialProfiles?.telegram || telegramUsername || '';
      const twitter = socialProfiles?.twitter || twitterScreenName || '';

      return {
        ...(socialProfiles || {}),
        twitter,
        telegram,
      };
    },
  },
  watch: {
    'contact.id': {
      handler(id) {
        this.$store.dispatch('contacts/fetchContactableInbox', id);
      },
      immediate: true,
    },
  },
  methods: {
    dynamicTime,
    toggleEditModal() {
      this.showEditModal = !this.showEditModal;
    },
    formatAttributeValue({ type, value }) {
      if (type === 'date') return new Date(value).toLocaleDateString();
      if (type === 'checkbox') {
        return value === true || value === 'true'
          ? this.$t('CHOICE_TOGGLE.YES')
          : this.$t('CHOICE_TOGGLE.NO');
      }
      return String(value);
    },
    isImageAttribute(attribute) {
      return !!attribute.fileURL && isImageFileURL(attribute.fileURL);
    },
    isPdfAttribute(attribute) {
      return !!attribute.fileURL && isPdfFileURL(attribute.fileURL);
    },
    openAttributeImagePreview(attribute) {
      this.previewImageSrc = attribute.fileURL;
      this.previewImageAlt = attribute.label;
      this.$refs.attributeImageDialog.open();
    },
    startEditingName() {
      this.editName = this.contact.name || '';
      this.isEditingName = true;
      this.$nextTick(() => {
        this.$refs.nameInput?.focus();
      });
    },
    saveNameEdit() {
      if (!this.isEditingName) return;
      this.isEditingName = false;
      const trimmed = this.editName.trim();
      if (trimmed && trimmed !== this.contact.name) {
        this.updateContactField({ name: trimmed });
      }
    },
    cancelNameEdit() {
      this.isEditingName = false;
    },
    onFieldUpdate(field, value) {
      this.updateContactField({ [field]: value });
    },
    async updateContactField(attrs) {
      const contactId = this.contact.id;
      try {
        await this.$store.dispatch('contacts/update', {
          id: contactId,
          ...attrs,
        });
        useAlert(this.$t('CONTACT_FORM.SUCCESS_MESSAGE'));
        await this.$store.dispatch('contacts/fetchContactableInbox', contactId);
      } catch (error) {
        if (error instanceof DuplicateContactException) {
          const detail = error.contactErrorDetail;
          if (detail) {
            useAlert(detail);
          } else {
            const invalidAttrs = Array.isArray(error.data) ? error.data : [];
            if (invalidAttrs.includes('email')) {
              useAlert(this.$t('CONTACT_FORM.FORM.EMAIL_ADDRESS.DUPLICATE'));
            } else if (invalidAttrs.includes('phone_number')) {
              useAlert(this.$t('CONTACT_FORM.FORM.PHONE_NUMBER.DUPLICATE'));
            } else {
              useAlert(this.$t('CONTACT_FORM.ERROR_MESSAGE'));
            }
          }
        } else if (error instanceof ExceptionWithMessage) {
          useAlert(error.data);
        } else {
          useAlert(error.message || this.$t('CONTACT_FORM.ERROR_MESSAGE'));
        }
      }
    },
  },
};
</script>

<template>
  <div class="relative items-center w-full p-4">
    <div class="flex flex-col w-full gap-2 text-left rtl:text-right">
      <div class="flex flex-row justify-between">
        <Avatar
          v-if="showAvatar"
          :src="contact.thumbnail"
          :name="contact.name"
          :status="contact.availability_status"
          :size="48"
          hide-offline-status
        />
      </div>

      <div class="flex flex-col items-start gap-1.5 min-w-0 w-full">
        <div v-if="showAvatar" class="flex items-center w-full min-w-0 gap-2">
          <div class="group/name flex items-center min-w-0 gap-2">
            <InlineInput
              v-if="isEditingName"
              ref="nameInput"
              v-model="editName"
              custom-input-class="!text-base !font-medium !w-auto max-w-full [field-sizing:content]"
              class="!w-fit min-w-0"
              @enter-press="saveNameEdit"
              @escape-press="cancelNameEdit"
              @blur="saveNameEdit"
            />
            <h3
              v-else
              class="flex-shrink max-w-full min-w-0 my-0 text-base capitalize break-words text-n-slate-12 cursor-pointer hover:text-n-slate-12/80"
              :title="$t('CONTACT_PANEL.CLICK_TO_EDIT')"
              @click="startEditingName"
            >
              {{ contact.name }}
            </h3>
            <NextButton
              ghost
              xs
              slate
              icon="i-lucide-pencil"
              :title="$t('CONTACT_PANEL.CLICK_TO_EDIT')"
              class="flex-shrink-0 -mx-1 opacity-0 transition-opacity"
              :class="
                isEditingName
                  ? 'invisible'
                  : 'group-hover/name:opacity-100 focus-visible:opacity-100'
              "
              @click="startEditingName"
            />
          </div>
          <div class="flex flex-row items-center gap-2">
            <span
              v-if="contact.created_at"
              v-tooltip.left="
                `${$t('CONTACT_PANEL.CREATED_AT_LABEL')} ${dynamicTime(
                  contact.created_at
                )}`
              "
              class="i-lucide-info text-sm text-n-slate-10"
            />
            <a
              :href="contactProfileLink"
              target="_blank"
              rel="noopener nofollow noreferrer"
              class="leading-3"
            >
              <span class="i-lucide-external-link text-sm text-n-slate-10" />
            </a>
          </div>
        </div>

        <p v-if="additionalAttributes.description" class="break-words mb-0.5">
          {{ additionalAttributes.description }}
        </p>
        <div class="flex flex-col items-start w-full gap-2">
          <ContactInfoRow
            :href="contact.email ? `mailto:${contact.email}` : ''"
            :value="contact.email"
            icon="mail"
            emoji="✉️"
            :title="$t('CONTACT_PANEL.EMAIL_ADDRESS')"
            show-copy
            editable
            @update="value => onFieldUpdate('email', value)"
          />
          <ContactInfoRow
            :href="contact.phone_number ? `tel:${contact.phone_number}` : ''"
            :value="contact.phone_number"
            icon="call"
            emoji="📞"
            :title="$t('CONTACT_PANEL.PHONE_NUMBER')"
            show-copy
            editable
            @update="value => onFieldUpdate('phone_number', value)"
          />
          <ContactInfoRow
            v-if="contact.identifier"
            :value="contact.identifier"
            icon="contact-identify"
            emoji="🪪"
            :title="$t('CONTACT_PANEL.IDENTIFIER')"
          />
          <ContactInfoRow
            :value="additionalAttributes.address"
            icon="location"
            emoji="📍"
            :title="$t('CONTACT_PANEL.ADDRESS')"
            editable
            @update="
              value =>
                updateContactField({
                  additional_attributes: {
                    ...additionalAttributes,
                    address: value,
                  },
                })
            "
          />
          <ContactInfoRow
            v-if="locationLabel"
            :href="googleMapsUrl"
            :value="locationLabel"
            icon="map"
            emoji="🌍"
            :title="$t('CONTACT_PANEL.LOCATION')"
            :trailing-html="countryFlagHtml"
          />
          <SocialIcons :social-profiles="socialProfiles" />
          <div
            v-if="loadedCustomAttributes.length"
            class="flex flex-col items-start w-full gap-2 pt-2 mt-1 border-t border-n-weak"
          >
            <div
              v-for="attribute in loadedCustomAttributes"
              :key="attribute.key"
              class="flex items-center w-full min-w-0 gap-2"
            >
              <template v-if="isImageAttribute(attribute)">
                <img
                  :src="attribute.fileURL"
                  :alt="attribute.label"
                  class="flex-shrink-0 object-cover w-6 h-6 rounded outline outline-1 outline-n-weak -outline-offset-1 cursor-pointer"
                  @click="openAttributeImagePreview(attribute)"
                />
                <span
                  class="overflow-hidden text-sm whitespace-nowrap text-ellipsis text-n-slate-11"
                >
                  {{ attribute.label }}
                </span>
              </template>
              <a
                v-else-if="isPdfAttribute(attribute)"
                :href="attribute.fileURL"
                target="_blank"
                rel="noopener noreferrer"
                class="flex items-center min-w-0 gap-2 text-n-slate-11 hover:underline"
              >
                <span class="i-lucide-file-text text-sm flex-shrink-0" />
                <span
                  class="overflow-hidden text-sm whitespace-nowrap text-ellipsis"
                >
                  {{ attribute.label }}
                </span>
              </a>
              <template v-else-if="attribute.type === 'file'">
                <a
                  :href="attribute.fileURL"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="flex items-center min-w-0 gap-2 text-n-slate-11 hover:underline"
                >
                  <span class="i-lucide-paperclip text-sm flex-shrink-0" />
                  <span
                    class="overflow-hidden text-sm whitespace-nowrap text-ellipsis"
                  >
                    {{ attribute.label }}
                  </span>
                </a>
              </template>
              <template v-else>
                <span class="flex-shrink-0 text-sm font-medium text-n-slate-12">
                  {{ attribute.label }}:
                </span>
                <a
                  v-if="attribute.linkURL"
                  :href="attribute.linkURL"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="overflow-hidden text-sm whitespace-nowrap text-ellipsis text-n-blue-11 hover:underline"
                >
                  {{ attribute.displayValue }}
                </a>
                <span
                  v-else
                  class="overflow-hidden text-sm whitespace-nowrap text-ellipsis text-n-slate-11"
                >
                  {{ attribute.displayValue }}
                </span>
              </template>
            </div>
            <ImagePreviewDialog
              ref="attributeImageDialog"
              :show-cancel-button="false"
              :show-confirm-button="false"
              width="lg"
            >
              <img
                :src="previewImageSrc"
                :alt="previewImageAlt"
                class="w-full max-h-[70vh] object-contain rounded-lg"
              />
            </ImagePreviewDialog>
          </div>
        </div>
      </div>
      <div class="flex items-center w-full mt-0.5 gap-2">
        <ComposeConversation :contact-id="String(contact.id)">
          <template #trigger>
            <NextButton
              v-tooltip.top-end="$t('CONTACT_PANEL.NEW_MESSAGE')"
              icon="i-ph-chat-circle-dots"
              slate
              faded
              sm
            />
          </template>
        </ComposeConversation>
        <VoiceCallButton
          :phone="contact.phone_number"
          :contact-id="contact.id"
          :conversation-id="currentChat?.id"
          icon="i-lucide-phone"
          sm
          faded
          slate
          :tooltip-label="$t('CONTACT_PANEL.CALL')"
        />
        <NextButton
          v-tooltip.top-end="$t('EDIT_CONTACT.BUTTON_LABEL')"
          icon="i-ph-pencil-simple"
          slate
          faded
          sm
          @click="toggleEditModal"
        />
        <ContactMergeModal :primary-contact="contact">
          <template #trigger>
            <NextButton
              v-tooltip.top-end="$t('CONTACT_PANEL.MERGE_CONTACT')"
              icon="i-ph-arrows-merge"
              slate
              faded
              sm
              :disabled="uiFlags.isMerging"
            />
          </template>
        </ContactMergeModal>
        <ContactDeleteModal
          v-if="isAdmin"
          :contact="contact"
          @deleted="$emit('panelClose')"
        >
          <template #trigger>
            <NextButton
              v-tooltip.top-end="$t('DELETE_CONTACT.BUTTON_LABEL')"
              icon="i-ph-trash"
              slate
              faded
              sm
              ruby
              :disabled="uiFlags.isDeleting"
            />
          </template>
        </ContactDeleteModal>
      </div>
      <EditContact
        :show="showEditModal"
        :contact="contact"
        @cancel="toggleEditModal"
      />
    </div>
  </div>
</template>
