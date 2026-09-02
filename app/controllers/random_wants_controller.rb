class RandomWantsController < ApplicationController
  def show
    random_want = RandomWant.find(session[:random_want_id])
    @want = current_user.wants.build(content: random_want.content)
    @gacha_count = current_user.user_status.random_gacha_count
  end

  def draw
    user_status = current_user.user_status
    random_want = RandomWant.order(Arel.sql("RANDOM()")).first

    user_status.increment!(:random_gacha_count)
    session[:random_want_id] = random_want.id

    redirect_to random_want_path
  end
end
