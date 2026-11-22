module Users
  class CreateInitialAdmin
    def initialize(email:, password:)
      @email = email.strip.downcase
      @password = password
    end

    def call
      ApplicationRecord.transaction do
        existing_user = User.find_by(email: @email)

        if existing_user
          validate_existing_user!(existing_user)
          existing_user
        else
          create_admin!
        end
      end
    end

    private

    def validate_existing_user!(user)
      unless user.admin?
        raise "指定したメールアドレスは既に使用されています"
      end

      unless user.user_status
        raise "管理者のUserStatusが存在しません"
      end
    end

    def create_admin!
      user = User.create!(
        name: "管理者",
        email: @email,
        password: @password,
        password_confirmation: @password,
        role: :admin
      )

      user.create_user_status!(
        last_login_date: Date.current,
        login_count: 1,
        login_streak: 1,
        longest_login_streak: 1
      )

      user
    end
  end
end
