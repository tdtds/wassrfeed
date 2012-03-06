# -*- coding: utf-8; -*-
#
# Net::Wassr : An implementation of of Wassr API (post only)
#
# Copyright (C) 2012 TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL.
#
require 'net/http'
require 'timeout'
require 'cgi'

module Net	#:nodoc:

	class Wassr
		def initialize( user, pass )
			@login = { user: user, pass: pass }
		end
	
		def post_status( status )
			params = "source=wassrfeed&status=#{CGI::escape status}"
			post( '/statuses/update.json', params )
		end
	
		def post_channel( channel, status )
			params = "body=#{CGI::escape status}"
			post( "/channel_message/update.json?name_en=#{channel}", params )
		end
	
		:private
		def post( end_point, params )
			px_host, px_port = (ENV['http_proxy']||'').scan( %r|^(?:.*?)://(.*?):(\d+)?| ).flatten
			timeout( 10 ) do
				Net::HTTP.version_1_2
				req = Net::HTTP::Post.new( end_point )
				req.basic_auth( @login[:user], @login[:pass] )
				req.body = params
				Net::HTTP::Proxy( px_host, px_port ).start( 'api.wassr.jp', 80 ) do |http|
					res = http.request( req )
				end
			end
		end
	end
end
