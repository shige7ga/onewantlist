module Experience
  class Grant
    def initialize(user_status:, exp_events:)
      @user_status = user_status
      @exp_events = exp_events
    end

    def call
      events = []
      new_exp = @user_status.experience
      new_lv = @user_status.level

      @exp_events.each do |event|
        new_exp += event[:exp]
        events << event

        while new_exp >= Experience::LevelCalculator.total_exp_for_next_level(new_lv)
          new_lv += 1
          events << { type: "lv_up", source: event[:source], level: new_lv }
        end
      end

      @user_status.update!(experience: new_exp, level: new_lv)
      events
    end
  end
end
