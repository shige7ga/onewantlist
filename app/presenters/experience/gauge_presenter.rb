module Experience
  class GaugePresenter
    def initialize(level:, experience:, events:)
      @level = level
      @experience = experience
      @events = events
    end

    # EXPゲージのアニメーション用データ
    def call
      # イベントのキーを文字列・シンボル両対応にする
      normalized_events = @events.map(&:with_indifferent_access)

      # 今回獲得したEXPの合計
      earned_exp = normalized_events.sum do |event|
        event[:type] == "exp_up" ? event[:exp].to_i : 0
      end

      return nil if earned_exp <= 0

      # 今回のレベルアップ回数
      level_up_count = normalized_events.count do |event|
        event[:type] == "lv_up"
      end

      # 更新前のレベルと累計EXP
      start_level = @level - level_up_count
      start_total_exp = @experience - earned_exp

      return nil if start_level < 1 || start_total_exp < 0

      # 更新前のレベル内EXP
      calculator = Experience::LevelCalculator

      start_exp = start_total_exp -
                  calculator.total_exp_for_current_level(start_level)

      return nil if start_exp < 0
      return nil if start_exp >= calculator.required_exp_for(start_level)

      # アニメーション中に必要なレベル別EXP
      requirements = (start_level..@level).map do |lv|
        calculator.required_exp_for(lv)
      end

      {
        start_level: start_level,
        start_exp: start_exp,
        earned_exp: earned_exp,
        requirements: requirements
      }
    end
  end
end
