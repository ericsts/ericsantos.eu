# ericsantos.eu

> [🇺🇸 Read in English](README.en.md)

Site pessoal e portfólio de Eric Santos — desenvolvedor de software com mais de uma década de experiência em sistemas backend, DevOps e full stack. Hospeda projetos reais rodando em produção, construídos como laboratório de estudos e experimentação.

🌐 **Site:** [ericsantos.eu](https://ericsantos.eu)

## Sobre

Desenvolvedor com vasta experiência em construir produtos digitais do zero — desde modelagem de banco de dados e APIs REST até pipelines de CI/CD e orquestração de containers em produção. Apaixonado por arquitetura de software, boas práticas e automação.

| | |
|---|---|
| **Experiência** | 10+ anos |
| **Linguagem favorita** | Go |
| **Especialidades** | Backend · DevOps · Full Stack |

## Stack

| Área | Tecnologias |
|---|---|
| **Backend** | Go / Golang, PHP, Laravel, FilamentPHP, RabbitMQ, REST APIs, WebSockets |
| **Bancos de dados** | PostgreSQL, MySQL, MariaDB, SQLite |
| **Frontend** | Vue.js 3, JavaScript, TypeScript, Pinia, Vite, HTML/CSS |
| **DevOps** | Docker, Kubernetes, CI/CD, GitHub Actions, Git, Linux, nginx |

## Projetos

| Projeto | Descrição | Stack |
|---|---|---|
| [🚗 iCarros](https://icarros.ericsantos.eu) | Plataforma de leilões de carros em tempo real com WebSockets, JWT, RabbitMQ e notificações por e-mail | Go · Vue 3 · PostgreSQL · RabbitMQ · Docker |
| [🃏 Planning Poker](https://poker.ericsantos.eu) | Cards para sessões de Planning Scrum em tempo real | Go · Vue 3 · WebSocket · Docker |
| [⚓ Batalha Naval](https://battleship.ericsantos.eu) | Jogo multiplayer em tempo real via WebSockets — sem frameworks no frontend | Go · WebSocket · HTML/CSS/JS · Docker |
| [💰 Banco](https://banco.ericsantos.eu) | Extração e organização de extratos bancários (PDF) com assistente financeiro de IA | Python · FastAPI · Vue 3 · PostgreSQL · Docker |
| [📅 SchedulesYou](https://schedulesyou.com) | SaaS de agendamentos multi-tenant, com subdomínio dinâmico por empresa | Laravel · PostgreSQL · Redis · Docker |

## Estrutura do repositório

```
ericsantos.eu/
├── index.html          # site em português (principal)
├── index.en.html       # site em inglês
├── nginx/              # configurações nginx por subdomínio/domínio
│   ├── ericsantos.eu.conf
│   ├── icarros.ericsantos.eu.conf
│   ├── poker.ericsantos.eu.conf
│   ├── battleship.ericsantos.eu.conf
│   ├── banco.ericsantos.eu.conf
│   └── schedulesyou.com.conf
├── infra/               # Postgres/Redis/RabbitMQ compartilhados entre os
│   │                     projetos do droplet (ver infra/README.md)
│   ├── docker-compose.yml
│   └── postgres/init/
└── .github/
    └── workflows/
        └── deploy.yml  # deploy automático via GitHub Actions
```

## Deploy

Push na branch `main` dispara o GitHub Actions, que dá `git pull` no checkout do repo em `/opt/ericsantos.eu/` no servidor (o mesmo checkout de onde a stack de infra compartilhada é subida — veja `infra/README.md`).

As configurações nginx ficam em `nginx/` e precisam ser aplicadas manualmente no servidor quando houver mudanças (o que é raro).
