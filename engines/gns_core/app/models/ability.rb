class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
    
    
    # gns_project / projects
    can :download_attachments, GnsProject::Project do |project|
      project.count_attachments > 0
    end
    
    can :create, GnsProject::Project do |project|
      true
    end
    
    can :read, GnsProject::Project do |project|
      true
    end
    
    can :update, GnsProject::Project do |project|
      true
    end
    
    can :delete, GnsProject::Project do |project|
      true
    end
    
    can :mark_as_new, GnsProject::Project do |project|
      false
    end
    
    can :send_request, GnsProject::Project do |project|
      project.is_new?
    end
    
    can :start_project, GnsProject::Project do |project|
      project.is_pending?
    end
    
    can :finish, GnsProject::Project do |project|
      project.is_in_progress? and project.get_tasks_not_closed.count == 0
    end
    
    # gns_project / tasks
    can :create_task, GnsProject::Project do |project|
      user.has_project_permission?(project, 'gns_project.tasks.create')
    end
    
    can :read, GnsProject::Task do |task|
      (user.has_project_permission?(task.project, 'gns_project.tasks.read_own') and task.employee == user) or
      (user.has_project_permission?(task.project, 'gns_project.tasks.read_other') and task.employee != user)
    end
    
    can :update, GnsProject::Task do |task|
      (user.has_project_permission?(task.project, 'gns_project.tasks.update_own') and task.employee == user) or
      (user.has_project_permission?(task.project, 'gns_project.tasks.update_other') and task.employee != user)
    end
    
    can :delete, GnsProject::Task do |task|
      (user.has_project_permission?(task.project, 'gns_project.tasks.delete_own') and task.employee == user) or
      (user.has_project_permission?(task.project, 'gns_project.tasks.delete_other') and task.employee != user)
    end
    
    can :finish, GnsProject::Task do |task|
      (!task.finished? and task.progress == 100) and
      (
        (user.has_project_permission?(task.project, 'gns_project.tasks.finish_own') and task.employee == user) or
        (user.has_project_permission?(task.project, 'gns_project.tasks.finish_other') and task.employee != user)
      )
    end
    
    can :unfinish, GnsProject::Task do |task|
      (task.finished? and task.is_open?) and
      (
        (user.has_project_permission?(task.project, 'gns_project.tasks.unfinish_own') and task.employee == user) or
        (user.has_project_permission?(task.project, 'gns_project.tasks.unfinish_other') and task.employee != user)
      )
    end
    
    can :close, GnsProject::Task do |task|
      (task.finished? and task.is_open?) and
      (
        (user.has_project_permission?(task.project, 'gns_project.tasks.close_own') and task.employee == user) or
        (user.has_project_permission?(task.project, 'gns_project.tasks.close_other') and task.employee != user)
      )
    end
    
    can :reopen, GnsProject::Task do |task|
      (task.finished? and task.is_closed?) and
      (
        (user.has_project_permission?(task.project, 'gns_project.tasks.reopen_own') and task.employee == user) or
        (user.has_project_permission?(task.project, 'gns_project.tasks.reopen_other') and task.employee != user)
      )
    end
    
    can :update_progress, GnsProject::Task do |task|
      !task.finished? and
      (
        (user.has_project_permission?(task.project, 'gns_project.tasks.update_progress_own') and task.employee == user) or
        (user.has_project_permission?(task.project, 'gns_project.tasks.update_progress_other') and task.employee != user)
      )
    end
    
    can :download_attachments, GnsProject::Task do |task|
      task.count_attachments > 0
    end
    
    # gns_project / attachments
    can :download, GnsProject::Attachment do |att|
      true
    end
    
    # gns_project / comments
    can :add_new_commnet, GnsProject::Project do |project|
      true
    end
    
    can :reply, GnsProject::Comment do |comment|
      true
    end
    
    can :update, GnsProject::Comment do |comment|
      true
    end
    
    can :delete, GnsProject::Comment do |comment|
      true
    end
    
    can :download, GnsProject::Comment do |comment|
      false
    end
  end
end
