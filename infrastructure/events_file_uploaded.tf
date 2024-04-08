resource "aws_cloudwatch_event_rule" "s3_file_uploaded_event_rule" {
  name = "FileUploaded"
  event_pattern = jsonencode({
    "source" : ["aws.s3"],
    "detail-type" : ["Object Created"],
    "detail" : {
      "bucket" : {
        "name" : [aws_s3_bucket.input_bucket.bucket]
      }
      "object" : {
        "key" : [{
          "prefix" : "upload/"
        }]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "preprocess_uploaded_file_lambda" {
  rule      = aws_cloudwatch_event_rule.s3_file_uploaded_event_rule.name
  target_id = "InvokePreprocessUploadedFileLambda"
  arn       = aws_lambda_function.upload_listener_lambda.arn
}
