/* global axios */
import ApiClient from './ApiClient';

class MailerSettingsAPI extends ApiClient {
  constructor() {
    super('mailer_settings', { accountScoped: true });
  }

  get() {
    return axios.get(this.url);
  }

  update(data) {
    return axios.patch(this.url, data);
  }

  reload() {
    return axios.post(`${this.url}/reload`);
  }

  test(settings) {
    return axios.post(`${this.url}/test`, { settings });
  }
}

export default new MailerSettingsAPI();
