/* global axios */
import ApiClient from './ApiClient';

class ProductsAPI extends ApiClient {
  constructor() {
    super('products', { accountScoped: true });
  }

  get(params = {}) {
    return axios.get(this.url, { params });
  }

  uploadImage(id, file) {
    const formData = new FormData();
    formData.append('image', file);
    return axios.post(`${this.url}/${id}/image`, formData);
  }

  removeImage(id) {
    return axios.delete(`${this.url}/${id}/image`);
  }
}

export default new ProductsAPI();
