# ericsantos.eu

> [🇧🇷 Leia em Português](README.md)

Personal website and portfolio of Eric Santos — a software developer with over a decade of experience in backend systems, DevOps, and full stack development. Hosts real projects running in production, built as a study lab and technology playground.

🌐 **Website:** [ericsantos.eu](https://ericsantos.eu)

## About

Developer with extensive experience building digital products from scratch — from database modeling and REST APIs to CI/CD pipelines and container orchestration in production. Passionate about software architecture, best practices, and automation.

| | |
|---|---|
| **Experience** | 10+ years |
| **Favorite language** | Go |
| **Specialties** | Backend · DevOps · Full Stack |

## Stack

| Area | Technologies |
|---|---|
| **Backend** | Go / Golang, PHP, Laravel, FilamentPHP, RabbitMQ, REST APIs, WebSockets |
| **Databases** | PostgreSQL, MySQL, MariaDB, SQLite |
| **Frontend** | Vue.js 3, JavaScript, TypeScript, Pinia, Vite, HTML/CSS |
| **DevOps** | Docker, Kubernetes, CI/CD, GitHub Actions, Git, Linux, nginx |

## Projects

| Project | Description | Stack |
|---|---|---|
| [🚗 iCarros](https://icarros.ericsantos.eu) | Real-time car auction platform with WebSockets, JWT auth, RabbitMQ queues, and email notifications | Go · Vue 3 · PostgreSQL · RabbitMQ · Docker |
| [🃏 Planning Poker](https://poker.ericsantos.eu) | Real-time Scrum planning cards for agile teams | Go · Vue 3 · WebSocket · Docker |
| [⚓ Battleship](https://battleship.ericsantos.eu) | Real-time multiplayer naval battle game via WebSockets — no frontend frameworks | Go · WebSocket · HTML/CSS/JS · Docker |

## Repository structure

```
ericsantos.eu/
├── index.html          # Portuguese site (primary)
├── index.en.html       # English site
├── nginx/              # per-subdomain nginx configs
│   ├── ericsantos.eu.conf
│   ├── icarros.ericsantos.eu.conf
│   ├── poker.ericsantos.eu.conf
│   └── battleship.ericsantos.eu.conf
└── .github/
    └── workflows/
        └── deploy.yml  # automatic deploy via GitHub Actions
```

## Deploy

A push to the `main` branch triggers GitHub Actions, which copies `index.html` (and `index.en.html`) to `/var/www/ericsantos.eu/` on the server via SCP.

The nginx configs in `nginx/` are applied manually on the server when changed (which is rare).
