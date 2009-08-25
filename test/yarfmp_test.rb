require 'test_helper'
require 'rubygems'
require 'shoulda'
require File.join( File.dirname(__FILE__), '..', 'lib', 'yarfmp.rb')

class FakeMessaging < ActionController::Base
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::CaptureHelper
  include Yarfmp::FlashMessages::ViewHelpers
  
  def flash
    @flash ||= {}
  end
  
  def output_buffer=( buf )
    @output_buffer = buf
  end
  
  def output_buffer
    @output_buffer
  end
  
  public :h
end

class YarfmpTest < ActiveSupport::TestCase
  context "flash messaging" do
    setup do
      @helper = FakeMessaging.new
    end
    
    context "with no messages" do
      should "render an empty string" do
        assert_equal %Q{<div id="flash_messages_wrap"></div>}, @helper.render_flash_messages 
      end
    end
    
    context "with a single message" do
      context "just plain text" do
        setup do
          @message = "Testing 1 2 3"
          @helper.add_message(@message)
        end
        
        should "render a list with the message as an li" do
          assert_single_message @message, @helper.render_flash_messages
        end        
      end
      
      context "with plain text and line breaks" do
        setup do
          @message = "First line\n2nd line"
          @helper.add_message( @message )
        end
        
        should "convert the line break into a html break" do
          assert_single_message @message.gsub("\n", "<br/>"), @helper.render_flash_messages
        end
      end
      
      context "with html" do
        setup do
          @message = "<h1>TEST ME!</h1>"
          @helper.add_message(@message)
        end
        
        should "have the html escaped" do
          assert_single_message @helper.h(@message), @helper.render_flash_messages
        end
        
      end
    end
    
    context "with multiple messages" do
      context "just plain text" do
        setup do
          @messages = [
            'message 1',
            'message 2',
          ]
          
          @messages.each {|m| @helper.add_message(m) }
        end
        
        should "render the messages as a list" do
          assert_multiple_messages @messages, @helper.render_flash_messages
        end
      end
      
      context "with html" do
        setup do
          @messages = [
            "<h1>Test message</h1>",
            "<span>Blerg</span>",
          ]
          
          @messages.each {|m| @helper.add_message(m) }
        end
        
        should "render the messages as a list, that's escaped" do
          assert_multiple_messages @messages.collect {|m| @helper.h(m) }, @helper.render_flash_messages
        end
      end
    end
  end
  
  def assert_single_message( message, output, level = :notice )
    assert_equal %Q{<div id="flash_messages_wrap"><div id="flash_messages">\n<div class="message_#{level.to_s}">#{message}</div></div></div>}, output
  end
  
  def assert_multiple_messages( messages, output, level = :notice )
    expected_str = %Q{<div id="flash_messages_wrap"><div id="flash_messages">\n<ul class="message_#{level.to_s}">}
    expected_str << messages.collect {|m| %Q{<li>#{m}</li>} }.join("\n")
    expected_str << "</ul></div></div>"
    
    assert_equal expected_str, output
  end
end