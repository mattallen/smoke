require 'rubygems'
gem 'rspec'

require 'spec'
require 'fake_web'

$:<< File.join(File.dirname(__FILE__), '..', 'lib')


SPEC_DIR = File.dirname(__FILE__) unless defined? SPEC_DIR
$:<< SPEC_DIR

require 'smoke'

require 'supports/mayo.rb'
require 'supports/test_source.rb'