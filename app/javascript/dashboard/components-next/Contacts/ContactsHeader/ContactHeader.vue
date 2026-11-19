<script setup>
import Button from 'dashboard/components-next/button/Button.vue';
import Input from 'dashboard/components-next/input/Input.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';
import ContactSortMenu from './components/ContactSortMenu.vue';
import ContactMoreActions from './components/ContactMoreActions.vue';
import { usePolicy } from 'dashboard/composables/usePolicy';
import ComposeConversation from 'dashboard/components-next/NewConversation/ComposeConversation.vue';

defineProps({
  showSearch: { type: Boolean, default: true },
  searchValue: { type: String, default: '' },
  headerTitle: { type: String, required: true },
  buttonLabel: { type: String, default: '' },
  activeSort: { type: String, default: 'last_activity_at' },
  activeOrdering: { type: String, default: '' },
  isSegmentsView: { type: Boolean, default: false },
  hasActiveFilters: { type: Boolean, default: false },
  isLabelView: { type: Boolean, default: false },
  isActiveView: { type: Boolean, default: false },
});

const emit = defineEmits([
  'search',
  'filter',
  'update:sort',
  'add',
  'import',
  'export',
  'createSegment',
  'deleteSegment',
]);

const { checkPermissions } = usePolicy();
</script>

<template>
  <header class="sticky top-0 z-20 px-6 md:px-10 bg-n-surface-2">
    <div
      class="flex flex-wrap items-end justify-between w-full pt-8 pb-6 gap-4 mx-auto max-w-[65rem]"
    >
      <div class="min-w-0">
        <h1
          class="m-0 text-2xl font-semibold tracking-tight leading-tight truncate text-n-slate-12"
        >
          {{ headerTitle }}
        </h1>
        <p class="mt-1.5 mb-0 text-sm text-n-slate-11">
          {{ $t('CONTACTS_LAYOUT.HEADER.SUBTITLE') }}
        </p>
      </div>
      <div class="flex items-center flex-col sm:flex-row flex-shrink-0 gap-4">
        <div v-if="showSearch" class="flex items-center gap-2 w-full">
          <Input
            :model-value="searchValue"
            type="search"
            :placeholder="$t('CONTACTS_LAYOUT.HEADER.SEARCH_PLACEHOLDER')"
            :custom-input-class="[
              'h-9 bg-n-solid-1 shadow-sm ltr:!pl-9 !py-1 rtl:!pr-9 sm:w-72',
            ]"
            class="w-full"
            @input="emit('search', $event.target.value)"
          >
            <template #prefix>
              <Icon
                icon="i-lucide-search"
                class="absolute -translate-y-1/2 text-n-slate-11 size-4 top-1/2 ltr:left-3 rtl:right-3"
              />
            </template>
          </Input>
        </div>
        <div class="flex items-center flex-shrink-0 gap-4">
          <div class="flex items-center gap-2">
            <div v-if="!isLabelView && !isActiveView" class="relative">
              <Button
                id="toggleContactsFilterButton"
                :icon="
                  isSegmentsView ? 'i-lucide-pen-line' : 'i-lucide-list-filter'
                "
                color="slate"
                size="sm"
                class="relative w-8"
                variant="ghost"
                @click="emit('filter')"
              >
                <div
                  v-if="hasActiveFilters && !isSegmentsView"
                  class="absolute top-0 right-0 w-2 h-2 rounded-full bg-n-brand"
                />
              </Button>
              <slot name="filter" />
            </div>
            <Button
              v-if="
                hasActiveFilters &&
                !isSegmentsView &&
                !isLabelView &&
                !isActiveView
              "
              icon="i-lucide-save"
              color="slate"
              size="sm"
              variant="ghost"
              @click="emit('createSegment')"
            />
            <Button
              v-if="isSegmentsView && !isLabelView && !isActiveView"
              icon="i-lucide-trash"
              color="slate"
              size="sm"
              variant="ghost"
              @click="emit('deleteSegment')"
            />
            <ContactSortMenu
              :active-sort="activeSort"
              :active-ordering="activeOrdering"
              @update:sort="emit('update:sort', $event)"
            />
            <ContactMoreActions
              @add="emit('add')"
              @import="emit('import')"
              @export="emit('export')"
            />
          </div>
          <div class="w-px h-4 bg-n-strong" />
          <Button
            v-if="checkPermissions(['administrator', 'contact_manage'])"
            :label="
              $t(
                'CONTACTS_LAYOUT.HEADER.ACTIONS.CONTACT_CREATION.IMPORT_CONTACT'
              )
            "
            icon="i-lucide-download"
            color="slate"
            variant="outline"
            class="hidden sm:inline-flex"
            @click="emit('import')"
          />
          <ComposeConversation>
            <template #trigger>
              <Button :label="buttonLabel" icon="i-lucide-plus" />
            </template>
          </ComposeConversation>
        </div>
      </div>
    </div>
  </header>
</template>
