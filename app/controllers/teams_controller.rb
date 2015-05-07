class TeamsController < ApplicationController

  before_action :teams, only: [:index]
  before_action :set_team, except: [:index, :new, :create]


  def index
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    if @team.save
      redirect_to teams_path, notice: "Team successfully created"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @team.update_attributes(team_params)
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

  def team_params
    params.require(:team).permit(:name, :number)
  end

  def set_team
    @team = current_resource
  end

   def current_resource
    @current_resource ||= Team.find(params[:id]) if params[:id]
  end
end
