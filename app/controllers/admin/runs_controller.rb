# encoding: utf-8

class Admin::RunsController < Admin::BaseController
  def index
    @runs = Run.includes({ :problem => :contest }, :user).order("runs.created_at DESC")
    @runs = @runs.where(:problem_id => params[:problem_id]) unless params[:problem_id].blank?
    @runs = @runs.where(:problems => { :contest_id => params[:contest_id] }) unless params[:contest_id].blank?
    @runs = @runs.paginate(:page => params[:page], :per_page => 50)

    @contest = Contest.find(params[:contest_id]) unless params[:contest_id].blank?
    @problem = Problem.find(params[:problem_id]) unless params[:problem_id].blank?
  end

  def queue
    @runs = Run.includes(:problem)
    @runs = @runs.where(:problem_id => params[:problem_id]) unless params[:problem_id].blank?
    @runs = @runs.where(:id => params[:id]) unless params[:id].blank?
    @runs = @runs.where(:problems => { :contest_id => params[:contest_id] }) unless params[:contest_id].blank?
    @runs.each { |run| run.update_attributes(:status => Run::WAITING) }
    redirect_to :back
  end

  def show
    @run = Run.find(params[:id])
  end

  def new
    @contest = Contest.find(params[:contest_id])
    @problem = Problem.find(params[:problem_id])

    @run = Run.new
  end

  def edit
    @run = Run.find(params[:id])
  end

  def update
    @run = Run.find(params[:id])
    if @run.update_attributes(params.require(:run).permit!)
      redirect_to(admin_contest_problem_run_path(@run.problem.contest, @run.problem, @run))
    else
      render :action => "edit"
    end
  end

  def create
    @contest = Contest.find(params[:contest_id])
    @problem = Problem.find(params[:problem_id])

    @run = @problem.runs.build(params.require(:run).permit!)

    if @run.save
      flash[:notice] = "Решението е пратено успешно"
      redirect_to admin_contest_problem_runs_path(@contest, @problem)
    else
      render :action => "new"
    end
  end
end
