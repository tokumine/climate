require 'rubygems'
require 'narray'
gem 'activesupport', '2.0.2'
require 'activesupport'
require 'numru/netcdf'
require 'geonames'
#gem 'activerecord', '2.0.2'
#require 'activerecord'

include ActiveSupport
include NumRu

#ActiveRecord::Base.establish_connection(
#  :adapter  => :mysql,
#  :database => "cc_dev" 
#)

class ClimRead  
  
  attr_accessor :file
  
  def initialize (filename = nil)
    raise "Must initialise with filename/path" if filename.blank? 
    @filename = filename
    @file = NetCDF.open(filename)
    
    @t = @file.var "time"
    @c = @file.var @file.var_names.last #THIS NEED TO CHANGE :)
    @x = @file.var "latitude"
    @y = @file.var "longitude"
    
    #GRAB TIME BASELINE
    @units = @t.att "units"
    @date_since = @units.get.split(" ")[-1]    
    
    #PULL OUT 3D narray
    #@temperatures = @c.get    
  end
  
  def list_variables
    
  end
  
  def summary_data
    #OUTPUT BASIC DATA
    output = ""
    output << "*" * 30 + "\n"
    output << "File: #{@filename}" + "\n"
    output << "*" * 30 + "\n"
    @file.att_names.each do |atts|
      output << "#{@file.att(atts).name.humanize}: #{@file.att(atts).get} " + "\n"
    end
    
    output << "*" * 30 + "\n"
    output << "latitude points: #{@x.get.length}" + "\n"
    output << "longitude points: #{@y.get.length}" + "\n"
    output << "total points per month: #{@x.get.length * @y.get.length}" + "\n"
    output << "months: #{@t.get.length}" + "\n"
    output << "From: #{@date_since.to_date}" + "\n"
    output << "total data points: #{@c.get.length}" + "\n"
    output << "file shape: #{@c.get.shape.join ", "}" + "\n"
    output << "*" * 30   + "\n"
    output
  end

  def strip_data
    #OUTPUT STRIP BY STRIP HORIZONTALLY
    #Create Directory name
    dir_name = @filename.split(".").first
    Dir.mkdir dir_name
        
    @t.get.to_a.each_with_index do |timestamp, time_index|
      my_file = File.new("#{dir_name}/#{timestamp.days.since(@date_since.to_date)}.csv", "w")
      my_file.puts summary_data
      my_file.puts "\n\ndate,latitude,longitude,value"
      
      puts "Extracting timestamp #{timestamp.days.since(@date_since.to_date)}"
      @y.get.to_a.each_with_index do |longitude, longitude_index|
        @x.get.to_a.each_with_index do |latitude, latitude_index|
            my_file.puts "#{timestamp.days.since(@date_since.to_date)},#{latitude}, #{longitude},#{@c.get[longitude_index, latitude_index, time_index]}"  
=begin          
          c = Climate.new
          c.timeslice = timestamp.days.since(@date_since.to_date)
          c.model_tag = @file.att("model_tag").get
          c.scenario_tag = @file.att("scenario_tag").get
          c.longitude = longitude
          c.latitude = latitude
          c.variable = @c.att("standard_name").get
          c.value = @c.get[longitude_index, latitude_index, time_index]
          c.units = @c.att("units").get
          c.save
=end          
          #puts "#{timestamp.days.since(@date_since.to_date)} - (#{longitude} #{latitude}) #{@c.get[longitude_index, latitude_index, time_index]}"        
          
        end
      end  
    end
  end    
 
end








