class Guest::UsersController < ApplicationController
  def show
    # 一時的にデータを格納
    @user = User.new(name: "ゲストユーザー")
    @user_status = UserStatus.new(user: @user)
    @wants = Want.none
  end
end
