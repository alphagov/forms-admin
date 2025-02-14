output "review_app_url" {
  description = "The full URL of the review app"
  value       = "https://${local.review_app_hostname}/"
}
