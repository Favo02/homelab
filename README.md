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
- [services](./services/services)
    - [teamspeak](./services/services/teamspeak): Voice communication server 🎙️
    - [firefly](./services/services/firefly): Self-hosted personal finance manager 💶
    - [immich](./services/services/immich): Self-hosted Google Photo clone 📸
    - [linkding](./services/services/linkding): Bookmark manager 🔖
- [utils](./services/utils)
    - [authelia](./services/utils/authelia): Self-hosted 2FA authentication 🔒
    - [cloudflare](./services/utils/cloudflare): DDNS to automatically detect and update the public IP address 🌐
    - [gotify](./services/utils/gotify): Self-hosted push notification service 📲
    - [nginx](./services/utils/nginx): Reverse proxy server 🔄
    - [pihole](./services/utils/pihole): Network-wide ad blocker 🚫
    - [portainer](./services/utils/portainer): Lightweight management UI for Docker 🐳
    - [speedtest](./services/utils/speedtest): Self-hosted internet quality tracker 📶
    - [wireguard](./services/utils/wireguard): Fast and modern VPN protocol 🔒
- [websites](./services/websites)
    - [favo02dev](./services/websites/favo02dev): Personal website (React - [repo](https://github.com/favo02/favo02.dev)) 💻
    - [socialnetworkformusic](./services/websites/socialnetworkformusic): University project (React + Node + MongoDB - [repo](https://github.com/favo02/social-network-for-music)) 🎵
    - [superunimia](./services/websites/superunimia): University project (PHP + PostgreSQL - [repo](https://github.com/favo02/super-unimia)) 🎓
    - [seelabel](./services/websites/seelabel): Hackathon project (React + Python - [repo](https://github.com/favo02/see-label)) 🏷️
    - [cessadvisorapi](./services/websites/cessadvisorapi): Personal project (Svelte + OCaml - [repo](https://github.com/favo02/cess-advisor)) 🚽
