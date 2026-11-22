import { mount, flushPromises } from '@vue/test-utils';
import { withFullI18n } from 'test-i18n';
import ProductsAPI from 'dashboard/api/products';
import { usePolicy } from 'dashboard/composables/usePolicy';
import ProductsIndex from '../pages/ProductsIndex.vue';

vi.mock('dashboard/api/products', () => ({
  default: { get: vi.fn(), delete: vi.fn() },
}));
vi.mock('dashboard/composables/usePolicy', () => ({ usePolicy: vi.fn() }));
vi.mock('dashboard/composables', () => ({ useAlert: vi.fn() }));

const products = [
  {
    id: 1,
    name: 'Paracetamol 500 mg',
    sku: 'P-1',
    brand: 'Genérico',
    category: 'Analgésicos',
    image_url: '',
    active: true,
    total_stock: 184,
    variants: [
      {
        id: 1,
        price: 8.5,
        currency: 'BOB',
        stock: 120,
        availability: 'in_stock',
      },
      {
        id: 2,
        price: 15,
        currency: 'BOB',
        stock: 64,
        availability: 'in_stock',
      },
    ],
  },
  {
    id: 2,
    name: 'Alcohol en gel',
    sku: 'A-1',
    category: 'Higiene',
    image_url: '',
    active: true,
    total_stock: 0,
    variants: [
      {
        id: 3,
        price: 41,
        currency: 'BOB',
        stock: 0,
        availability: 'out_of_stock',
      },
    ],
  },
  {
    id: 3,
    name: 'Protector solar',
    sku: 'S-1',
    category: 'Piel',
    image_url: '',
    active: true,
    total_stock: 2,
    variants: [
      {
        id: 4,
        price: 78,
        currency: 'BOB',
        stock: 2,
        availability: 'low_stock',
      },
    ],
  },
];

withFullI18n('es');

const mountPage = async ({ isAdmin }) => {
  usePolicy.mockReturnValue({ checkPermissions: () => isAdmin });
  ProductsAPI.get.mockResolvedValue({
    data: {
      payload: products,
      meta: { count: 3, current_page: 1, per_page: 25 },
    },
  });
  const wrapper = mount(ProductsIndex, {
    global: {
      stubs: {
        ProductFormDialog: true,
        Dialog: true,
        Switch: true,
        Button: {
          props: ['label', 'icon'],
          template: '<button :data-icon="icon">{{ label }}</button>',
        },
      },
    },
  });
  await flushPromises();
  return wrapper;
};

describe('ProductsIndex', () => {
  beforeEach(() => vi.clearAllMocks());

  it('lists each product with its price range and stock status', async () => {
    const wrapper = await mountPage({ isAdmin: false });
    const text = wrapper.text();

    expect(text).toContain('Paracetamol 500 mg');
    expect(text).toContain('8.50 – 15.00 BOB');
    expect(text).toContain('Disponible');
    expect(text).toContain('Agotado');
    expect(text).toContain('Stock bajo');
    expect(text).toContain('184 unidades');
  });

  it('lets administrators create, edit and delete', async () => {
    const wrapper = await mountPage({ isAdmin: true });

    expect(wrapper.text()).toContain('Nuevo producto');
    expect(wrapper.findAll('[data-icon="i-lucide-pen-line"]')).toHaveLength(3);
    expect(wrapper.findAll('[data-icon="i-lucide-trash-2"]')).toHaveLength(3);
    expect(ProductsAPI.get).toHaveBeenCalledWith(
      expect.objectContaining({ include_inactive: true })
    );
  });

  it('only lets agents view the list', async () => {
    const wrapper = await mountPage({ isAdmin: false });

    expect(wrapper.text()).not.toContain('Nuevo producto');
    expect(wrapper.find('[data-icon="i-lucide-pen-line"]').exists()).toBe(
      false
    );
    expect(wrapper.find('[data-icon="i-lucide-trash-2"]').exists()).toBe(false);
    expect(ProductsAPI.get).toHaveBeenCalledWith(
      expect.objectContaining({ include_inactive: undefined })
    );
  });
});
