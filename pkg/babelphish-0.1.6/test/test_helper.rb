$:.reject! { |e| e.include? 'TextMate' }
require 'rubygems'
require 'ruby-debug'
require 'redgreen' rescue LoadError
require 'stringio'
require 'test/unit'
require File.dirname(__FILE__) + '/../lib/babelphish'

