require 'rubygems'
require 'narray'
require 'active_support'
require 'numru/netcdf'
require 'geonames'
require 'active_record'

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
    @c = @file.var "air_temperature" #THIS NEED TO CHANGE :)
    @x = @file.var "latitude"
    @y = @file.var "longitude"
    
    #GRAB TIME BASELINE
    @units = @t.att "units"
    @date_since = @units.get.split(" ")[-1]    
    
    #PULL OUT 3D narray
    @temperatures = @c.get
    
  end
  
  def summary_data
    #OUTPUT BASIC DATA
    puts "*" * 30
    puts "file: #{@filename}"
    puts "latitude points: #{@x.get.length}"
    puts "longitude points: #{@y.get.length}"
    puts "total points per month: #{@x.get.length * @y.get.length}"
    puts "months: #{@t.get.length}"
    puts "days from: #{@date_since.to_date}"
    puts "total data points: #{@c.get.length}"
    puts "file shape: #{@c.get.shape.join ", "}"
    puts "*" * 30  
  end
  
  def strip_data
    #OUTPUT STRIP BY STRIP HORIZONTALLY
    @t.get.to_a.each_with_index do |timestamp, time_index|
      @y.get.to_a.each_with_index do |longitude, longitude_index|
        @x.get.to_a.each_with_index do |latitude, latitude_index|
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
          #puts "#{timestamp.days.since(@date_since.to_date)} - (#{longitude} #{latitude}) #{@c.get[longitude_index, latitude_index, time_index]}"        
        end
      end  
    end
  end  
end








