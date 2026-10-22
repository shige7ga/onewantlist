class ApplicationController < ActionController::Base
  before_action :record_daily_login, if: :user_signed_in?, unless: :devise_controller?
  before_action :reset_expired_action_streak

  helper_method :status_events
  helper_method :current_owner

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

  def current_owner_status
    current_owner.user_status
  end

  def redirect_if_want_registered_today
    return unless current_owner.user_status.want_registered_today?
    redirect_to owner_home_path, alert: "今日は既にやりたいことを登録完了しています"
  end

  private

  def reset_expired_action_streak
    current_owner.user_status.reset_action_streak_if_expired!
  end

  # ゲスト体験制限モーダルの表示指示を保存して遷移
  def redirect_to_guest_limit_modal(type)
    session[:guest_limit_modal_type] = type.to_s
    redirect_to guest_user_path, status: :see_other
  end

  def current_guest
    return @current_guest if defined?(@current_guest)

    token = cookies.encrypted[:guest_token]
    @current_guest = GuestUser.find_by(token: token)
  end

  def create_guest
    @current_guest = GuestUser.create!
    @current_guest.create_user_status!

    add_status_events(@current_guest.user_status.record_first_visit!)

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
