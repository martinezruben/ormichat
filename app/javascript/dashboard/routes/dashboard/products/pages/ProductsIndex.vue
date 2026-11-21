<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useDebounceFn } from '@vueuse/core';
import { useAlert } from 'dashboard/composables';
import { usePolicy } from 'dashboard/composables/usePolicy';
import ProductsAPI from 'dashboard/api/products';
import Button from 'dashboard/components-next/button/Button.vue';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import Switch from 'dashboard/components-next/switch/Switch.vue';
import ProductFormDialog from '../components/ProductFormDialog.vue';

const AVAILABILITY_CLASSES = {
  in_stock: 'bg-n-teal-3 text-n-teal-11',
  low_stock: 'bg-n-amber-3 text-n-amber-11',
  out_of_stock: 'bg-n-ruby-3 text-n-ruby-11',
};

const { t } = useI18n();
const { checkPermissions } = usePolicy();
const canManage = computed(() => checkPermissions(['administrator']));

const products = ref([]);
const meta = ref({ count: 0, current_page: 1, per_page: 25 });
const knownCategories = ref([]);
const isLoading = ref(false);
const search = ref('');
const category = ref('');
const inStockOnly = ref(false);
const page = ref(1);

const formDialogRef = ref(null);
const deleteDialogRef = ref(null);
const productToDelete = ref(null);

const pageCount = computed(() =>
  Math.max(1, Math.ceil(meta.value.count / meta.value.per_page))
);

const fetchProducts = async () => {
  isLoading.value = true;
  try {
    const { data } = await ProductsAPI.get({
      q: search.value || undefined,
      category: category.value || undefined,
      in_stock: inStockOnly.value || undefined,
      include_inactive: canManage.value || undefined,
      page: page.value,
    });
    products.value = data.payload;
    meta.value = data.meta;
    const names = new Set([
      ...knownCategories.value,
      ...data.payload.map(product => product.category),
    ]);
    knownCategories.value = [...names].sort();
  } finally {
    isLoading.value = false;
  }
};

const debouncedFetch = useDebounceFn(() => {
  page.value = 1;
  fetchProducts();
}, 300);

watch(search, debouncedFetch);
watch([category, inStockOnly], () => {
  page.value = 1;
  fetchProducts();
});

const goToPage = value => {
  page.value = value;
  fetchProducts();
};

const priceRange = product => {
  const prices = product.variants.map(variant => variant.price);
  if (!prices.length) return '';
  const { currency } = product.variants[0];
  const min = Math.min(...prices).toFixed(2);
  const max = Math.max(...prices).toFixed(2);
  return min === max ? `${min} ${currency}` : `${min} – ${max} ${currency}`;
};

const productAvailability = product => {
  if (product.total_stock <= 0) return 'out_of_stock';
  return product.variants.some(variant => variant.availability === 'low_stock')
    ? 'low_stock'
    : 'in_stock';
};

const askDelete = product => {
  productToDelete.value = product;
  deleteDialogRef.value?.open();
};

const confirmDelete = async () => {
  await ProductsAPI.delete(productToDelete.value.id);
  useAlert(t('PRODUCTS.DELETE_CONFIRM.DONE'));
  deleteDialogRef.value?.close();
  fetchProducts();
};

onMounted(fetchProducts);
</script>

<template>
  <section class="flex overflow-hidden w-full h-full bg-n-surface-2">
    <div class="flex flex-col w-full h-full">
      <header class="px-6 md:px-10">
        <div
          class="flex flex-wrap gap-4 justify-between items-end pt-8 pb-6 mx-auto w-full max-w-[65rem]"
        >
          <div class="min-w-0">
            <h1
              class="m-0 text-2xl font-semibold tracking-tight leading-tight text-n-slate-12"
            >
              {{ t('PRODUCTS.TITLE') }}
            </h1>
            <p class="mt-1.5 mb-0 text-sm text-n-slate-11">
              {{ t('PRODUCTS.SUBTITLE') }}
            </p>
          </div>
          <Button
            v-if="canManage"
            :label="t('PRODUCTS.NEW')"
            icon="i-lucide-plus"
            @click="formDialogRef?.open()"
          />
        </div>
      </header>

      <main class="overflow-y-auto flex-1 px-6 pb-14 md:px-10">
        <div class="flex flex-col gap-4 mx-auto w-full max-w-[65rem]">
          <div class="flex flex-wrap gap-3 items-center">
            <div class="relative flex-1 basis-64">
              <span
                class="absolute top-1/2 -translate-y-1/2 i-lucide-search size-4 start-3 text-n-slate-10"
              />
              <input
                v-model="search"
                type="search"
                :placeholder="t('PRODUCTS.SEARCH')"
                class="!mb-0 w-full !h-9 text-sm rounded-lg border shadow-sm outline-none !ps-9 !pe-3 bg-n-solid-1 border-n-weak text-n-slate-12 placeholder:text-n-slate-10 focus:border-n-brand"
              />
            </div>
            <select
              v-model="category"
              class="!mb-0 !w-auto h-9 text-sm bg-n-solid-1"
            >
              <option value="">{{ t('PRODUCTS.ALL_CATEGORIES') }}</option>
              <option v-for="name in knownCategories" :key="name" :value="name">
                {{ name }}
              </option>
            </select>
            <label class="flex gap-2 items-center text-sm text-n-slate-12">
              <Switch v-model="inStockOnly" />
              {{ t('PRODUCTS.IN_STOCK_ONLY') }}
            </label>
          </div>

          <div
            class="overflow-hidden rounded-xl border shadow-sm bg-n-solid-1 border-n-weak"
          >
            <div
              class="hidden md:grid grid-cols-[minmax(0,2.4fr)_minmax(0,1.2fr)_minmax(0,1.2fr)_minmax(0,1.2fr)_5rem] gap-4 items-center px-5 h-10 text-xs font-semibold bg-n-surface-2 text-n-slate-11"
            >
              <span>{{ t('PRODUCTS.COLUMNS.PRODUCT') }}</span>
              <span>{{ t('PRODUCTS.COLUMNS.CATEGORY') }}</span>
              <span>{{ t('PRODUCTS.COLUMNS.PRICE') }}</span>
              <span>{{ t('PRODUCTS.COLUMNS.STOCK') }}</span>
              <span />
            </div>

            <p
              v-if="isLoading && !products.length"
              class="p-8 m-0 text-sm text-center text-n-slate-11"
            >
              {{ t('PRODUCTS.LOADING') }}
            </p>
            <p
              v-else-if="!products.length"
              class="p-8 m-0 text-sm text-center text-n-slate-11"
            >
              {{ t('PRODUCTS.EMPTY') }}
            </p>

            <div v-else class="divide-y divide-n-weak">
              <div
                v-for="product in products"
                :key="product.id"
                class="grid grid-cols-[minmax(0,1fr)_auto] md:grid-cols-[minmax(0,2.4fr)_minmax(0,1.2fr)_minmax(0,1.2fr)_minmax(0,1.2fr)_5rem] gap-4 items-center px-5 py-3 transition-colors hover:bg-n-slate-2"
                :class="{ 'opacity-60': !product.active }"
              >
                <div class="flex gap-3 items-center min-w-0">
                  <img
                    v-if="product.image_url"
                    :src="product.image_url"
                    :alt="product.name"
                    class="object-cover flex-none rounded-lg border size-12 border-n-weak bg-n-slate-2"
                  />
                  <span
                    v-else
                    class="flex flex-none justify-center items-center rounded-lg size-12 bg-n-slate-3 text-n-slate-10"
                  >
                    <span class="i-lucide-package size-5" />
                  </span>
                  <div class="min-w-0">
                    <div class="flex gap-2 items-center">
                      <span
                        class="text-sm font-semibold truncate text-n-slate-12"
                      >
                        {{ product.name }}
                      </span>
                      <span
                        v-if="!product.active"
                        class="px-2 h-5 text-xs font-medium leading-5 rounded-full bg-n-slate-3 text-n-slate-11"
                      >
                        {{ t('PRODUCTS.INACTIVE') }}
                      </span>
                    </div>
                    <div class="text-[0.8125rem] truncate text-n-slate-11">
                      {{ product.sku }}
                      <template v-if="product.brand">
                        · {{ product.brand }}
                      </template>
                      ·
                      {{
                        t(
                          'PRODUCTS.VARIANTS_COUNT',
                          { count: product.variants.length },
                          product.variants.length
                        )
                      }}
                    </div>
                  </div>
                </div>
                <div class="hidden md:block">
                  <span
                    class="inline-flex items-center px-2 h-[1.375rem] text-xs font-medium truncate rounded-md border bg-n-blue-3 border-n-blue-6 text-n-blue-11"
                  >
                    {{ product.category }}
                  </span>
                </div>
                <div
                  class="hidden text-[0.8125rem] tabular-nums md:block text-n-slate-12/80"
                >
                  {{ priceRange(product) }}
                </div>
                <div class="hidden md:block">
                  <span
                    class="inline-flex gap-1.5 items-center px-2 h-5 text-xs font-medium rounded-full"
                    :class="AVAILABILITY_CLASSES[productAvailability(product)]"
                  >
                    <span class="rounded-full size-1.5 bg-current" />
                    {{
                      t(`PRODUCTS.AVAILABILITY.${productAvailability(product)}`)
                    }}
                  </span>
                  <div class="mt-0.5 text-xs text-n-slate-11">
                    {{
                      t('PRODUCTS.STOCK_UNITS', { count: product.total_stock })
                    }}
                  </div>
                </div>
                <div class="flex gap-0.5 justify-end">
                  <Button
                    v-if="canManage"
                    v-tooltip.top="t('PRODUCTS.EDIT')"
                    icon="i-lucide-pen-line"
                    variant="ghost"
                    color="slate"
                    size="sm"
                    @click="formDialogRef?.open(product)"
                  />
                  <Button
                    v-if="canManage"
                    v-tooltip.top="t('PRODUCTS.DELETE')"
                    icon="i-lucide-trash-2"
                    variant="ghost"
                    color="ruby"
                    size="sm"
                    @click="askDelete(product)"
                  />
                </div>
              </div>
            </div>
          </div>

          <div
            v-if="pageCount > 1"
            class="flex gap-3 justify-between items-center text-sm text-n-slate-11"
          >
            <span>
              {{ t('PRODUCTS.PAGINATION', { page, pages: pageCount }) }}
            </span>
            <div class="flex gap-2">
              <Button
                :label="t('PRODUCTS.PREVIOUS')"
                color="slate"
                variant="outline"
                size="sm"
                :disabled="page <= 1"
                @click="goToPage(page - 1)"
              />
              <Button
                :label="t('PRODUCTS.NEXT')"
                color="slate"
                variant="outline"
                size="sm"
                :disabled="page >= pageCount"
                @click="goToPage(page + 1)"
              />
            </div>
          </div>
        </div>
      </main>
    </div>

    <ProductFormDialog ref="formDialogRef" @saved="fetchProducts" />
    <Dialog
      ref="deleteDialogRef"
      type="alert"
      :title="t('PRODUCTS.DELETE_CONFIRM.TITLE')"
      :description="
        t('PRODUCTS.DELETE_CONFIRM.DESCRIPTION', {
          name: productToDelete?.name,
        })
      "
      :confirm-button-label="t('PRODUCTS.DELETE_CONFIRM.CONFIRM')"
      @confirm="confirmDelete"
    />
  </section>
</template>
