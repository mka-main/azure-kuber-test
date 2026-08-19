resource "null_resource" "push_image" {
  depends_on = [azurerm_container_registry.this]

  triggers = {
    app = sha256(join("", [
      filesha256("${path.module}/../app/Dockerfile"),
      filesha256("${path.module}/../app/server.js"),
      filesha256("${path.module}/../app/public/index.html"),
      filesha256("${path.module}/../app/public/styles.css"),
      filesha256("${path.module}/../app/public/app.js"),
    ]))
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      az acr login --name "${azurerm_container_registry.this.name}"
      docker build --platform linux/amd64 \
        -t "${azurerm_container_registry.this.login_server}/myapp:v2" \
        "${path.module}/../app"
      docker push "${azurerm_container_registry.this.login_server}/myapp:v2"
    EOT
  }
}
