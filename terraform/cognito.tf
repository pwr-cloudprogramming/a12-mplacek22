provider "aws" {
  region = "us-east-1"
}

resource "aws_cognito_user_pool" "test_pool" {
  name = "AppPool"

  password_policy {
    minimum_length                  = 8
    require_uppercase               = true
    require_lowercase               = true
    require_numbers                 = true
    require_symbols                 = true
    temporary_password_validity_days = 7
  }

  deletion_protection = "INACTIVE"

  schema {
    name                        = "profile"
    attribute_data_type         = "String"
    developer_only_attribute    = false
    mutable                     = true
    required                    = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                        = "address"
    attribute_data_type         = "String"
    developer_only_attribute    = false
    mutable                     = true
    required                    = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                        = "birthdate"
    attribute_data_type         = "String"
    developer_only_attribute    = false
    mutable                     = true
    required                    = false
    string_attribute_constraints {
      min_length = 10
      max_length = 10
    }
  }

  schema {
    name                        = "gender"
    attribute_data_type         = "String"
    developer_only_attribute    = false
    mutable                     = true
    required                    = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                        = "pref_username"
    attribute_data_type         = "String"
    developer_only_attribute    = false
    mutable                     = true
    required                    = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                        = "updated_at"
    attribute_data_type         = "Number"
    developer_only_attribute    = false
    mutable                     = true
    required                    = false
    number_attribute_constraints {
      min_value = 0
    }
  }

  schema {
    name                        = "website"
    attribute_data_type         = "String"
    developer_only_attribute    = false
    mutable                     = true
    required                    = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                        = "picture"
    attribute_data_type         = "String"
    developer_only_attribute    = false
    mutable                     = true
    required                    = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                        = "identities"
    attribute_data_type         = "String"
    developer_only_attribute    = false
    mutable                     = true
    required                    = false
  }

  schema {
    name                        = "sub"
    attribute_data_type         = "String"
    developer_only_attribute    = false
    mutable                     = false
    required                    = true
    string_attribute_constraints {
      min_length = 1
      max_length = 2048
    }
  }

  schema {
    name                        = "phone_number"
    attribute_data_type         = "String"
    developer_only_attribute    = false
    mutable                     = true
    required                    = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                        = "phone_verified"
    attribute_data_type         = "Boolean"
    developer_only_attribute    = false
    mutable                     = true
    required                    = false
  }

  schema {
    name                        = "zoneinfo"
    attribute_data_type         = "String"
    developer_only_attribute    = false
    mutable                     = true
    required                    = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                        = "locale"
    attribute_data_type         = "String"
    developer_only_attribute    = false
    mutable                     = true
    required                    = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                        = "email"
    attribute_data_type         = "String"
    developer_only_attribute    = false
    mutable                     = true
    required                    = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                        = "email_verified"
    attribute_data_type         = "Boolean"
    developer_only_attribute    = false
    mutable                     = true
    required                    = false
  }

  schema {
    name                        = "given_name"
    attribute_data_type         = "String"
    developer_only_attribute    = false
    mutable                     = true
    required                    = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                        = "family_name"
    attribute_data_type         = "String"
    developer_only_attribute    = false
    mutable                     = true
    required                    = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                        = "middle_name"
    attribute_data_type         = "String"
    developer_only_attribute    = false
    mutable                     = true
    required                    = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                        = "name"
    attribute_data_type         = "String"
    developer_only_attribute    = false
    mutable                     = true
    required                    = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                        = "nickname"
    attribute_data_type         = "String"
    developer_only_attribute    = false
    mutable                     = true
    required                    = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  auto_verified_attributes = ["email"]

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  user_attribute_update_settings {
    attributes_require_verification_before_update = ["email"]
  }

  mfa_configuration = "OFF"

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
    invite_message_template {
      email_subject = "Your temporary password"
      email_message = "Your username is {username} and temporary password is {####}"
      sms_message   = "Your username is {username} and temporary password is {####}"
    }
  }

  username_configuration {
    case_sensitive = false
  }

  account_recovery_setting {
    recovery_mechanism {
      priority = 1
      name     = "verified_email"
    }
  }
}

resource "aws_cognito_user_pool_client" "public_client" {
  name                = "public client"
  user_pool_id        = aws_cognito_user_pool.test_pool.id
  generate_secret     = false

  refresh_token_validity  = 30
  access_token_validity   = 60
  id_token_validity       = 60
  token_validity_units {
    access_token = "minutes"
    id_token     = "minutes"
    refresh_token = "days"
  }

  read_attributes  = [
    "address",
    "birthdate",
    "email",
    "email_verified",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "phone_number_verified",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo"
  ]

  write_attributes = [
    "address",
    "birthdate",
    "email",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo"
  ]

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  allowed_oauth_flows_user_pool_client = false

  prevent_user_existence_errors = "ENABLED"
  enable_token_revocation = true
  auth_session_validity = 3
}
