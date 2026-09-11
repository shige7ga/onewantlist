class ApplicationController < ActionController::Base
  before_action :load_status_events
  before_action :record_daily_login, if: :user_signed_in?

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def load_status_events
    @events = session.delete(:status_events) || []
  end

  def record_daily_login
    @events.concat(current_user.user_status.record_daily_login!)
  end
end
