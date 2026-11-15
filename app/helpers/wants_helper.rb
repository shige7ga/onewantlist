module WantsHelper
  def want_status_class(status)
    {
      "not_started" => "border border-dashed border-current",
      "in_progress" => "border-transparent bg-[#E3C88F]",
      "completed" => "border-transparent bg-app-accent"
    }.fetch(status.to_s, "")
  end
end
