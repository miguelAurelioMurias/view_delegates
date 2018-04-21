class ViewDelegateController < ActionController::Base
  MODULES = [
    ActionController::ConditionalGet,
    ActionController::EtagWithTemplateDigest,
    ActionController::EtagWithFlash,
    ActionController::Caching,
    ActionController::ImplicitRender,
    ActionController::StrongParameters,
    ActionController::ParameterEncoding,
    ActionController::Cookies,
    ActionController::Flash,
    ActionController::FormBuilder
  ].freeze
  without_modules MODULES
end
