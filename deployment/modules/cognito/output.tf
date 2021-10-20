output "cognito_pool" {
  value = aws_cognito_user_pool.users
}

output "cognito_client" {
  value = aws_cognito_user_pool_client.client
}

output "cognito_domain" {
  value = aws_cognito_user_pool_domain.main
}
