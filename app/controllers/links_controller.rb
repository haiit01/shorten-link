class LinksController < ApplicationController
  include LinkHelpers

  before_action :validate_url, only: :encode

  def encode
    short_url = generate_short_url
    @link = Link.create(original_url:, short_url:)

    render_error(
      template: "error",
      message: I18n.t("errors.messages.unable_to_create_short_link"),
      status: :internal_server_error
    ) unless @link.persisted?
  end

  def decode
    @link = Link.find_by_short_url(params[:short_link])

    render_error(
      template: "error",
      message: I18n.t("errors.messages.not_found"),
      status: :not_found
    ) if @link.nil?
  end

  def redirect_to_original
    link = Link.find_by_short_url("#{request.base_url}/#{params[:short_code]}")

    if link.present?
      redirect_to link.original_url, allow_other_host: true
    else
      render plain: "Not found", status: :not_found
    end
  end

  private

  def original_url
    @original_url ||= params[:original_link]
  end

  def validate_url
    uri = URI.parse(original_url)

    if !uri.is_a?(URI::HTTP) || original_url.include?(request.host)
      render_error(
        template: "error",
        message: I18n.t("errors.messages.url_invalid"),
        status: :bad_request
      )
    end
  rescue URI::InvalidURIError
    render_error(
      template: "error",
      message: I18n.t("errors.messages.url_invalid"),
      status: :bad_request
    )
  end
end
