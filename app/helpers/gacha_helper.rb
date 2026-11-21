module GachaHelper
  # ガチャボタンの遷移先・リクエスト方法
  def gacha_link_options(status)
    if status.daily_gacha_draw_available?
      {
        path: draw_random_want_path,
        data: { turbo_method: :post }
      }
    else
      {
        path: random_want_path,
        data: {}
      }
    end
  end
end
