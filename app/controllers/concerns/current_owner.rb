module CurrentOwner
  extend ActiveSupport::Concern

  def current_owner
    user_signed_in? ? current_user : ensure_guest
  end

  def ensure_guest
    current_guest || create_guest
  end

  def current_owner_status
    current_owner.user_status
  end

  private

  def current_guest
    return @current_guest if defined?(@current_guest)

    token = cookies.encrypted[:guest_token]
    @current_guest = GuestUser.find_by(token: token)
  end

  def create_guest
    @current_guest = GuestUser.create!
    @current_guest.create_user_status!

    add_status_events(
      @current_guest.user_status.record_first_visit!
    )

    cookies.encrypted[:guest_token] = {
      value: @current_guest.token,
      expires: 30.days.from_now,
      httponly: true,
      same_site: :lax,
      secure: Rails.env.production?
    }

    @current_guest
  end
end
