resource "aws_cloudwatch_event_rule" "uploaded_file_copied" {
  name           = "UploadedFileCopied"
  event_bus_name = aws_cloudwatch_event_bus.var_bus.name
  event_pattern = jsonencode({
    "source" : ["var.upload_listener"],
    "detail-type" : ["UploadedFileCopied"],
  })
}

resource "aws_cloudwatch_event_target" "request_file_ref_creation" {
  rule           = aws_cloudwatch_event_rule.uploaded_file_copied.name
  event_bus_name = aws_cloudwatch_event_bus.var_bus.name
  target_id      = "BackendRequestFileCreation"
  arn            = module.api_backend.rest_backend_lambda_arn

  input_transformer {
    input_paths = {
      userId : "$.detail.userId",
      key : "$.detail.key",
      name : "$.detail.name"
    }
    input_template = <<EOF
{
  "path": "/files/<userId>",
  "httpMethod": "POST",
  "pathParameters": {
    "userId": "<userId>"
  },
  "body": "{\"key\": \"<key>\", \"name\": \"<name>\"}"
}
EOF
  }
}

resource "aws_lambda_permission" "rest_backend_events_file_copied" {
  statement_id  = "AllowExecutionFromEventBridge_FileCopied"
  action        = "lambda:InvokeFunction"
  function_name = module.api_backend.rest_backend_lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.uploaded_file_copied.arn
}