# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id          :integer          not null, primary key
#  name        :string(40)       default(""), not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  visible     :boolean          default(TRUE), not null
#  private     :boolean          default(FALSE), not null
#

class Team < ApplicationRecord
  attr_readonly :private, :type
  has_many :folders, -> { order :name }, dependent: :destroy
  has_many :teammembers, dependent: :delete_all
  has_many :members, through: :teammembers, source: :user
  has_many :user_favourite_teams, dependent: :destroy

  validates :name, presence: true
  validates :name, length: { maximum: 40 }
  validates :description, length: { maximum: 300 }

  def label
    name
  end

  def last_teammember?(user_id)
    teammembers.count == 1 && teammember?(user_id)
  end

  def teammember?(user_id)
    teammember(user_id).present?
  end

  def teammember(user_id)
    teammembers.find_by(user_id: user_id)
  end

  def decrypt_team_password(user, plaintext_private_key)
    crypted_team_password = teammember(user.id).password
    Crypto::Rsa.decrypt(crypted_team_password, plaintext_private_key)
  end

  def personal_team?
    # self is required for this method to work, even tho RuboCop is complaining
    self.is_a?(Team::Personal) # rubocop:disable Style/RedundantSelf
  end

  def add_user(user, plaintext_team_password)
    raise 'user is already team member' if teammember?(user.id)

    create_teammember(user, plaintext_team_password)
  end

  def self.policy_class
    TeamPolicy
  end

  private

  def create_teammember(user, plaintext_team_password)
    encrypted_team_password = Crypto::Rsa.encrypt(plaintext_team_password, user.public_key)
    teammembers.create!(password: encrypted_team_password, user: user)
  end
end
