# Configure the AWS credentials.
aws_credentials = Aws::Credentials.new(AedEnv.AWS_ACCESS_KEY_ID, AedEnv.AWS_SECRET_ACCESS_KEY)

# Configure action mailer.
Aws::Rails.add_action_mailer_delivery_method(:aws_sdk, credentials: aws_credentials, region: AedEnv.AWS_DEFAULT_REGION)
