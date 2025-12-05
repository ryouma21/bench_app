class MenusController < ApplicationController
  def lighter
    render json: current_user.suggested_lighter_menu
  end

  def heavier
    render json: current_user.suggested_heavier_menu
  end
end
