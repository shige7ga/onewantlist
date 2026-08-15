class WantsController < ApplicationController
  def index
    @wants = [ "test", "test2" ]
  end
end
