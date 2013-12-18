#!/usr/bin/env ruby
require 'rubygems'
require 'set'

if ARGV.length == 2
  p 'Usage: count.rb <filename> <parameter>'
end

parameter_types = [
  'Plan',
  'PPG',
  'Goal',
  'RightsGroup',
  'Output',
  'ProblemObjective',
  'Indicator',
]

filename = ARGV[0]
parameters = ARGV[1] || parameter_types

parameters.each do |parameter|

  unless parameter_types.include? parameter
    p "Parameter type: #{parameter}, not found"
    p "Please choose: #{parameter_types.join(', ')}"
  end

  cmd = "grep '<#{parameter}' #{filename}"

  result = `#{cmd}`

  list = result.lines.map &:chomp

  total = Set.new
  unique = Set.new

  totalRegex = / ID="[^ ]*"/
  uniqueRegex = / RFID="[^ ]*"/
  uniqueRegex = / POPGRPID="[^ ]*"/ if parameter == 'PPG'

  list.each do |line|
    m = totalRegex.match line
    total.add(m.to_s) if m

    m = uniqueRegex.match line
    unique.add(m.to_s) if m
  end

  p "Total Unique #{parameter}: #{unique.count}" unless parameter == 'Plan'
  p "Total #{parameter}: #{total.count}"

end
