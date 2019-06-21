module GnsProject
  class TemplateDetail < ApplicationRecord
    belongs_to :template, class_name: 'GnsProject::Template'
    belongs_to :stage, class_name: 'GnsProject::Stage'
    
    validates :task_description, :stage_id, :template_id, :presence => true
    
    # get stage name
    def stage_name
      stage.present? ? stage.name : ''
    end
    
    # get template name
    def template_name
      template.present? ? template.name : ''
    end
    
    # get select2 records
    def self.select2(params)
      per_page = 10
      page = 1      
      data = {results: [], pagination: {more: false}}
      
      query = self.includes(:stage).order("gns_project_stages.custom_order, gns_project_template_details.custom_order")
      
      # keyword
      if params[:q].present?
        query = query.where('LOWER(gns_project_emplate_details.task_description) LIKE ?', '%'+params[:q].to_ascii.strip.downcase+'%')
      end
      
      # stage
      if params[:stage_id].present?
        query = query.where(stage_id: params[:stage_id])
      end
      
      # project
      if params[:template_id].present?
        query = query.where(template_id: params[:template_id])
      end
      
      # pagination
      page = params[:page].to_i if params[:page].present?
      query = query.limit(per_page).offset(per_page*(page-1))      
      data[:pagination][:more] = true if query.count >= per_page
      
      # render items
      query.each do |d|
        data[:results] << {id: d.id, text: task_description}
      end
      
      return data
    end
    
    # update custom_order
    def update_custom_order(current_template_detail=nil)
      template_details_query = TemplateDetail.where(template_id: self.template_id)
      max_order_num = template_details_query.maximum(:custom_order)
      
      if max_order_num == nil
        self.update_columns(custom_order: 1)
        
      elsif current_template_detail.present?
        # template details behind / update custom_order
        template_details_query.where("custom_order > ?", current_template_detail.custom_order).update_all("custom_order=custom_order + 1")
        
        # self / update custom_order
        self.update_columns(custom_order: current_template_detail.custom_order + 1)
      else
        self.update_columns(custom_order: max_order_num + 1)
      end
    end
  end
end
