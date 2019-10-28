class TeamsController < ApplicationController
  before_action :teams, only: [:index]

  def index
  end

  def new
    @team = TeamForm.new
  end

  def create
    @team = TeamForm.new
    if @team.submit(params)
      redirect_to teams_path, notice: "Team successfully created"
    else
      render :new
    end
  end

  def edit
    @team = TeamForm.new(current_resource)
  end

  def update
    @team = TeamForm.new(current_resource)
    if @team.submit(params)
      redirect_to teams_path, notice: "Team successfully updated"
    else
      render :edit
    end
  end

  def teams
    @teams ||= Team.all
  end

  helper_method :teams

  private

  def current_resource
    @current_resource ||= Team.find(params[:id]) if params[:id]
 end
end
