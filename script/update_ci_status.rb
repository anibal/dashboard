#!/usr/bin/env ruby

%w[rubygems dashboard].each {|l| require l }

`wget -q http://ci.trike.com.au/XmlStatusReport.aspx -O #{CI_STATUS_FILE} &> /dev/null > /dev/null`
