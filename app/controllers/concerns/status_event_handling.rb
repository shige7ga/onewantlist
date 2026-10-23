module StatusEventHandling
  extend ActiveSupport::Concern

  private

  def add_status_events(events)
    return if events.blank?

    session[:status_events] ||= []
    session[:status_events].concat(events)
  end

  def status_events
    @status_events ||= session.delete(:status_events) || []
  end
end
