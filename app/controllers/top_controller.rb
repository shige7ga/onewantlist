class TopController < ApplicationController
  def index
    redirect_to mypage_path if user_signed_in?
  end
end
