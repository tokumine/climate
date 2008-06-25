#
# S. Tokumine, 2008
#
# SCRIPT DEMOING CLIMATE DATA READING 
#

require '../lib/clim_read'
require 'active_record'

clim = ClimRead.new("HADGEM_SRA1B_1_tas_2046-2065.nc")
clim.summary_data
#clim.strip_data
