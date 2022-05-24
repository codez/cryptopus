import BaseRoute from "./base";
import { inject as service } from "@ember/service";

export default class LogRoute extends BaseRoute {
  @service navService;

  model() {
    return this.store.query("version", {
      load: 0
    });
  }
}
