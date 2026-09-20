class TopController < ApplicationController
  before_action :ensure_guest, unless: :user_signed_in?

  def index
    redirect_to mypage_path if user_signed_in?
  end
end
