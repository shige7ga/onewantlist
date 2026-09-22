class RandomWantsController < ApplicationController
  before_action :clear_stale_gacha_result, only: %i[ show ]
  before_action :check_guest_gacha_usage_limit, only: %i[ show draw ]
  before_action :check_today_want_registration, only: %i[ show draw ]
  before_action :check_random_want, only: %i[ show ]
  before_action :check_today_gacha_limit, only: %i[ draw ]

  def show
    random_want = RandomWant.find(session[:random_want_id])
    @want = current_owner.wants.build(content: random_want.content)
    @user_status = current_owner_status
  end

  def draw
    random_want = RandomWant.order(Arel.sql("RANDOM()")).first

    prepare_gacha_for_draw!

    session[:random_want_id] = random_want.id
    current_owner_status.increment!(:random_gacha_count)

    if current_owner_status.random_gacha_count == UserStatus::RANDOM_GACHA_LIMIT
      add_status_events(current_owner_status.record_random_wants_limit!)
    end

    redirect_to random_want_path
  end

  private

  def clear_stale_gacha_result
    return if current_owner_status.random_gacha_date == Date.current
    session.delete(:random_want_id)
  end

  def prepare_gacha_for_draw!
    return if current_owner_status.random_gacha_date == Date.current

    current_owner.record_gacha_usage! unless user_signed_in?
    current_owner_status.update!(random_gacha_date: Date.current, random_gacha_count: 0)
    session.delete(:random_want_id)
  end

  def check_guest_gacha_usage_limit
    return if user_signed_in?
    return if current_owner_status.random_gacha_date == Date.current
    return if current_owner.gacha_usage_available?

    redirect_to new_user_registration_path, alert: "ゲスト利用制限に達しました。ユーザー登録して使ってみましょう。"
  end

  def check_random_want
    return if session[:random_want_id].present?
    redirect_to owner_home_path, alert: "やりたいことガチャを回してください"
  end

  def check_today_gacha_limit
    return if current_owner_status.random_gacha_available?
    redirect_to owner_home_path, alert: "やりたいことガチャの使用上限を超えています"
  end
end
