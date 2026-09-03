class RandomWantsController < ApplicationController
  before_action :authenticate_user!
  before_action :initialize_gacha_count, only: %i[ draw ]
  before_action :check_today_gacha_limit

  def show
    random_want = RandomWant.find(session[:random_want_id])
    @want = current_user.wants.build(content: random_want.content)
    @user_status = current_user_status
  end

  def draw
    random_want = RandomWant.order(Arel.sql("RANDOM()")).first
    current_user_status.increment!(:random_gacha_count)
    session[:random_want_id] = random_want.id
    redirect_to random_want_path
  end

  private

  def current_user_status
    current_user.user_status
  end

  def initialize_gacha_count
    if current_user_status.random_gacha_date != Date.current
      current_user_status.update!(random_gacha_date: Date.current)
      current_user_status.update!(random_gacha_count: 0)
    end
  end

  def check_today_gacha_limit
    return if current_user_status.random_gacha_count <= UserStatus::RANDOM_GACHA_LIMIT
    redirect_to mypage_path, alert: "今日はやりたいことガチャを回す上限を超えています"
  end
end
