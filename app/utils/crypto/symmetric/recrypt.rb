# frozen_string_literal: true

class Crypto::Symmetric::Recrypt

  def initialize(current_user, team, private_key)
    @current_user = current_user
    @team = team
    @private_key = private_key
  end

  def perform
    return if already_recrypted? || recrypt_not_ready?

    prepare_recrypt
    begin
      ActiveRecord::Base.transaction do
        recrypt(new_team_password)
      end
    rescue => e # rubocop:disable Style/RescueStandardError
      # TODO: Notify sentry
      @team.recrypt_failed!
      raise "Recrypt failed: #{e.message}"
    end
  end

  private

  def prepare_recrypt
    @team.recrypt_in_progress!
    @team_password = @team.decrypt_team_password(@current_user, @private_key)
  end

  def already_recrypted?
    Crypto::Symmetric::EncryptionAlgorithm.latest_in_use?(@team)
  end

  def recrypt_not_ready?
    @team.recrypt_in_progress? || @team.recrypt_failed?
  end

  def recrypt(new_team_password)
    recrypt_entailed_encryptables(new_team_password)
    update_team(new_team_password)
  end

  def recrypt_entailed_encryptables(new_team_password)
    return if @team.encryptables.empty?

    @team.encryptables.each do |encryptable|
      encryptable.recrypt(@team_password, new_team_password)
    end
  end

  def update_team(new_team_password)
    update_team_encryption_algorithm
    update_teammember_passwords(new_team_password)
    @team.recrypt_done!
  end

  def update_teammember_passwords(new_team_password)
    @team.teammembers.each do |member|
      update_teammeber(member, new_team_password)
    end
  end

  def update_teammeber(member, new_team_password)
    public_key = member.user.public_key
    encrypted_team_password = Crypto::Rsa.encrypt(new_team_password, public_key)
    member.password = encrypted_team_password
    member.save!
  end

  def update_team_encryption_algorithm
    @team.update_encryption_algorithm
    @team.save!
  end

  def new_team_password
    Crypto::Symmetric::EncryptionAlgorithm::ALGORITHMS[@team.encryption_algorithm.to_sym].random_key
  end

end