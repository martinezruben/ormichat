import { frontendURL } from '../../../helper/URLHelper';

const meta = { permissions: ['administrator', 'agent'] };

export const routes = [
  {
    path: frontendURL('accounts/:accountId/products'),
    component: () => import('./pages/ProductsIndex.vue'),
    meta,
    children: [
      {
        path: '',
        name: 'products_dashboard_index',
        component: () => import('./pages/ProductsIndex.vue'),
        meta,
      },
    ],
  },
];
