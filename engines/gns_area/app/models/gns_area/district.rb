module GnsArea
  class District < ApplicationRecord
    belongs_to :state
    
    def self.select2(params)
      per_page = 10
      page = 1      
      data = {results: [], pagination: {more: false}}
      
      query = self.all
      
      # keyword
      if params[:q].present?
        query = query.where('LOWER(gns_area_districts.name) LIKE ?', '%'+params[:q].to_ascii.downcase+'%')
      end
      
      # pagination
      page = params[:page].to_i if params[:page].present?
      query = self.limit(per_page).offset(per_page*(page-1))      
      data[:pagination][:more] = true if query.count > 0
      
      # render items
      query.each do |d|
        data[:results] << {id: d.id, text: d.name}
      end
      
      return data
    end
    
    # import district
    def self.import(file)
      ActiveRecord::Base.logger = nil
      
      xlsx = Roo::Spreadsheet.open(file)
      
      # Read excel file. sheet tabs loop
      xlsx.each_with_pagename do |name, sheet|
        sheet.each_row_streaming do |row|
          
          GnsArea::District.create(
            name: row[0].value,
            state_id: row[1].value
          )
          puts GnsArea::District.count
          
        end
      end
    end
    
  end
end
