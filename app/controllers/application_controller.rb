class ApplicationController < ActionController::Base
  #will setup here admin namespace 
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
