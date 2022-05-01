import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";

export default class ShowComponent extends Component {
  @service store;
  @service router;
  @service intl;
  @service notify;

  @tracked logs = [];
  loadAmount = 10;

  constructor() {
    super(...arguments);

    this.store.query("file-entry", {
      encryptableId: this.args.encryptable.id
    });
    this.getLogs();

    window.scrollTo(0, 0);
  }

  @tracked
  isEncryptableEditing = false;

  @tracked
  isFileEntryCreating = false;

  @tracked
  isPasswordVisible = false;

  @tracked
  canLoadMore = true;

  @action
  toggleEncryptableEdit() {
    this.isEncryptableEditing = !this.isEncryptableEditing;
    this.getLogs();
  }

  @action
  toggleFileEntryNew() {
    this.isFileEntryCreating = !this.isFileEntryCreating;
  }

  @action
  showPassword() {
    this.isPasswordVisible = true;
  }

  @action
  refreshRoute() {
    this.router.transitionTo("/teams");
  }

  @action
  transitionBack() {
    this.router.transitionTo(
      "teams.folders-show",
      this.args.encryptable.folder.get("team.id"),
      this.args.encryptable.folder.get("id")
    );
  }

  @action
  onCopied(attribute) {
    this.notify.info(this.intl.t(`flashes.encryptables.${attribute}_copied`));
  }

  @action
  getLogs() {
    this.store
      .query("paper-trail-version", {
        encryptableId: this.args.encryptable.id,
        load: this.loadAmount
      })
      .then((res) => {
        this.logs = res;
        this.toggleLoadMore();
      });
  }

  @action
  loadMore() {
    this.loadAmount += 10;
    this.getLogs();
  }

  toggleLoadMore() {
    this.canLoadMore = this.loadAmount <= this.logs.length;
  }
}
