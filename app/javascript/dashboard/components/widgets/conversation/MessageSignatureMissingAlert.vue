<script setup>
import { useRouter } from 'vue-router';
import Button from 'dashboard/components-next/button/Button.vue';

const router = useRouter();

const openProfileSettings = () => {
  return router.push({ name: 'profile_settings_index' });
};
</script>

<template>
  <div
    class="flex items-baseline justify-between px-2 py-1 my-0 overflow-auto text-xs rounded-lg text-n-slate-11 bg-n-alpha-1 max-h-[8vh]"
  >
    <p class="w-fit !m-0">
      {{ $t('CONVERSATION.FOOTER.MESSAGE_SIGNATURE_NOT_CONFIGURED') }}

      <Button
        link
        :label="$t('CONVERSATION.FOOTER.CLICK_HERE')"
        @click="openProfileSettings"
      />
    </p>
  </div>
</template>
