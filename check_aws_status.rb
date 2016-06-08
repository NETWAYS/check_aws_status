#!/usr/bin/env ruby
# COPYRIGHT:
#
# This software is Copyright (c) 2016 NETWAYS GmbH, Simon Hoenscheid <simon.hoenscheid@netways.de>
#
# (Except where explicitly superseded by other copyright notices)
#
#
# LICENSE:
#
# Copyright (C) 2016 NETWAYS GmbH <support@netways.de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
# or see <http://www.gnu.org/licenses/>.
#
# CONTRIBUTION SUBMISSION POLICY:
#
# (The following paragraph is not intended to limit the rights granted
# to you to modify and distribute this software under the terms of
# the GNU General Public License and is only of importance to you if
# you choose to contribute your changes and enhancements to the
# community by submitting them to NETWAYS GmbH.)
#
# By intentionally submitting any modifications, corrections or
# derivatives to this work, or any other work intended for use with
# this Software, to NETWAYS GmbH, you confirm that
# you are the copyright holder for those contributions and you grant
# NETWAYS GmbH a nonexclusive, worldwide, irrevocable,
# royalty-free, perpetual, license to use, copy, create derivative
# works based on those contributions, and sublicense and distribute
# those contributions and any derivatives thereof.
#
# Nagios and the Nagios logo are registered trademarks of Ethan Galstad.
=begin
@author NETWAYS GmbH Simon Hoenscheid <simon.hoenscheid@netways.de>
=end

script_version=0.1

# ruby dependencies
require 'rss'
require 'choice'

#options and help message
Choice.options do
  header ''
  header 'Specific options:'

  option :protocol do
    short '-p'
    long '--protocol=PORT'
    desc 'The protocol to use (default http)'
    default 'http'
  end
  
	option :aws_status_url do
    short '-u'
    long '--url=URL'
    desc 'The AWS Status URL (default status.aws.amazon.com)'
    default 'status.aws.amazon.com'
  end

  option :aws_region do
    short '-r'
    long '--region=REGION'
    desc 'The AWS Region to use (default eu-central-1)'
    default 'eu-central-1'
  end

  option :aws_service do
    short '-s'
    long '--service=SERVICE'
    desc 'The AWS Service to monitor (default ec2)'
    default 'ec2'
  end


  separator ''
  separator 'Common options: '

  option :help do
    long '--help'
    desc 'Show this message'
  end

  option :examples do
    long '--examples'
    desc 'S3 Status in Ireland (eu-west-1 region): ./check_aws_status.rb -s s3 -r eu-west-1'
    desc 'EC2 Status in North California (us-west-1 region): ./check_aws_status.rb -s ec2 -r us-west-1'
  end

  option :version do
    short '-v'
    long '--version'
    desc 'Show version'
    action do
      puts "check_aws_status.rb v#{script_version}"
      exit
    end
  end
end

#build RSS Feed URL
aws_service_status_rss = Choice[:protocol] + '://' + Choice[:aws_status_url] + '/rss/' + Choice[:aws_service] + '-' + Choice[:aws_region] + '.rss'

#parse the feed
parse_rss_service_feed = RSS::Parser.parse(aws_service_status_rss, false)
#get latest event
last_event = parse_rss_service_feed.items.first.title.to_s
#latest event is an array, split it
split_last_event = last_event.split(':')
#this is the service event
service_event = split_last_event.first
#here are some details, just needed for informational events
service_event_details = split_last_event.last

#feed icinga with the results
case service_event
  #everything is OK
  when 'Service is operating normally'
    puts 'OK - ' + Choice[:aws_service].upcase + ' in ' + Choice[:aws_region].upcase
    exit 0
  #there was an information, force the user to have a look at it, send an warning
  when 'Informational message'
    #amazon doesn't create a new feed item if an information is resolved, we need to check if the info is resolved.
    # if resolved the state is OK
    if service_event_details.include? "[RESOLVED]"
      puts 'OK - ' + Choice[:aws_service].upcase + ' in ' + Choice[:aws_region].upcase + ' was RESOLVED'
      exit 0
    #if just an information return a warning
    else
      puts 'WARNING - ' + 'Information for ' + Choice[:aws_service].upcase + ' in ' + Choice[:aws_region].upcase + ' you should check it'
      exit 1
    end
  #performance issues are treated as a warning
  when 'Performance issues'
    puts 'WARNING - ' + Choice[:aws_service].upcase + ' in ' + Choice[:aws_region].upcase
    exit 1
  #service disruptions are critical, return this state
  when 'Service disruption'
    puts 'CRITICAL - ' + Choice[:aws_service].upcase + ' in ' + Choice[:aws_region].upcase
    exit 2
  #every other state I do not know is treated as unknown
  else
    puts 'UNKNOWN - ' + Choice[:aws_service].upcase + ' in ' + Choice[:aws_region].upcase
    exit 3
end