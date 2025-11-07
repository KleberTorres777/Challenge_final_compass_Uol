# Cinema Challenge

Sistema de cinema com funcionalidades completas de reserva de ingressos, incluindo autenticação de usuários, seleção de filmes, sessões e assentos.

## 📋 Visão Geral

O Cinema Challenge é uma aplicação web completa que permite aos usuários:
- Fazer login e cadastro
- Visualizar filmes disponíveis
- Selecionar sessões e assentos
- Realizar reservas de ingressos
- Gerenciar perfil de usuário

## 🏗️ Arquitetura

```
cinema-challenge/
├── back/           # Backend API (Node.js)
├── front/          # Frontend Web Application
└── README.md       # Este arquivo
```

### Backend
- **API REST** rodando em `localhost:3000`
- Endpoints para autenticação, filmes, sessões, teatros, usuários e reservas
- Banco de dados com limpeza automática para testes

### Frontend
- **Aplicação Web** rodando em `localhost:3002`
- Interface responsiva para interação do usuário
- Integração completa com a API backend

## 🧪 Testes Automatizados

O projeto possui suítes de testes abrangentes usando **Robot Framework**:

### Backend Tests (`/back/tests/`)
- **Framework**: Robot Framework + RequestsLibrary
- **Cobertura**: API endpoints, autenticação, CRUD operations
- **Execução**: `robot -d logs tests/`
- [📖 Documentação completa](back/README.md)

### Frontend Tests (`/front/tests/`)
- **Framework**: Robot Framework + Browser Library (Playwright)
- **Cobertura**: UI/UX, fluxos E2E, validações visuais
- **Execução**: `robot -d logs tests/`
- [📖 Documentação completa](front/README.md)

## 🚀 Como Executar

### Pré-requisitos
- Node.js
- Python 3.x
- Robot Framework
- RequestsLibrary (backend tests)
- Browser Library (frontend tests)

### Executar Aplicação
1. **Backend**: Iniciar API em `localhost:3000`
2. **Frontend**: Iniciar aplicação em `localhost:3002`

### Executar Testes
```bash
# Backend Tests
cd back
robot -d logs tests/

# Frontend Tests  
cd front
robot -d logs tests/
```

## 📊 Relatórios

Após execução dos testes, relatórios são gerados em:
- `back/logs/` - Relatórios dos testes de API
- `front/logs/` - Relatórios dos testes de UI

## 📁 Estrutura de Testes

### Backend
- `auth.robot` - Autenticação e autorização
- `movies.robot` - Gerenciamento de filmes
- `sessions.robot` - Sessões de cinema
- `theaters.robot` - Salas de cinema
- `users.robot` - Usuários do sistema
- `reservations.robot` - Reservas de ingressos

### Frontend
- `login.robot` - Tela de login
- `cadastro.robot` - Cadastro de usuários
- `movies.robot` - Listagem de filmes
- `assentos.robot` - Seleção de assentos
- `fluxo_completo.robot` - Jornada completa do usuário
- `cobertura_elementos.robot` - Validação de elementos UI

## 🏷️ Tags de Teste

- `smoke` - Testes críticos básicos
- `regression` - Testes de regressão
- `crud` - Operações Create, Read, Update, Delete
- `auth` - Testes de autenticação
- `ui` - Testes de interface
- `e2e` - Testes end-to-end

## 📋 Status dos Testes

### ✅ Funcionalidades Testadas
- Autenticação completa (login/logout)
- CRUD de filmes, usuários, sessões, teatros
- Fluxo completo de compra
- Validações de UI/UX

### ⚠️ Issues Conhecidas
- Reservas: retorno 400 em vez de 201 (backend)
- Mensagens de sucesso inconsistentes (frontend)

## 🔧 Manutenção

Para atualizações e manutenção dos testes, consulte:
- [Backend Test Documentation](back/README.md)
- [Frontend Test Documentation](front/README.md)

---

**Desenvolvido para garantir qualidade e confiabilidade do sistema Cinema Challenge**