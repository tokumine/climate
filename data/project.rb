#!/usr/local/bin/ruby
#
# S. Tokumine, 2008
#
# SCRIPT DEMOING CLIMATE DATA READING 
#

require '../lib/clim_read'

filename = ARGV.first
if filename.blank?
  puts "please enter a filename to process"
else
  clim = ClimRead.new(filename)
  puts clim.summary_data
  clim.strip_data
end