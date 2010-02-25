require File.dirname(__FILE__) + '/lib/yarfmp'

ActionController::Base.send( :include, Yarfmp::FlashMessages::ControllerHelpers)
ActionView::Base.send( :include, Yarfmp::FlashMessages::ViewHelpers )
ActiveSupport::TestCase.send( :include, Yarfmp::FlashMessages::TestHelpers )