module Admin
  class BaseController < ApplicationController
    prepend_before_action :authenticate_user!
    after_action :verify_authorized
  end
end
