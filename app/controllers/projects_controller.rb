class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!, only: [:create, :edit, :update, :destroy]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html do
          if session[:return_to] == projects_path
            redirect_to projects_path
          else
            redirect_to root_path
          end
        end
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html do
          if session[:return_to] == projects_path
            redirect_to projects_path
          else
            redirect_to root_path
          end
        end
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def remove_people
    return redirect_to :back unless params[:people]
    current_projects = Person.find(params[:people][:people]).projects
    old_project = Project.find(params[:id])
    current_projects.delete(old_project) if current_projects.include?(old_project)
    redirect_to :back
  end

  def add_people
    return redirect_to :back unless params[:people]
    people = params[:people][:people]
    people = [ people ] if people.is_a? String
    people.reject(&:blank?).each do |person_id|
      current_projects = Person.find(person_id.to_i).projects
      new_project = Project.find(params[:id])
      current_projects << new_project unless current_projects.include?(new_project)
    end
    redirect_to :back
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name, :url, :people)
    end
end
