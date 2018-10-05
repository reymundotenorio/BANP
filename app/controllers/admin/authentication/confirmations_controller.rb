class Admin::Authentication::ConfirmationsController < ApplicationController
  # Authentication layout
  layout "admin/authentication"
  # End Authentication layout

  # /confirm-employee-account
  def new
    @email = params[:email]
    hide_message = params[:hide_message]

    if hide_message
      @hide_message = true

    else
      @hide_message = false
    end

    if @email
      @email.strip!.downcase!
    else
      @email = ""
    end
  end

  # /confirm-employee-account/:confirmation_token
  def show
    @token = params[:confirmation_token]
    @not_found = false;


    # If token has been found
    if @employee = Employee.find_by(confirmation_token: @token)

      # If user is enabled
      if @employee.state

        # If user is not confirmed yet
        if !@employee.confirmed
          @employee.update_attribute(:confirmed, true)

          # Render Sync with external controller
          sync_update @employee

          flash[:notice] = t('views.authentication.successfully_confirmed', email: @employee.email)

          # If user is already confirmed
        else
          flash[:notice] = t('views.authentication.account_confirmed', email: @employee.email)
        end

        # If user is disabled
      else
        flash[:alert] = t('views.authentication.account_disabled')
        @not_found = true
      end

      # If token has not been found
    else
      flash[:alert] = t('views.authentication.token_not_found', token: @token)
      @not_found = true
    end

    render :show
  end

  # Send unlock email to the user
  def send_confirmation_email

    # If email has been found
    if @employee = Employee.find_by(email: params[:resend_confirmation][:email].strip!.downcase!)

      # If user is enabled
      if @employee.state

        # If user is disabled
      else
        flash[:alert] = t('views.authentication.account_disabled')
        render :new
        return
      end

      # If email has not been found
    else
      flash[:alert] = t('views.authentication.email_not_found', email: params[:resend_confirmation][:email].strip!.downcase!)
      render :new
      return
    end

    # Generate random token
    generate_token

    @employee.update_attribute(:confirmation_sent, true)
    @employee.update_attribute(:confirmation_token, @token)

    # Render Sync with external controller
    sync_update @employee

    # Send email
    AuthenticationMailer.confirmation_instructions(@employee, @token, I18n.locale).deliver

    flash[:notice] = t("views.authentication.email_sent", @employee.email)
    render :new
  end

  # Generate token
  def generate_token
    loop do
      @token = SecureRandom.hex(15)
      break @token unless Employee.where(confirmation_token: @token).exists?
    end
  end
end
