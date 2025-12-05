class HomeController < ApplicationController
  def index
    if user_signed_in?
      @today_menu = current_user.suggested_menu
    end
  end
end
