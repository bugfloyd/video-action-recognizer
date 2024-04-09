resource "aws_cloudwatch_event_rule" "file_analyzed" {
  name           = "FileAnalyzed"
  event_bus_name = aws_cloudwatch_event_bus.var_bus.name
  event_pattern = jsonencode({
    "source" : ["var.analysis_core"],
    "detail-type" : ["FileAnalyzed"],
  })
}

resource "aws_cloudwatch_event_target" "update_analysis_ref" {
  rule           = aws_cloudwatch_event_rule.file_analyzed.name
  event_bus_name = aws_cloudwatch_event_bus.var_bus.name
  target_id      = "BackendRequestAnalysisRefUpdate"
  arn            = module.api_backend.rest_backend_lambda_arn

  input_transformer {
    input_paths = {
      userId : "$.detail.userId"
      fileId : "$.detail.fileId",
      analysisId: "$.detail.analysisId"
      model: "$.detail.data.model"
      output: "$.detail.data.output"
    }
    input_template = <<EOF
{
  "path": "/analysis/<userId>/<fileId>/<analysisId>",
  "httpMethod": "PATCH",
  "pathParameters": {
    "userId": "<userId>",
    "fileId": "<fileId>",
    "analysisId": "<analysisId>"
  },
  "body": "{\"data\": {\"model\": \"<model>\",\"output\": <output>}}"
}
EOF
  }
}

resource "aws_lambda_permission" "rest_backend_events_file_analyzed" {
  statement_id  = "AllowExecutionFromEventBridge_FileAnalyzed"
  action        = "lambda:InvokeFunction"
  function_name = module.api_backend.rest_backend_lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.file_analyzed.arn
}