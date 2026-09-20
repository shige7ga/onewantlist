class ApplicationController < ActionController::Base
  before_action :record_daily_login, if: :user_signed_in?, unless: :devise_controller?

  helper_method :status_events

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def current_guest
    return @current_guest if defined?(@current_guest)

    token = cookies.encrypted[:guest_token]
    @current_guest = GuestUser.find_by(token: token)
  end

  def create_guest
    guest_user = GuestUser.create!
    guest_user.create_user_status!

    cookies.encrypted[:guest_token] = {
      value: guest_user.token,
      expires: 30.days.from_now,
      httponly: true,
      same_site: :lax,
      secure: Rails.env.production?
    }

    guest_user
  end

  def ensure_guest
    current_guest || create_guest
  end

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
