module Admin
  class DashboardsController < BaseController
    def show
      authorize [:admin, :dashboard], :show?

      @total_users = User.count
      @general_users = User.general.count
      @tester_users = User.tester.count
    end
  end
end
