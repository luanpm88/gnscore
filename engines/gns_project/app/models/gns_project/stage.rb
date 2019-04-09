module GnsProject
  class Stage < ApplicationRecord
    belongs_to :category, class_name: 'GnsProject::Category'
    
    validates :name, :category_id, :presence => true
    
    # get select2 records
    def self.select2(params)
      per_page = 10
      page = 1      
      data = {results: [], pagination: {more: false}}
      
      query = self.order(:custom_order)
      
      # keyword
      if params[:q].present?
        query = query.where('LOWER(gns_project_stages.name) LIKE ?', '%'+params[:q].to_ascii.strip.downcase+'%')
      end
      
      # category
      if params[:category_id].present?
        query = query.where(category_id: params[:category_id])
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
    
    # update custom_order
    def update_custom_order(current_stage=nil)
      stages_query = Stage.where(category_id: self.category_id)
      max_order_num = stages_query.maximum(:custom_order)
      
      if max_order_num == nil
        self.update_columns(custom_order: 1)
        
      elsif current_stage.present?
        # stages behind / update custom_order
        stages_query.where("custom_order > ?", current_stage.custom_order).update_all("custom_order=custom_order + 1")
        
        # self / update custom_order
        self.update_columns(custom_order: current_stage.custom_order + 1)
      else
        self.update_columns(custom_order: max_order_num + 1)
      end
    end
  end
end
