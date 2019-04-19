module GnsProject
  class Comment < ApplicationRecord
    belongs_to :project, class_name: "GnsProject::Project"
    belongs_to :parent, class_name: "GnsProject::Comment", optional: true
    belongs_to :user, class_name: "GnsCore::User"
    has_many :children, class_name: "GnsProject::Comment", foreign_key: "parent_id", dependent: :restrict_with_error
    validates :message, :presence => true
    
    # get project name
    def project_name
			project.present? ? project.name : ''
		end
    
    # get project code
    def project_code
			project.present? ? project.code : ''
		end
    
    # get user name
    def user_name
			user.present? ? user.full_name : ''
		end
    
    # get user email
    def user_email
			user.present? ? user.email : ''
		end
    
    # filters
    def self.filter(query, params)
      params = params.to_unsafe_hash
      
      # single keyword
      #if params[:keyword].present?
      #  keyword = params[:keyword].strip.downcase
      #  keyword.split(' ').each do |q|
      #    q = q.strip
      #    query = query.where('LOWER(gns_project_comments.message) LIKE ?', '%'+q.to_ascii.strip.downcase+'%')
      #  end
      #end

      return query
    end
    
    # searchs
    def self.search(params)
      query = self.where(parent_id: nil)
      query = self.filter(query, params)

      # order
      if params[:sort_by].present?
        order = params[:sort_by]
        order += " #{params[:sort_direction]}" if params[:sort_direction].present?

        query = query.order(order)
      end

      return query
    end
  end
end
