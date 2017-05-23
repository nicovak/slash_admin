# frozen_string_literal: true
module RelaxAdmin
  class AdminAbility
    include CanCan::Ability

    def initialize(user)
      @user = user
      can :read, :all
    end
  end
end
