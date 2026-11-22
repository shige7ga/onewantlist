module Admin
  class DashboardPolicy < ApplicationPolicy
    def show?
      user&.admin? == true
    end
  end
end
