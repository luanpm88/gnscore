module GnsProject
  class Task < ApplicationRecord
    belongs_to :stage
    belongs_to :project
    has_many :attachments, dependent: :restrict_with_error
    
    validates :name, :stage_id, :project_id, :presence => true
    
    # get stage name
    def stage_name
      stage.present? ? stage.name : ''
    end
    
    # get select2 records
    def self.select2(params)
      per_page = 10
      page = 1      
      data = {results: [], pagination: {more: false}}
      
      query = self.order(:name)
      
      # keyword
      if params[:q].present?
        query = query.where('LOWER(gns_project_tasks.name) LIKE ?', '%'+params[:q].to_ascii.strip.downcase+'%')
      end
      
      # state
      if params[:stage_id].present?
        query = query.where(stage_id: params[:stage_id])
      end
      
      # pagination
      page = params[:page].to_i if params[:page].present?
      query = query.limit(per_page).offset(per_page*(page-1))      
      data[:pagination][:more] = true if query.count >= per_page
      
      # render items
      query.each do |d|
        data[:results] << {id: d.id, text: d.name}
      end
      
      return data
    end
  end
end
