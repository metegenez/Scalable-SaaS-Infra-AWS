resource "aws_cognito_user_pool" "users" {
  name = "cloudvisor-pool"
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name                                 = "cloudvisor-client"
  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  user_pool_id                         = aws_cognito_user_pool.users.id
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  callback_urls                        = ["https://visor.metawise.co/"]
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "cloudvisor-domain"
  user_pool_id = aws_cognito_user_pool.users.id
}
