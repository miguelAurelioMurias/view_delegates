# View delegate minimal controller for rendering
class ViewDelegateController < ActionController::Base
  # Unnecesary modules to remove
  MODULES = [
    ActionController::ConditionalGet,
    ActionController::EtagWithTemplateDigest,
    ActionController::EtagWithFlash,
    ActionController::Caching,
    ActionController::ImplicitRender,
    ActionController::StrongParameters,
    ActionController::ParameterEncoding,
    ActionController::Flash,
    ActionController::FormBuilder
  ].freeze
  without_modules MODULES
end
