/* global axios */
import ApiClient from './ApiClient';

class ProductsAPI extends ApiClient {
  constructor() {
    super('products', { accountScoped: true });
  }

  get(params = {}) {
    return axios.get(this.url, { params });
  }
}

export default new ProductsAPI();
