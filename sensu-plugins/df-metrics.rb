#! /usr/bin/env ruby
#  encoding: UTF-8
#   <script name>
#
# DESCRIPTION:
#   This plugin uses vmstat to collect basic system metrics, produces
#   Graphite formated output.
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: socket
#
# USAGE:
#
# NOTES:
#
# LICENSE:
#   Copyright 2011 Sonian, Inc <chefs@sonian.net>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

def convert_integers(values)
  values.each_with_index do |value, index|
    begin
      converted = Integer(value)
      values[index] = converted
      # #YELLOW
    rescue ArgumentError # rubocop:disable HandleExceptions
    end
  end
  values
end

def run
  result = []
  `df`.each_line.each_with_index do | line, index1 |
    if index1 != 0
      result_line = []
      line.chomp.split(' ').each_with_index do | value, index2 |
        result_line[index2] = value
      end
      result[index1 - 1] = result_line
      print(result_line)
    end
  end

  print('\\n')
  print(result)
  metrics = {}
  result.each do | line |
    print(line)
    diskp = line[0] + '[' + line[5] + ']'
    metrics[diskp] = {}
    line.each_with_index do | value, index |
      case index
        when 1
          metrics[diskp]['1K-Block'] = Integer(value)
        when 2
          metrics[diskp]['Use'] = Integer(value)
        when 3
          metrics[diskp]['Free'] = Integer(value)
        when 4
          metrics[diskp]['UseRate'] = Integer(value.gsub('%', ''))
      end
    end
  end

  timestamp = Time.now.to_i
  metrics.each do |parent, children|
    children.each do |child, value|
      print(['scheme', parent, child].join('.') + ' ' + value.to_s + ' ' + timestamp.to_s + "\n")
    end
  end
end

run();
