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
        if message.escape
          h(message.message)
        else
          message.message
        end.gsub("\n", "<br/>")
      end
      
      def has_flash_messages?
        flash[FLASH_MESSAGE_KEY] and ! flash[FLASH_MESSAGE_KEY].empty?
      end
    end
  end
end