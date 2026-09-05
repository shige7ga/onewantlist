class RandomWantsController < ApplicationController
  before_action :authenticate_user!
  before_action :initialize_gacha_count, only: %i[ show draw ]
  before_action :check_random_want, only: %i[ show ]
  before_action :check_today_gacha_limit, only: %i[ draw ]

  def show
    random_want = RandomWant.find(session[:random_want_id])
    @want = current_user.wants.build(content: random_want.content)
    @user_status = current_user_status
  end

  def draw
    random_want = RandomWant.order(Arel.sql("RANDOM()")).first
    session[:random_want_id] = random_want.id
    current_user_status.increment!(:random_gacha_count)

    if current_user_status.random_gacha_count == UserStatus::RANDOM_GACHA_LIMIT
      current_user_status.update(last_action_date: Date.current)
    end

    redirect_to random_want_path
  end

  private

  def current_user_status
    current_user.user_status
  end

  def initialize_gacha_count
    if current_user_status.random_gacha_date != Date.current
      current_user_status.update!(random_gacha_date: Date.current, random_gacha_count: 0)
      session.delete(:random_want_id)
    end
  end

  def check_random_want
    return if session[:random_want_id].present?
    redirect_to mypage_path, alert: "やりたいことガチャを回してください"
  end

  def check_today_gacha_limit
    return if current_user_status.random_gacha_available?
    redirect_to mypage_path, alert: "やりたいことガチャの使用上限を超えています"
  end
end
