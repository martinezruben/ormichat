<script setup>
import { ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute } from 'vue-router';
import { useAlert } from 'dashboard/composables';
import { useMapGetter } from 'dashboard/composables/store';
import { useCustomAttributeFileUpload } from 'dashboard/composables/useCustomAttributeFileUpload';
import { isActiveStorageBlobPath } from 'dashboard/helper/URLHelper';

import Button from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  attribute: {
    type: Object,
    required: true,
  },
  isEditingView: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(['update', 'delete']);

const { t } = useI18n();
const route = useRoute();
const accountId = useMapGetter('getCurrentAccountId');
const { uploadFile } = useCustomAttributeFileUpload();

const fileInput = ref(null);
const isUploading = ref(false);

const hasValue = computed(() => !!props.attribute.value);

const fileDisplayName = computed(() => {
  if (!hasValue.value) return '';
  try {
    return decodeURIComponent(props.attribute.value.split('/').pop());
  } catch {
    return props.attribute.value;
  }
});

const directUploadUrl = computed(
  () =>
    `/api/v1/accounts/${accountId.value}/contacts/${route.params.contactId}/direct_uploads`
);

const triggerFileInput = () => fileInput.value.click();

const onFileSelected = async event => {
  const [file] = event.target.files;
  event.target.value = '';
  if (!file) return;

  isUploading.value = true;
  try {
    const url = await uploadFile(directUploadUrl.value, file);
    emit('update', url);
  } catch {
    useAlert(t('CONTACTS_LAYOUT.SIDEBAR.ATTRIBUTES.FILE.ERROR'));
  } finally {
    isUploading.value = false;
  }
};
</script>

<template>
  <div
    class="flex items-center w-full min-w-0 gap-2"
    :class="{
      'justify-start': isEditingView,
      'justify-end': !isEditingView,
    }"
  >
    <a
      v-if="isActiveStorageBlobPath(attribute.value)"
      :href="attribute.value"
      target="_blank"
      rel="noopener noreferrer"
      class="min-w-0 text-sm truncate hover:underline text-n-blue-11"
    >
      {{ fileDisplayName }}
    </a>
    <span v-else class="min-w-0 text-sm text-n-slate-11">
      {{ t('CONTACTS_LAYOUT.SIDEBAR.ATTRIBUTES.TRIGGER.INPUT') }}
    </span>

    <input
      ref="fileInput"
      type="file"
      class="hidden"
      @change="onFileSelected"
    />

    <div class="flex items-center gap-1">
      <Button
        variant="faded"
        color="slate"
        size="xs"
        :is-loading="isUploading"
        :label="
          hasValue
            ? t('CONTACTS_LAYOUT.SIDEBAR.ATTRIBUTES.FILE.REPLACE')
            : t('CONTACTS_LAYOUT.SIDEBAR.ATTRIBUTES.FILE.UPLOAD')
        "
        class="flex-shrink-0 opacity-0 group-hover/attribute:opacity-100 hover:no-underline"
        @click="triggerFileInput"
      />
      <Button
        v-if="isEditingView"
        variant="faded"
        color="ruby"
        icon="i-lucide-trash"
        size="xs"
        class="flex-shrink-0 opacity-0 group-hover/attribute:opacity-100 hover:no-underline"
        @click="emit('delete')"
      />
    </div>
  </div>
</template>
