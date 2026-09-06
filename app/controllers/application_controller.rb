class ApplicationController < ActionController::Base
  before_action :update_last_login_date, if: :user_signed_in?

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def update_last_login_date
    current_user.user_status.record_daily_login!
  end
end
