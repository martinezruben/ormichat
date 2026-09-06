<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import { useMapGetter } from 'dashboard/composables/store';
import mailerSettingsAPI from 'dashboard/api/mailerSettings';

import SectionLayout from '../../account/components/SectionLayout.vue';
import WithLabel from 'v3/components/Form/WithLabel.vue';
import TextInput from 'next/input/Input.vue';
import Switch from 'next/switch/Switch.vue';
import SelectInput from 'dashboard/components-next/select/Select.vue';
import NextButton from 'next/button/Button.vue';

const { t } = useI18n();
const currentUser = useMapGetter('getCurrentUser');

const isLoading = ref(true);
const isSubmitting = ref(false);
const isReloading = ref(false);
const isSendingTest = ref(false);
const passwordIsSet = ref(false);

const formState = reactive({
  address: '',
  port: '587',
  userName: '',
  password: '',
  authentication: 'login',
  domain: '',
  enableStarttlsAuto: true,
  ssl: false,
  senderEmail: '',
});

const testEmail = ref('');

const authenticationOptions = [
  { value: '', label: t('SECURITY_SETTINGS.MAILER.AUTHENTICATION.NONE') },
  { value: 'plain', label: 'Plain' },
  { value: 'login', label: 'Login' },
  { value: 'cram_md5', label: 'CRAM-MD5' },
];

const passwordPlaceholder = computed(() =>
  passwordIsSet.value
    ? t('SECURITY_SETTINGS.MAILER.PASSWORD.PLACEHOLDER_SET')
    : t('SECURITY_SETTINGS.MAILER.PASSWORD.PLACEHOLDER_UNSET')
);

// What the backend expects for update/test, built from the current form
// values so "test" can validate not-yet-saved settings too.
const buildSettingsPayload = () => ({
  SMTP_ADDRESS: formState.address,
  SMTP_PORT: formState.port,
  SMTP_USERNAME: formState.userName,
  SMTP_PASSWORD: formState.password,
  SMTP_AUTHENTICATION: formState.authentication,
  SMTP_DOMAIN: formState.domain,
  SMTP_ENABLE_STARTTLS_AUTO: formState.enableStarttlsAuto,
  SMTP_SSL: formState.ssl,
  MAILER_SENDER_EMAIL: formState.senderEmail,
});

const loadSettings = async () => {
  try {
    isLoading.value = true;
    const { data } = await mailerSettingsAPI.get();
    const settings = data.mailer_settings || {};
    formState.address = settings.SMTP_ADDRESS || '';
    formState.port = settings.SMTP_PORT || '587';
    formState.userName = settings.SMTP_USERNAME || '';
    formState.authentication = settings.SMTP_AUTHENTICATION || '';
    formState.domain = settings.SMTP_DOMAIN || '';
    formState.enableStarttlsAuto = settings.SMTP_ENABLE_STARTTLS_AUTO !== false;
    formState.ssl = !!settings.SMTP_SSL;
    formState.senderEmail = settings.MAILER_SENDER_EMAIL || '';
    passwordIsSet.value = !!settings.SMTP_PASSWORD_SET;
  } catch (error) {
    useAlert(t('SECURITY_SETTINGS.MAILER.API.ERROR_LOADING'));
  } finally {
    isLoading.value = false;
  }
};

const handleSubmit = async () => {
  try {
    isSubmitting.value = true;
    const { data } = await mailerSettingsAPI.update(buildSettingsPayload());
    passwordIsSet.value = !!data.mailer_settings?.SMTP_PASSWORD_SET;
    formState.password = '';
    useAlert(t('SECURITY_SETTINGS.MAILER.API.SAVE_SUCCESS'));
  } catch (error) {
    useAlert(t('SECURITY_SETTINGS.MAILER.API.SAVE_ERROR'));
  } finally {
    isSubmitting.value = false;
  }
};

const handleReload = async () => {
  try {
    isReloading.value = true;
    await mailerSettingsAPI.reload();
    useAlert(t('SECURITY_SETTINGS.MAILER.API.RELOAD_SUCCESS'));
  } catch (error) {
    useAlert(t('SECURITY_SETTINGS.MAILER.API.RELOAD_ERROR'));
  } finally {
    isReloading.value = false;
  }
};

const handleSendTest = async () => {
  try {
    isSendingTest.value = true;
    const payload = buildSettingsPayload();
    await mailerSettingsAPI.test(
      {
        address: payload.SMTP_ADDRESS,
        port: payload.SMTP_PORT,
        user_name: payload.SMTP_USERNAME,
        password: payload.SMTP_PASSWORD || undefined,
        authentication: payload.SMTP_AUTHENTICATION || undefined,
        domain: payload.SMTP_DOMAIN || undefined,
        enable_starttls_auto: payload.SMTP_ENABLE_STARTTLS_AUTO,
        ssl: payload.SMTP_SSL,
        from: payload.MAILER_SENDER_EMAIL || undefined,
      },
      testEmail.value
    );
    useAlert(
      t('SECURITY_SETTINGS.MAILER.API.TEST_SUCCESS', {
        email: testEmail.value,
      })
    );
  } catch (error) {
    useAlert(
      error.response?.data?.error ||
        t('SECURITY_SETTINGS.MAILER.API.TEST_ERROR')
    );
  } finally {
    isSendingTest.value = false;
  }
};

onMounted(() => {
  testEmail.value = currentUser.value.email;
  loadSettings();
});
</script>

<template>
  <SectionLayout
    :title="t('SECURITY_SETTINGS.MAILER.TITLE')"
    :description="t('SECURITY_SETTINGS.MAILER.NOTE')"
    :hide-content="isLoading"
    class="max-w-2xl ltr:mr-auto rtl:ml-auto"
  >
    <form class="grid gap-5" @submit.prevent="handleSubmit">
      <div class="grid grid-cols-2 gap-5">
        <WithLabel
          name="address"
          :label="t('SECURITY_SETTINGS.MAILER.ADDRESS.LABEL')"
        >
          <TextInput
            v-model="formState.address"
            class="w-full"
            :placeholder="t('SECURITY_SETTINGS.MAILER.ADDRESS.PLACEHOLDER')"
          />
        </WithLabel>
        <WithLabel
          name="port"
          :label="t('SECURITY_SETTINGS.MAILER.PORT.LABEL')"
        >
          <TextInput v-model="formState.port" class="w-full" type="number" />
        </WithLabel>
      </div>

      <div class="grid grid-cols-2 gap-5">
        <WithLabel
          name="userName"
          :label="t('SECURITY_SETTINGS.MAILER.USERNAME.LABEL')"
        >
          <TextInput v-model="formState.userName" class="w-full" />
        </WithLabel>
        <WithLabel
          name="password"
          :label="t('SECURITY_SETTINGS.MAILER.PASSWORD.LABEL')"
        >
          <TextInput
            v-model="formState.password"
            class="w-full"
            type="password"
            :placeholder="passwordPlaceholder"
          />
        </WithLabel>
      </div>

      <div class="grid grid-cols-2 gap-5">
        <WithLabel
          name="authentication"
          :label="t('SECURITY_SETTINGS.MAILER.AUTHENTICATION.LABEL')"
        >
          <SelectInput
            v-model="formState.authentication"
            :options="authenticationOptions"
          />
        </WithLabel>
        <WithLabel
          name="domain"
          :label="t('SECURITY_SETTINGS.MAILER.DOMAIN.LABEL')"
        >
          <TextInput
            v-model="formState.domain"
            class="w-full"
            :placeholder="t('SECURITY_SETTINGS.MAILER.DOMAIN.PLACEHOLDER')"
          />
        </WithLabel>
      </div>

      <WithLabel
        name="senderEmail"
        :label="t('SECURITY_SETTINGS.MAILER.SENDER.LABEL')"
        :help-message="t('SECURITY_SETTINGS.MAILER.SENDER.HELP')"
      >
        <TextInput
          v-model="formState.senderEmail"
          class="w-full"
          :placeholder="t('SECURITY_SETTINGS.MAILER.SENDER.PLACEHOLDER')"
        />
      </WithLabel>

      <div class="flex gap-6">
        <label class="flex items-center gap-2 text-sm">
          <Switch v-model="formState.enableStarttlsAuto" />
          {{ t('SECURITY_SETTINGS.MAILER.STARTTLS.LABEL') }}
        </label>
        <label class="flex items-center gap-2 text-sm">
          <Switch v-model="formState.ssl" />
          {{ t('SECURITY_SETTINGS.MAILER.SSL.LABEL') }}
        </label>
      </div>

      <div class="flex flex-wrap gap-2">
        <NextButton
          blue
          type="submit"
          :is-loading="isSubmitting"
          :label="t('SECURITY_SETTINGS.MAILER.SAVE_BUTTON')"
        />
        <NextButton
          faded
          slate
          type="button"
          :is-loading="isReloading"
          :label="t('SECURITY_SETTINGS.MAILER.RELOAD_BUTTON')"
          @click="handleReload"
        />
      </div>

      <div class="pt-4 mt-2 border-t border-n-weak grid gap-3">
        <WithLabel
          name="testEmail"
          :label="t('SECURITY_SETTINGS.MAILER.TEST_EMAIL.LABEL')"
          :help-message="t('SECURITY_SETTINGS.MAILER.TEST_EMAIL.HELP')"
        >
          <div class="flex flex-wrap gap-2">
            <TextInput
              v-model="testEmail"
              class="w-full max-w-xs"
              type="email"
              :placeholder="
                t('SECURITY_SETTINGS.MAILER.TEST_EMAIL.PLACEHOLDER')
              "
            />
            <NextButton
              faded
              slate
              type="button"
              :is-loading="isSendingTest"
              :disabled="!testEmail"
              :label="t('SECURITY_SETTINGS.MAILER.TEST_BUTTON')"
              @click="handleSendTest"
            />
          </div>
        </WithLabel>
      </div>
    </form>
  </SectionLayout>
</template>
