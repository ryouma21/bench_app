class HomeController < ApplicationController
  def index
    @today_menu = current_user.suggested_menu
  end
end
