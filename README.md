# HomeLab

Configuration files for my **home laboratory** _(legacy config can be found in [docker-compose](https://github.com/Favo02/docker-compose) repository)_:

- [backup scripts](./scripts)
- [docker services](./services)

The services configured _(running and not)_ are:

- [databases](./services/databases)
    - [mongo](./services/databases/mongo): MongoDB NoSQL database server ☘️
    - [postgres](./services/databases/postgres/): PostgreSQL database server 🐘
- [games](./services/games)
    - [minecraft](./services/games/minecraft): Minecraft server 🎮
    - [teamspeak](./services/games/teamspeak): Voice communication server 🎙️
- [utils](./services/utils)
    - [authelia](./services/utils/authelia): Self-hosted 2FA authentication 🔒
    - [cloudflare](./services/utils/cloudflare): DDNS to automatically detect and update the public IP address 🌐
    - [firefly](./services/utils/firefly): Self-hosted personal finance manager 💶 
    - [gotify](./services/utils/gotify): Self-hosted push notification service 📲
    - [nginx](./services/utils/nginx): Reverse proxy server 🔄
    - [pihole](./services/utils/pihole): Network-wide ad blocker 🚫
    - [portainer](./services/utils/portainer): Lightweight management UI for Docker 🐳
    - [wireguard](./services/utils/wireguard): Fast and modern VPN protocol 🔒
- [websites](./services/websites)
    - [favo02dev](./services/websites/favo02dev): Personal website (React) 💻
    - [socialnetworkformusic](./services/websites/socialnetworkformusic): University project (React + Node + MongoDB) 🎵
    - [superunimia](./services/websites/superunimia): University project (PHP + PostgreSQL) 🎓
