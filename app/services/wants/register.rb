
module Wants
  class Register
    Result = Struct.new(:want, :events, :error, keyword_init: true) do
      def success?
        error.nil?
      end
    end

    def initialize(owner:, attributes:, source:)
      @owner = owner
      @attributes = attributes
      @source = source

      unless %i[direct gacha].include?(@source)
        raise ArgumentError, "Unknown registration source"
      end
    end

    def call
      want = @owner.wants.new(@attributes)
      events = []
      error = nil

      @owner.with_lock do
        status = @owner.user_status.reload

        if status.want_registered_today?
          error = :already_registered
        elsif guest_direct? && !@owner.direct_registration_available?
          error = :guest_limit
        elsif want.save
          @owner.record_direct_registration! if guest_direct?
          events = status.record_want_registration!
        else
          error = :invalid_want
        end
      end

      Result.new(want: want, events: events, error: error)
    end

    private

    def guest_direct?
      @owner.is_a?(GuestUser) && @source == :direct
    end
  end
end
