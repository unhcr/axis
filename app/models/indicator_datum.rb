class IndicatorDatum < ActiveRecord::Base
  attr_accessible :baseline, :comp_target, :reversal, :standard, :stored_baseline, :threshold_green, :threshold_red, :yer
end
