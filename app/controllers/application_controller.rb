class ApplicationController < ActionController::Base
  before_action :record_daily_login, if: :user_signed_in?, unless: :devise_controller?

  helper_method :status_events

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def owner_home_path
    user_signed_in? ? mypage_path : guest_user_path
  end

  def current_owner
    user_signed_in? ? current_user : ensure_guest
  end

  def ensure_guest
    current_guest || create_guest
  end

  private

  def current_guest
    return @current_guest if defined?(@current_guest)

    token = cookies.encrypted[:guest_token]
    @current_guest = GuestUser.find_by(token: token)
  end

  def create_guest
    @current_guest = GuestUser.create!
    @current_guest.create_user_status!

    cookies.encrypted[:guest_token] = {
      value: @current_guest.token,
      expires: 30.days.from_now,
      httponly: true,
      same_site: :lax,
      secure: Rails.env.production?
    }

    @current_guest
  end

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
