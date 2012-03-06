# -*- coding: utf-8; -*-
#
# WassrFeed::RCfile
#
# Copyright (C) 2012 TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL.
#

module WassrFeed
	module RCfile
		RCFILE = "#{ENV['HOME']}/.wassrfeedrc"
	
		module_function
		def load
			begin
				YAML::load( open( RCFILE, &:read ) )
			rescue Errno::ENOENT
				{
					:latest => {
					}
				}
			end
		end
	
		def save( conf )
			open( RCFILE, 'w' ) {|f| f.write conf.to_yaml }
		end
	end
end
