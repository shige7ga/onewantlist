module Gacha
  class Draw
    Result = Struct.new(
      :random_want,
      :events,
      :error,
      keyword_init: true
    ) do
      def success?
        error.nil?
      end
    end

    def initialize(owner:)
      @owner = owner
    end

    def call
      random_want = nil
      events = []
      error = nil

      @owner.with_lock do
        status = @owner.user_status.reload

        error = unavailable_reason(status)
        next if error
        random_want = RandomWant.order(Arel.sql("RANDOM()")).first

        unless random_want
          error = :no_random_want
          next
        end

        start_new_gacha_day!(status)
        status.increment!(:random_gacha_count)

        if status.random_gacha_count == UserStatus::RANDOM_GACHA_LIMIT
          events = status.record_random_wants_limit!
        end
      end

      Result.new(
        random_want: random_want,
        events: events,
        error: error
      )
    end

    private

    def unavailable_reason(status)
      return :guest_limit if guest? && @owner.gacha_usage_limited?
      return :already_registered if status.want_registered_today?
      return :daily_limit unless status.random_gacha_available?

      nil
    end

    def start_new_gacha_day!(status)
      return if status.random_gacha_date == Date.current

      @owner.record_gacha_usage! if guest?

      status.update!(
        random_gacha_date: Date.current,
        random_gacha_count: 0
      )
    end

    def guest?
      @owner.is_a?(GuestUser)
    end
  end
end
