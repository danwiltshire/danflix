resource "auth0_rule" "this" {
  name = var.name
  script = var.script
  enabled = var.enabled
}
