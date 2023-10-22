locals {
  mongo_connection_string = "'mongodb://${var.mongo_user}:${urlencode(var.mongo_password)}@172.17.0.2:27017'"
  bot_env                 = join(" ", [
    "-e AppSettings__ClientId=${var.twitch_client_id}",
    "-e AppSettings__ClientSecret=${var.twitch_client_secret}",
    "-e AppSettings__RedirectUri=${var.twitch_redirect_uri}",
  ])
}

resource "null_resource" "up_twitch_bot_container" {
  triggers = {
    build_number = timestamp()
  }

  connection {
    user        = "root"
    host        = hcloud_server.cleannetcode_bot.ipv4_address
    type        = "ssh"
    private_key = var.ssh_private_key
  }

  provisioner "remote-exec" {
    inline = [
      "docker container stop twitch_bot &> /dev/null",
      "docker container rm twitch_bot &> /dev/null",
      "docker rmi $(docker images | grep 'cleannetcode.twitchbot') &> /dev/null",
      "docker pull pingvin1308/cleannetcode.twitchbot:${var.image_version}",
      "docker run -d ${local.bot_env} --name twitch_bot pingvin1308/cleannetcode.twitchbot:${var.image_version}",
      "docker container ls"
    ]
  }
}