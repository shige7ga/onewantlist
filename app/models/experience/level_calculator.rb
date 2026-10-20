module Experience
  class LevelCalculator
    # 指定Lvから次Lvへ上がるために必要なEXP
    def self.required_exp_for(level)
      case level
      when 1..57
        (10 * 1.05**(level - 1)).floor
      when 58..100
        100 + level
      else
        200
      end
    end

    # 現在Lvに到達した時点の累計EXP
    def self.total_exp_for_current_level(current_lv)
      total_exp_for_level(current_lv)
    end

    # 次Lvに到達するために必要な累計EXP
    def self.total_exp_for_next_level(current_lv)
      total_exp_for_level(current_lv + 1)
    end

    # 指定Lvに到達するための累計EXP
    def self.total_exp_for_level(level)
      (1...level).sum { |lv| required_exp_for(lv) }
    end

    private_class_method :total_exp_for_level
  end
end
