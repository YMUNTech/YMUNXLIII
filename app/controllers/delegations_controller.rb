class DelegationsController < InheritedResources::Base
  before_action :auth
  before_action :attach_id, only: [:show, :update, :edit, :edit_preferences]

  def show

  end

  def new
    if current_user.delegation
      redirect_to action: :edit and return
    end
    new! { url_for(action: :index) }
  end

  def create
    create! do |success, failure|
      success.html do
        current_user.delegation = @delegation
        current_user.save
        redirect_to action: :index
      end
    end
  end

  def edit
    if params[:step].blank?
      if current_user.delegation.registration_finished?
        redirect_to edit_page_delegation_path(1) and return
      else
        redirect_to edit_page_delegation_path(current_user.delegation.step) and return
      end
    end
    @step = params[:step].to_i
    @page = DelegationPage.where(step: @step).first
    @fields = resource.all_fields(@page)
    unless @page
      flash[:error] = 'Invalid Edit Page.'
      redirect_to edit_page_delegation_path(1) and return
    end
    edit!
  end

  def update
    unless params[:step]
      # this is weird
      params[:step] = current_user.delegation.step
    end

    update! do |success, failure|
      flash.keep
      failure.html do
        # flash[:error] = resource.errors.inspect
        # redirect_to edit_page_delegation_path(params[:step])
        edit
      end
      success.html do
        unless current_user.delegation.registration_finished?
          current_user.delegation.advance_step!
        end
        curr_step = params[:step].to_i
        step = if curr_step + 1 > DelegationPage.maximum(:step) then curr_step else curr_step + 1 end
        redirect_to edit_page_delegation_path(step)
      end
    end
  end

  def edit_preferences
    resource.pad_preferences
    edit!
  end

  def payment

  end

  private

  def attach_id
    if current_user.delegation
      params[:id] = current_user.delegation_id
    else
      redirect_to action: :new
    end
  end

  def auth
    authenticate_user!
    unless current_user.type == 'Advisor'
      redirect_to after_sign_in_path_for(current_user)
    end
  end

  def permitted_params
    params.permit(:delegation => [:name, address_attributes: [:id, :line1, :line2, :city, :state, :zip, :country],
                                  preferences_attributes: [:country_id, :id],
                                  fields_attributes: [:id, :delegation_field_id, :value],
                                  advisors_attributes: [:id, :email, :first_name, :last_name],
                                  committee_type_selections_attributes: [:id, :delegate_count, :committee_type_id]])
  end
end
