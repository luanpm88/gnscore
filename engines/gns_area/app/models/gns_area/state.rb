module GnsArea
  class State < ApplicationRecord
    belongs_to :country
    has_many :districts
    
    validates :name, :country_id, :presence => true
    
    def self.select2(params)
      per_page = 10
      page = 1      
      data = {results: [], pagination: {more: false}}
      
      query = self.all
      
      # keyword
      if params[:q].present?
        query = query.where('LOWER(gns_area_states.name) LIKE ?', '%'+params[:q].to_ascii.downcase+'%')
      end
      
      # pagination
      page = params[:page].to_i if params[:page].present?
      query = self.limit(per_page).offset(per_page*(page-1))      
      data[:pagination][:more] = true if query.count > 0
      
      # render items
      query.each do |s|
        data[:results] << {id: s.id, text: s.name}
      end
      
      return data
    end
    
    # import state
    def self.import(file)
      ActiveRecord::Base.logger = nil
      
      xlsx = Roo::Spreadsheet.open(file)
      
      # Read excel file. sheet tabs loop
      xlsx.each_with_pagename do |name, sheet|
        sheet.each_row_streaming do |row|
          
          GnsArea::State.create(
            name: row[0].value,
            country_id: row[1].value
          )
          puts GnsArea::State.count
          
        end
      end
    end
    
  end
end
