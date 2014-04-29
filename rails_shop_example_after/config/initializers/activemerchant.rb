require 'active_merchant'
require 'active_merchant/billing/integrations/action_view_helper'

ActionView::Base.send(:include, ActiveMerchant::Billing::Integrations::ActionViewHelper)

# to choose 'production' or 'test' mode
ActiveMerchant::Billing::Base.integration_mode = :test # for sandbox
#ActiveMerchant::Billing::Base.integration_mode = :production # for production use
