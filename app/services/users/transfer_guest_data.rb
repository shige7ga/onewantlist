module Users
  class TransferGuestData
    def initialize(guest_user:, user:)
      @guest_user = guest_user
      @user = user
    end

    def call
      ApplicationRecord.transaction do
        user_status = @guest_user.user_status

        user_status.update!(
          owner: @user,
          last_login_date: Date.current,
          login_count: 1,
          login_streak: 1,
          longest_login_streak: 1
        )

        @guest_user.wants.update_all(
          owner_type: "User",
          owner_id: @user.id,
          updated_at: Time.current
        )

        @guest_user.reload.destroy!

        user_status
      end
    end
  end
end
