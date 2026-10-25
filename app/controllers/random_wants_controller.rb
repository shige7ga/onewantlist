class RandomWantsController < ApplicationController
  before_action :clear_stale_gacha_result, only: %i[ show edit ]
  before_action :redirect_if_guest_gacha_limited, only: %i[ show edit ]
  before_action :redirect_if_want_registered_today, only: %i[ show edit ]
  before_action :check_random_want, only: %i[ show edit ]
  before_action :set_gacha_result, only: %i[ show edit ]

  def show
  end

  def edit
  end

  def draw
    result = Gacha::Draw.new(owner: current_owner).call

    case result.error
    when nil
      session[:random_want_id] = result.random_want.id
      add_status_events(result.events)
      redirect_to random_want_path

    when :guest_limit
      redirect_to_guest_limit_modal(:gacha)

    when :already_registered
      redirect_to owner_home_path, alert: "今日は既にやりたいことを登録完了しています"

    when :daily_limit
      redirect_to owner_home_path, alert: "やりたいことガチャの使用上限を超えています"

    when :no_random_want
      redirect_to owner_home_path, alert: "ガチャの候補がありません"

    end
  end

  private

  def clear_stale_gacha_result
    return if current_owner_status.random_gacha_date == Date.current
    session.delete(:random_want_id)
  end

  def redirect_if_guest_gacha_limited
    return if user_signed_in?
    return unless current_owner.gacha_usage_limited?

    redirect_to_guest_limit_modal(:gacha)
  end

  def check_random_want
    return if session[:random_want_id].present?
    redirect_to owner_home_path, alert: "やりたいことガチャを回してください"
  end

  def set_gacha_result
    random_want = RandomWant.find(session[:random_want_id])
    @want = current_owner.wants.build(content: random_want.content)
    @user_status = current_owner_status
  end
end
