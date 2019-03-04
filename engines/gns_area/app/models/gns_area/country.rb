module GnsArea
  class Country < ApplicationRecord
    has_many :states, class_name: 'GnsArea::States', dependent: :restrict_with_error
    
    validates :name, :presence => true
    
    def self.select2(params)
      per_page = 10
      page = 1      
      data = {results: [], pagination: {more: false}}
      
      query = self.order(:name)
      
      # keyword
      if params[:q].present?
        query = query.where('LOWER(gns_area_countries.name) LIKE ?', '%'+params[:q].downcase+'%')
      end
      
      # pagination
      page = params[:page].to_i if params[:page].present?
      query = query.limit(per_page).offset(per_page*(page-1))      
      data[:pagination][:more] = true if query.count > 0
      
      # render items
      query.each do |c|
        data[:results] << {id:c.id, text: c.name}
      end
      
      return data
    end

  end
end
