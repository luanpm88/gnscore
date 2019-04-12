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
    
    # gns_project / tasks
    can :finish, GnsProject::Task do |task|
      !task.finished? and task.progress == 100
    end
    
    can :unfinish, GnsProject::Task do |task|
      task.finished? and task.is_open?
    end
    
    can :close, GnsProject::Task do |task|
      task.finished? and task.is_open?
    end
    
    can :reopen, GnsProject::Task do |task|
      task.finished? and task.is_closed?
    end
    
    can :update_progress, GnsProject::Task do |task|
      !task.finished?
    end
    
    can :download_attachments, GnsProject::Task do |task|
      task.count_attachments > 0
    end
    
    # gns_project / attachments
    can :download, GnsProject::Attachment do |att|
      true
    end
  end
end
