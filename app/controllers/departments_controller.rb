class DepartmentsController < ApplicationController
  load_and_authorize_resource
  before_action :set_department, only: [:show, :edit, :update, :change_status]

  # GET /departments
  # GET /departments.json
  def index
    format_to('departments', DepartmentsDatatable)
  end

  # GET /departments/1
  # GET /departments/1.json
  def show
    department_assets
  end

  # GET /departments/new
  def new
    @department = Department.new
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # GET /departments/1/edit
  def edit
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /departments
  # POST /departments.json
  def create
    @department = Department.new(department_params)

    respond_to do |format|
      if @department.save
        format.html { redirect_to departments_url, notice: t('general.created', model:Department.model_name.human) }
        format.json { render action: 'show', status: :created, location: @department }
      else
        format.html { render action: 'form' }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /departments/1
  # PATCH/PUT /departments/1.json
  def update
    respond_to do |format|
      if @department.update(department_params)
        format.html { redirect_to departments_url, notice: t('general.updated', model: Department.model_name.human) }
        format.json { head :no_content }
      else
        format.html { render action: 'form' }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  def change_status
    @department.change_status unless @department.verify_assignment
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def download
    department_assets
    filename = @department.name.parameterize || 'activos'
    respond_to do |format|
      format.html { render nothing: true }
      format.csv do
        send_data @assets.to_csv,
          filename: "#{filename}.csv",
          type: 'text/csv'
      end
      format.pdf do
        render pdf: filename,
               disposition: 'attachment',
               layout: 'pdf.html',
               page_size: 'Letter',
               template: 'users/download.pdf.haml',
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_department
      @department = Department.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def department_params
      params.require(:department).permit(:code, :name, :status, :building_id)
    end

    def department_assets
      users = @department.users
      assets = view_context.status_active(Asset)
      @assets = assets.where(user_id: users)
    end
end
