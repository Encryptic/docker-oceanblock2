# [FTB OceanBlock 2-1.12.0](https://www.feed-the-beast.com/modpacks/128-ftb-oceanblock-2) from FTB.
<!-- toc -->

- [Description](#description)
- [Requirements](#requirements)
- [Options](#options)
  * [Adding Minecraft Operators](#adding-minecraft-operators)
- [Troubleshooting](#troubleshooting)
  * [Accept the EULA](#accept-the-eula)
  * [Permissions of Files](#permissions-of-files)
  * [Resetting](#resetting)

<!-- tocstop -->

## Description

This container is built to run on an [Unraid](https://unraid.net) server, outside of that your mileage will vary.

The docker on the first run will download the same version as tagged `FTB OceanBlock 2 10-2.39` and install it.  This can take a while as the Forge installer can take a bit to complete.  You can watch the logs and it will eventually finish.

After the first run, it will simply start the server.

Note: There are no modded Minecraft files shipped in the container, they are all downloaded at runtime.

## Requirements

* /data mounted to a persistent disk
* Port 25565/tcp mapped
* environment variable EULA set to "true"

As the end user, you are responsible for accepting the EULA from Mojang to run their server, by default in the container it is set to false.

## Options

These environment variables can be set to override their defaults.

* JVM_OPTS "-Xms2048m -Xmx4096m"
* MOTD "FTB OceanBlock 2 10-2.39 Server Powered by Docker"
* ALLOW_FLIGHT "true" or "false"
* MAX_PLAYERS "5"
* ONLINE_MODE "true" or "false"
* ENABLE_WHITELIST "true" or "false"
* WHITELIST_USERS "TestUserName1, TestUserName2"
* OP_USERS "TestUserName1, TestUserName2"

## Troubleshooting

### Accept the EULA
Did you pass in the environment variable EULA set to `true`?

### Permissions of Files
This container is designed for [Unraid](https://unraid.net) so the user in the container runs on uid 99 and gid 100.  This may cause permission errors on the /data mount on other systems.

### Resetting
If the installation is incomplete for some reason.  Deleting the downloaded server file in /data will restart the install/upgrade process.

## Inspirted by: 
Github: https://github.com/Goobaroo/docker-allthemods10
