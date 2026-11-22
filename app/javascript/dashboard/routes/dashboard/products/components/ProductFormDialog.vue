<script setup>
import { ref, reactive } from 'vue';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import ProductsAPI from 'dashboard/api/products';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import Input from 'dashboard/components-next/input/Input.vue';
import Switch from 'dashboard/components-next/switch/Switch.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const emit = defineEmits(['saved']);

const { t } = useI18n();
const dialogRef = ref(null);
const isSaving = ref(false);
const productId = ref(null);
const fileInputRef = ref(null);
const imageFile = ref(null);
const imagePreview = ref('');
const hasUploadedImage = ref(false);
const removeUploadedImage = ref(false);

const blankVariant = () => ({ name: '', sku: '', price: '', stock: 0 });

const form = reactive({
  name: '',
  sku: '',
  category: '',
  brand: '',
  description: '',
  aiDescription: '',
  imageUrl: '',
  requiresPrescription: false,
  active: true,
  variants: [blankVariant()],
  removedVariantIds: [],
});

const open = (product = null) => {
  productId.value = product?.id ?? null;
  Object.assign(form, {
    name: product?.name ?? '',
    sku: product?.sku ?? '',
    category: product?.category ?? '',
    brand: product?.brand ?? '',
    description: product?.description ?? '',
    aiDescription: product?.ai_description ?? '',
    imageUrl: product?.image_url ?? '',
    requiresPrescription: product?.requires_prescription ?? false,
    active: product?.active ?? true,
    variants: product?.variants?.length
      ? product.variants.map(variant => ({ ...variant }))
      : [blankVariant()],
    removedVariantIds: [],
  });
  imageFile.value = null;
  imagePreview.value = product?.image_url ?? '';
  hasUploadedImage.value = product?.has_uploaded_image ?? false;
  removeUploadedImage.value = false;
  dialogRef.value?.open();
};

const onFileChange = event => {
  const [file] = event.target.files;
  if (!file) return;
  imageFile.value = file;
  removeUploadedImage.value = false;
  imagePreview.value = URL.createObjectURL(file);
};

const clearImage = () => {
  imageFile.value = null;
  imagePreview.value = form.imageUrl;
  removeUploadedImage.value = hasUploadedImage.value;
  if (fileInputRef.value) fileInputRef.value.value = '';
};

const addVariant = () => form.variants.push(blankVariant());

const removeVariant = index => {
  const [removed] = form.variants.splice(index, 1);
  if (removed.id) form.removedVariantIds.push(removed.id);
};

const buildPayload = () => ({
  product: {
    name: form.name,
    sku: form.sku,
    category: form.category,
    brand: form.brand,
    description: form.description,
    ai_description: form.aiDescription,
    image_url: form.imageUrl,
    requires_prescription: form.requiresPrescription,
    active: form.active,
    variants_attributes: [
      ...form.variants.map(variant => ({
        id: variant.id,
        name: variant.name,
        sku: variant.sku,
        price: variant.price,
        stock: variant.stock,
      })),
      ...form.removedVariantIds.map(id => ({ id, _destroy: true })),
    ],
  },
});

const save = async () => {
  isSaving.value = true;
  try {
    const payload = buildPayload();
    const { data } = productId.value
      ? await ProductsAPI.update(productId.value, payload)
      : await ProductsAPI.create(payload);
    if (imageFile.value)
      await ProductsAPI.uploadImage(data.id, imageFile.value);
    else if (removeUploadedImage.value) await ProductsAPI.removeImage(data.id);
    useAlert(t('PRODUCTS.FORM.SAVED'));
    dialogRef.value?.close();
    emit('saved');
  } catch (error) {
    useAlert(t('PRODUCTS.FORM.ERROR'));
  } finally {
    isSaving.value = false;
  }
};

const textareaClass =
  'w-full px-3 py-2 text-sm rounded-lg border outline-none resize-y bg-n-solid-1 border-n-weak text-n-slate-12 placeholder:text-n-slate-10 focus:border-n-brand';

defineExpose({ open });
</script>

<template>
  <Dialog
    ref="dialogRef"
    width="3xl"
    overflow-y-auto
    :title="
      productId
        ? t('PRODUCTS.FORM.EDIT_TITLE')
        : t('PRODUCTS.FORM.CREATE_TITLE')
    "
    :description="t('PRODUCTS.FORM.DESCRIPTION')"
    :confirm-button-label="t('PRODUCTS.FORM.SAVE')"
    :cancel-button-label="t('PRODUCTS.FORM.CANCEL')"
    :is-loading="isSaving"
    :disable-confirm-button="
      isSaving || !form.name || !form.sku || !form.category
    "
    @confirm="save"
  >
    <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
      <Input v-model="form.name" :label="t('PRODUCTS.FORM.NAME')" />
      <Input v-model="form.sku" :label="t('PRODUCTS.FORM.SKU')" />
      <Input v-model="form.category" :label="t('PRODUCTS.FORM.CATEGORY')" />
      <Input v-model="form.brand" :label="t('PRODUCTS.FORM.BRAND')" />
      <div class="flex gap-4 items-center sm:col-span-2">
        <img
          v-if="imagePreview"
          :src="imagePreview"
          :alt="form.name"
          class="object-cover flex-none rounded-lg border size-20 border-n-weak bg-n-slate-2"
        />
        <span
          v-else
          class="flex flex-none justify-center items-center rounded-lg size-20 bg-n-slate-3 text-n-slate-10"
        >
          <span class="i-lucide-image size-6" />
        </span>
        <div class="flex flex-col gap-2 items-start">
          <span class="text-sm font-medium text-n-slate-12">
            {{ t('PRODUCTS.FORM.PHOTO') }}
          </span>
          <div class="flex flex-wrap gap-2">
            <Button
              :label="t('PRODUCTS.FORM.UPLOAD_PHOTO')"
              icon="i-lucide-upload"
              color="slate"
              variant="outline"
              size="sm"
              @click="fileInputRef?.click()"
            />
            <Button
              v-if="imageFile || (hasUploadedImage && !removeUploadedImage)"
              :label="t('PRODUCTS.FORM.REMOVE_PHOTO')"
              color="ruby"
              variant="ghost"
              size="sm"
              @click="clearImage"
            />
          </div>
          <input
            ref="fileInputRef"
            type="file"
            accept="image/jpeg,image/png,image/gif,image/webp"
            class="hidden"
            @change="onFileChange"
          />
          <span class="text-xs text-n-slate-11">
            {{ t('PRODUCTS.FORM.PHOTO_HELP') }}
          </span>
        </div>
      </div>
      <Input
        v-model="form.imageUrl"
        class="sm:col-span-2"
        :label="t('PRODUCTS.FORM.IMAGE_URL')"
      />
      <label class="flex flex-col gap-2 sm:col-span-2">
        <span class="text-sm font-medium text-n-slate-12">
          {{ t('PRODUCTS.FORM.DESCRIPTION_LABEL') }}
        </span>
        <textarea v-model="form.description" rows="2" :class="textareaClass" />
      </label>
      <label class="flex flex-col gap-2 sm:col-span-2">
        <span class="text-sm font-medium text-n-slate-12">
          {{ t('PRODUCTS.FORM.AI_DESCRIPTION') }}
        </span>
        <textarea
          v-model="form.aiDescription"
          rows="4"
          :class="textareaClass"
        />
        <span class="text-xs text-n-slate-11">
          {{ t('PRODUCTS.FORM.AI_DESCRIPTION_HELP') }}
        </span>
      </label>
      <label class="flex gap-3 items-center text-sm text-n-slate-12">
        <Switch v-model="form.requiresPrescription" />
        {{ t('PRODUCTS.FORM.REQUIRES_PRESCRIPTION') }}
      </label>
      <label class="flex gap-3 items-center text-sm text-n-slate-12">
        <Switch v-model="form.active" />
        {{ t('PRODUCTS.FORM.ACTIVE') }}
      </label>
    </div>

    <div class="flex flex-col gap-3 pt-4 mt-4 border-t border-n-weak">
      <div class="flex justify-between items-center">
        <h4 class="m-0 text-sm font-semibold text-n-slate-12">
          {{ t('PRODUCTS.FORM.VARIANTS') }}
        </h4>
        <Button
          :label="t('PRODUCTS.FORM.ADD_VARIANT')"
          icon="i-lucide-plus"
          color="slate"
          variant="outline"
          size="sm"
          @click="addVariant"
        />
      </div>
      <div
        v-for="(variant, index) in form.variants"
        :key="variant.id || `new-${index}`"
        class="grid grid-cols-[minmax(0,2fr)_minmax(0,1.5fr)_minmax(0,1fr)_minmax(0,1fr)_auto] gap-2 items-end"
      >
        <Input
          v-model="variant.name"
          :label="index === 0 ? t('PRODUCTS.FORM.VARIANT_NAME') : ''"
        />
        <Input
          v-model="variant.sku"
          :label="index === 0 ? t('PRODUCTS.FORM.VARIANT_SKU') : ''"
        />
        <Input
          v-model="variant.price"
          type="number"
          :label="index === 0 ? t('PRODUCTS.FORM.VARIANT_PRICE') : ''"
        />
        <Input
          v-model="variant.stock"
          type="number"
          :label="index === 0 ? t('PRODUCTS.FORM.VARIANT_STOCK') : ''"
        />
        <Button
          v-tooltip.top="t('PRODUCTS.FORM.REMOVE_VARIANT')"
          icon="i-lucide-trash-2"
          color="ruby"
          variant="ghost"
          size="sm"
          :disabled="form.variants.length === 1"
          @click="removeVariant(index)"
        />
      </div>
    </div>
  </Dialog>
</template>
