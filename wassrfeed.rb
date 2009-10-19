#!/usr/bin/env ruby

# wassrfeed.rb
#
# Copyright (C) 2009 TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2.


require 'rubygems'
require 'open-uri'
require 'rss'

require 'pit'
require 'timeout'
require 'net/http'
require 'cgi'

module WassrFeedRC
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

class Wassr
	def initialize
		@login = Pit::get( 'wassr', :require => {
			'user' => 'your ID of Wassr.',
			'pass' => 'your Password of Wassr.',
		} )
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
			req.basic_auth( @login['user'], @login['pass'] )
			req.body = params
			Net::HTTP::Proxy( px_host, px_port ).start( 'api.wassr.jp', 80 ) do |http|
				res = http.request( req )
			end
		end
	end
end

if __FILE__ == $0 then
	conf = WassrFeedRC::load
	
	while uri = ARGV.shift
		# reading feed
		begin
			feed = RSS::Parser::parse( open( uri, &:read ) )
		rescue OpenURI::HTTPError, Errno::ECONNRESET
			$stderr.puts "error on reading feed: #$!"
			exit( 1 )
		end
	
		# reading latest status
		latest = conf[:latest][feed.channel.link] || Time::now
	
		# making status list
		status = []
		feed.channel.items.each do |item|
			status << item if item.pubDate > latest
		end
	
		wassr = Wassr::new
		status.sort_by{|i| i.pubDate}.each do |item|
			# trimming ID when twitter
			if %r|^http://twitter\.com/| =~ item.link then
				item.description.sub!( /^[^:]*: /, '' )
				next if item.description.include?( '@' )
			end

			text = CGI::unescapeHTML( CGI::unescapeHTML( item.description ) )
			if text.sub!( /^#([a-zA-Z0-9]+)\s/, '' )
				wassr.post_channel( $1, text )
			else
				wassr.post_status( text )
			end
			conf[:latest][feed.channel.link] = item.pubDate
			WassrFeedRC.save( conf )
			sleep( 1 )
		end
		WassrFeedRC.save( conf )
	end
end
