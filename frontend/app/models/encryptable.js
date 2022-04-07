import Model, { attr, hasMany, belongsTo } from "@ember-data/model";

export default class Encryptable extends Model {
  @attr("string") name;
  @attr("string") description;
  @attr("string") createdAt;
  @attr("string") updatedAt;
  @belongsTo("folder") folder;
  @hasMany("file-entry") fileEntries;
  @hasMany("log") logs;

  get isOseSecret() {
    return this.constructor.modelName === "encryptable-ose-secret";
  }
}
