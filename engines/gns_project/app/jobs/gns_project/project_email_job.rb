module GnsProject
  class ProjectEmailJob < GnsCore::ApplicationJob
    def perform(type, options)
      GnsProject::ProjectMailer.run(type, options)
    end
  end
end
