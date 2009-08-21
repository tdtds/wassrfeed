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

def post_wassr( status )
	wassr = Pit::get( 'wassr', :require => {
		'user' => 'your ID of Wassr.',
		'pass' => 'your Password of Wassr.',
	} )
	px_host, px_port = (ENV['http_proxy']||'').scan( %r|^(?:.*?)://(.*?):(\d+)?| ).flatten
	timeout( 10 ) do
		Net::HTTP.version_1_2
		req = Net::HTTP::Post.new( '/statuses/update.json' )
		req.basic_auth( wassr['user'], wassr['pass'] )
		req.body = "source=wassrfeed&status=#{status}"
		Net::HTTP::Proxy( px_host, px_port ).start( 'api.wassr.jp', 80 ) do |http|
			res = http.request( req )
		end
	end
end

conf = WassrFeedRC::load

while uri = ARGV.shift
	# reading feed
	feed = RSS::Parser::parse( open( uri, &:read ) )

	# reading latest status
	latest = conf[:latest][feed.channel.link] || Time::now

	# making status list
	status = []
	feed.channel.items.each do |item|
		status << item if item.pubDate > latest
	end

	status.sort_by{|i| i.pubDate}.each do |item|
		# trimming ID when twitter
		if %r|^http://twitter\.com/| =~ item.link then
			item.description.sub!( /^[^:]*: /, '' )
			next if item.description.include?( '@' )
		end

		post_wassr item.description
		conf[:latest][feed.channel.link] = item.pubDate
		WassrFeedRC.save( conf )
		sleep( 1 )
	end
	WassrFeedRC.save( conf )
end
