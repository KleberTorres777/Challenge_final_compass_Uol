# Testes Backend - Cinema Challenge

## Visão Geral
Esta pasta contém os testes automatizados para a API do Cinema Challenge, implementados usando Robot Framework. Os testes cobrem todas as funcionalidades principais da aplicação, incluindo autenticação, gerenciamento de filmes, sessões, teatros, usuários e reservas.

## Estrutura dos Testes

### Arquivos de Teste
- **auth.robot** - Testes de autenticação (registro, login, perfil)
- **movies.robot** - Testes de gerenciamento de filmes
- **sessions.robot** - Testes de sessões de cinema
- **theaters.robot** - Testes de gerenciamento de teatros
- **users.robot** - Testes de gerenciamento de usuários
- **reservations.robot** - Testes de reservas

### Arquivos de Suporte
- **../variaveis/base.robot** - Configurações base e sessão da API
- **../resources/** - Keywords reutilizáveis para cada módulo
- **../libs/database.py** - Funções para manipulação do banco de dados

## Pré-requisitos

### Dependências
```bash
pip install robotframework
pip install robotframework-requests
pip install robotframework-faker
```

### Configuração
- API rodando em `http://localhost:3000/api/v1`
- Banco de dados configurado e acessível
- Usuário admin pré-cadastrado no sistema

## Execução dos Testes

### Executar todos os testes
```bash
robot tests/
```

### Executar testes específicos
```bash
# Testes de autenticação
robot tests/auth.robot

# Testes de filmes
robot tests/movies.robot

# Testes por tag
robot --include POST tests/
robot --include GET tests/
```

### Executar com relatórios
```bash
robot --outputdir logs tests/
```

## Cobertura de Testes

### Autenticação (auth.robot)
- ✅ Cadastro de usuário (201, 400 - duplicado, validações)
- ✅ Login (200, 401 - credenciais inválidas)
- ✅ Verificação de perfil (200, 401 - token inválido)
- ✅ Atualização de perfil (200, 401 - senha incorreta)

### Filmes (movies.robot)
- ✅ Listagem com filtros e paginação (200)
- ✅ Busca por ID (200, 400, 404)
- ✅ Cadastro (201 - admin, 401 - sem token/token inválido)
- ✅ Atualização (200, 401, 404)
- ✅ Exclusão (200, 401, 404)

### Sessões (sessions.robot)
- ✅ Listagem com filtros (200)
- ✅ Busca por ID (200, 400, 404)
- ✅ Cadastro (201, 401, 404, 400)
- ✅ Atualização (200, 401, 404, 409)
- ✅ Reset de assentos (200, 401, 404)
- ✅ Exclusão (200, 401, 404, 409)

### Teatros (theaters.robot)
- ✅ Listagem com filtros e ordenação (200)
- ✅ Busca por ID (200, 400, 404)
- ✅ Cadastro (201, 401, 400)
- ✅ Atualização (200, 401, 404, 409)
- ✅ Exclusão (401, 404, 409)

### Usuários (users.robot)
- ✅ Listagem com filtros (200, 401)
- ✅ Busca por ID (200, 401, 400, 404)
- ✅ Atualização (200, 401, 404, 409)
- ✅ Exclusão (200, 401, 404, 409)

### Reservas (reservations.robot)
- ⚠️ Cadastro (400 - issue na API)
- ✅ Listagem pessoal (200, 401)
- ✅ Listagem admin (200, 401, 403)
- ✅ Busca por ID (200, 401, 404)
- ✅ Atualização (200, 401, 403, 404)
- ✅ Exclusão (401, 403, 404)

## Issues Conhecidas

### Problemas Identificados
1. **Reservas**: API retorna 400 em vez de 201 no cadastro
2. **Validações**: Algumas validações de dados podem estar inconsistentes
3. **Conflitos**: Alguns cenários de conflito (409) podem não estar funcionando corretamente

### Tags de Issues
- `issue` - Marca testes que identificaram problemas na API
- `validation` - Testes de validação de dados
- `auth` - Testes relacionados à autenticação
- `pagination` - Testes de paginação

## Estrutura de Tags

### Por Método HTTP
- `GET` - Testes de consulta
- `POST` - Testes de criação
- `PUT` - Testes de atualização
- `DELETE` - Testes de exclusão

### Por Funcionalidade
- `auth` - Autenticação
- `movies` - Filmes
- `sessions` - Sessões
- `theaters` - Teatros
- `users` - Usuários
- `reservations` - Reservas

### Por Tipo
- `filter` - Testes com filtros
- `sort` - Testes de ordenação
- `pagination` - Testes de paginação
- `complex` - Testes com múltiplos parâmetros

## Relatórios

Os relatórios são gerados na pasta `logs/`:
- **log.html** - Log detalhado da execução
- **report.html** - Relatório resumido
- **output.xml** - Dados em XML para integração

## Manutenção

### Limpeza de Dados
Os testes incluem limpeza automática do banco de dados para evitar interferências entre execuções.

### Dados de Teste
- Usuários e dados são criados dinamicamente
- Cleanup automático após cada teste
- IDs fixos para testes de erro (404, etc.)

## Contribuição

Para adicionar novos testes:
1. Crie keywords no arquivo resource correspondente
2. Adicione cenários no arquivo de teste apropriado
3. Use tags adequadas para categorização
4. Inclua limpeza de dados quando necessário