module GuestLimitHelper
  def guest_limit_modal_titles
    {
      direct: "やりたいこと登録、3回達成！",
      gacha: "ガチャ体験、3回達成！",
      all: "ゲスト体験、上限まで達成！"
    }
  end

  def guest_action_limited?(type)
    return false if user_signed_in?

    case type
    when :direct
      !current_owner.direct_registration_available?
    when :gacha
      current_owner.gacha_usage_limited?
    else
      raise ArgumentError, "Unknown action type: #{type}"
    end
  end
end
