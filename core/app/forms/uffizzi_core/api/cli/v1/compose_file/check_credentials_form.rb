# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ComposeFile::CheckCredentialsForm
  include UffizziCore::ApplicationFormWithoutActiveRecord

  attribute :compose_file
  attribute :credentials

  validate :check_containers_credentials

  private

  def check_containers_credentials
    compose_content = Base64.decode64(compose_file.content)
    compose_payload = { compose_file: compose_file }
    compose_data = UffizziCore::ComposeFileService.parse(compose_content, compose_payload)

    UffizziCore::ComposeFileService.containers_credentials(compose_data, credentials)
  rescue UffizziCore::ComposeFile::CredentialError => e
    errors.add(:credentials, e.message)
  end
end
