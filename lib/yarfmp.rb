module Yarfmp
  module FlashMessages
    FLASH_MESSAGE_LEVELS = [:error, :notice]
    FLASH_MESSAGE_KEY = :flash_messages
    
    class Message
      attr :message, :writable => true
      attr :escape, :writable => true
      
      def initialize( message, escape = true )
        @message = message
        @escape = escape
      end
    end
    
    module ControllerHelpers
     
      def add_message( str, escape = true )
        add_flash_message(:notice, str, escape)
      end

      def add_error( str, escape = true )
        add_flash_message(:error, str, escape )
      end
            
      protected

        def add_flash_message( level, str, escape = true )
          return nil unless FLASH_MESSAGE_LEVELS.include?(level)

          logger.debug("#{self.class.name}:: Adding #{level} message: #{str}")

          message = Message.new( str, escape )

          existing = (flash[FLASH_MESSAGE_KEY] ||= {})[level]
          if existing and ! existing.is_a?(Array)
            existing = [existing, message].flatten
          elsif existing and existing.is_a?(Array)
            existing << message
          elsif ! existing
            existing = message
          end

          flash[FLASH_MESSAGE_KEY][level] = existing
        end

    end

    module ViewHelpers
      def render_flash_messages
        unless has_flash_messages?
          return content_tag(:div, "", :id => "flash_messages_wrap") 
        end

        content_tag(:div, :id => "flash_messages_wrap") do 
          content_tag(:div, :id => "flash_messages") do
            Yarfmp::FlashMessages::FLASH_MESSAGE_LEVELS.collect do |level|
              render_flash_message_single(flash[Yarfmp::FlashMessages::FLASH_MESSAGE_KEY][level], :class => "message_#{level}")
            end.join("\n")
          end
        end
      end

      def render_flash_message_single( messages, options = {} )
        return "" unless messages

        if messages.is_a?(Array)
          content_tag(:ul, options) do
            messages.collect do |msg|
              content_tag(:li, escape_single(msg))
            end.join("\n")
          end
        else
          content_tag(:div, options) do
            escape_single messages
          end
        end
      end

      def escape_single( message )
        if ! message.is_a?(Message) or message.escape
          h(message.message)
        else
          message.message
        end.gsub("\n", "<br/>")
      end
      
      def has_flash_messages?
        flash[FLASH_MESSAGE_KEY] and ! flash[FLASH_MESSAGE_KEY].empty?
      end
    end
    
    module TestHelpers
      # def self.included( base )
      #   FLASH_MESSAGE_LEVELS.each do |level|
      #     define_method("assert_#{level.to_s}") do |message|
      #       assert_message_present( message, level )
      #     end
      #     
      #     define_method("assert_no_#{level.to_s}") do |message|
      #       assert_message_not_present( message, level )
      #     end
      #   end
      # end

      def assert_error( message )
        assert_message_present( message, :error )
      end
      
      def assert_no_error( message )
        assert_message_not_present( message, :error )
      end
      
      def assert_notice(message)
        assert_message_present( message, :notice )
      end
      
      def assert_no_notice( message )
        assert_message_not_present( message, :notice)
      end
      
      def assert_message_present( message, level )
        assert_equal msg,  messages_to_basic(level)
      end
      
      def assert_message_not_present( message, level )
        assert_not_equal msg,  messages_to_basic(level)
      end

      def assert_no_messages
        assert_nil flash[Yarfmp::FlashMessages::FLASH_MESSAGE_KEY]
      end
      
      def messages_to_basic( level )
        message = flash[Yarfmp::FlashMessages::FLASH_MESSAGE_KEY][level]
        if message.is_a? Array
          message.collect(&:message)
        else
          message.try(:message)
        end
      end
    end
  end
end