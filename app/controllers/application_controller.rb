class ApplicationController < ActionController::Base
  before_action :record_daily_login, if: :user_signed_in?, unless: :devise_controller?

  helper_method :status_events

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def record_daily_login
    add_status_events(current_user.user_status.record_daily_login!)
  end

  def add_status_events(events)
    return if events.blank?

    session[:status_events] ||= []
    session[:status_events].concat(events)
  end

  def status_events
    @status_events ||= session.delete(:status_events) || []
  end
end
