# View delegate minimal controller for rendering
class ViewDelegateController < ActionController::Base
  # Unnecesary modules to remove
  MODULES = [
    ActionController::ConditionalGet,
    ActionController::EtagWithTemplateDigest,
    ActionController::EtagWithFlash,
    ActionController::ImplicitRender,
    ActionController::StrongParameters,
    ActionController::ParameterEncoding,
    ActionController::Flash
  ].freeze
  without_modules MODULES
end
