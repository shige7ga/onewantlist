class WantsController < ApplicationController
  before_action :authenticate_user!

  def index
    @wants = [ "test", "test2" ]
  end

  def new
    @want = current_user.wants.new
  end
end
