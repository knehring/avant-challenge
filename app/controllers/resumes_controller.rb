class ResumesController < ApplicationController
  def new
  end

  def index
    @resumes = Resume.all
  end

  def create
    @resume = Resume.new(resume_params)

    @resume.save
    redirect_to @resume
  end

  def show
    @resume = Resume.find(params[:id])
  end

  private
    # Allow for reuse of params within controller
    def resume_params
      params.require(:resume).permit(:title, :text)
    end
end
