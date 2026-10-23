class ApplicationController < ActionController::Base
  include CurrentOwner
  include StatusEventHandling
  include UserStatusTracking

  before_action :record_daily_login, if: :user_signed_in?, unless: :devise_controller?
  before_action :reset_expired_action_streak

  helper_method :status_events, :current_owner

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def owner_home_path
    user_signed_in? ? mypage_path : guest_user_path
  end

  def redirect_if_want_registered_today
    return unless current_owner_status.want_registered_today?
    redirect_to owner_home_path, alert: "今日は既にやりたいことを登録完了しています"
  end

  private

  # ゲスト体験制限モーダルの表示指示を保存して遷移
  def redirect_to_guest_limit_modal(type)
    session[:guest_limit_modal_type] = type.to_s
    redirect_to guest_user_path, status: :see_other
  end
end
