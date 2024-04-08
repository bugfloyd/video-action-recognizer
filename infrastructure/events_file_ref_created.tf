resource "aws_cloudwatch_event_rule" "file_ref_created" {
  name           = "FileRefCreated"
  event_bus_name = aws_cloudwatch_event_bus.var_bus.name
  event_pattern = jsonencode({
    "source" : ["var.backend"],
    "detail-type" : ["FileRefCreated"],
  })
}

resource "aws_cloudwatch_event_target" "file_ref_created" {
  rule           = aws_cloudwatch_event_rule.file_ref_created.name
  event_bus_name = aws_cloudwatch_event_bus.var_bus.name
  target_id      = "BackendRequestAnalysisCreation"
  arn            = module.api_backend.rest_backend_lambda_arn

  input_transformer {
    input_paths = {
      fileId : "$.detail.file.id",
      userId : "$.detail.file.userId"
    }
    input_template = <<EOF
{
  "path": "/analysis/<userId>/<fileId>",
  "httpMethod": "POST",
  "pathParameters": {
    "userId": "<userId>",
    "fileId": "<fileId>"
  },
  "body": "{\"data\": {\"model\": \"tf\", \"output\": {}}}"
}
EOF
  }
}

resource "aws_lambda_permission" "rest_backend_events_file_created" {
  statement_id  = "AllowExecutionFromEventBridge_FileCreated"
  action        = "lambda:InvokeFunction"
  function_name = module.api_backend.rest_backend_lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.file_ref_created.arn
}