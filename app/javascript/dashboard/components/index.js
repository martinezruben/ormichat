// [NOTE][DEPRECATED] This method is to be deprecated, please do not add new components to this file.
/* eslint no-plusplus: 0 */
import { defineAsyncComponent } from 'vue';
import ConfirmDeleteModal from './widgets/modal/ConfirmDeleteModal.vue';
import ConfirmModal from './widgets/modal/ConfirmationModal.vue';
import DeleteModal from './widgets/modal/DeleteModal.vue';
import DropdownItem from 'shared/components/ui/dropdown/DropdownItem.vue';
import DropdownMenu from 'shared/components/ui/dropdown/DropdownMenu.vue';
import FeatureToggle from './widgets/FeatureToggle.vue';
import Input from './widgets/forms/Input.vue';
import Label from './ui/Label.vue';
import LoadingState from './widgets/LoadingState.vue';
import ModalHeader from './ModalHeader.vue';
import Modal from './Modal.vue';
import Spinner from 'shared/components/Spinner.vue';
import Tabs from './ui/Tabs/Tabs.vue';
import TabsItem from './ui/Tabs/TabsItem.vue';

// Componentes con dependencias pesadas (highlight.js, selector de color, libphonenumber,
// calendario): se descargan solo cuando una pantalla los usa.
const Code = defineAsyncComponent(() => import('./Code.vue'));
const ColorPicker = defineAsyncComponent(
  () => import('./widgets/ColorPicker.vue')
);
const PhoneInput = defineAsyncComponent(
  () => import('./widgets/forms/PhoneInput.vue')
);
const DatePicker = defineAsyncComponent(
  () => import('./ui/DatePicker/DatePicker.vue')
);

const WootUIKit = {
  Code,
  ColorPicker,
  ConfirmDeleteModal,
  ConfirmModal,
  DeleteModal,
  DropdownItem,
  DropdownMenu,
  FeatureToggle,
  Input,
  PhoneInput,
  Label,
  LoadingState,
  Modal,
  ModalHeader,
  Spinner,
  Tabs,
  TabsItem,
  DatePicker,
  install(Vue) {
    const keys = Object.keys(this);
    keys.pop(); // remove 'install' from keys
    let i = keys.length;
    while (i--) {
      Vue.component(`woot${keys[i]}`, this[keys[i]]);
    }
  },
};

if (typeof window !== 'undefined' && window.Vue) {
  window.Vue.use(WootUIKit);
}

export default WootUIKit;
