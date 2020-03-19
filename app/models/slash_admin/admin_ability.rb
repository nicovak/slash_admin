# frozen_string_literal: true

module SlashAdmin
  class AdminAbility
    include CanCan::Ability

    def initialize(user)
      @user = user
      can :manage, :all
    end
  end
end
