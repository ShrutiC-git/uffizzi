# frozen_string_literal: true

class UffizziCore::ApplicationController < ActionController::Base
  include Pundit
  include UffizziCore::ResponseService
  include UffizziCore::AuthManagement
  include UffizziCore::AuthorizationConcern
  include UffizziCore::DependencyInjectionConcern

  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 20

  protect_from_forgery with: :exception
  RESCUABLE_EXCEPTIONS = [RuntimeError, TypeError, NameError, ArgumentError, SyntaxError].freeze
  rescue_from *RESCUABLE_EXCEPTIONS do |exception|
    render_server_error(exception)
  end
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render_not_found(exception)
  end

  rescue_from Pundit::NotAuthorizedError, with: :render_not_authorized

  before_action :authenticate_request!
  skip_before_action :verify_authenticity_token
  respond_to :json

  def render_not_authorized
    render json: { errors: { title: [I18n.t('session.unauthorized')] } }, status: :forbidden
  end

  def policy_context
    UffizziCore::BaseContext.new(current_user, user_access_module, params)
  end

  def self.responder
    UffizziCore::JsonResponder
  end

  def render_not_found(exception)
    resource = exception.model || 'Resource'
    render json: { errors: { title: ["#{resource} Not Found"] } }, status: :not_found
  end

  def render_server_error(error)
    render json: { errors: { title: [error] } }, status: :internal_server_error
  end

  def render_errors(errors)
    json = { errors: errors }

    render json: json, status: :unprocessable_entity
  end

  def q_param
    params[:q] || ActionController::Parameters.new
  end

  def page
    params[:page] || DEFAULT_PAGE
  end

  def per_page
    params[:per_page] || DEFAULT_PER_PAGE
  end
end
