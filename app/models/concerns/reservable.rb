# frozen_string_literal: true

# Add Methods for Reserved
module Reservable
  extend ActiveSupport::Concern

  def reserved?
    team.present?
  end

  #  Has to be released before it can be reserved
  def reserve(new_team)
    return false if team.present?

    update(team: new_team)
  end

  def reserved_by
    team
  end

  def release
    update_attribute(:team, nil)
  end
end
