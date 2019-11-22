module Jobs
  class UpdateDmonEvent < Jobs::Base
    def execute(args)
      DiscourseDmon::DmonHelper.index_event(args[:discourse_event])
    end
  end
end
