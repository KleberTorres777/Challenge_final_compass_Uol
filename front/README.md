# Testes Frontend - Cinema Challenge

## Visão Geral
Esta pasta contém os testes automatizados para o frontend do Cinema Challenge, implementados usando Robot Framework com Browser Library. Os testes cobrem todas as funcionalidades principais da interface, incluindo cadastro, login, navegação de filmes, seleção de assentos e fluxo completo de compra.

## Estrutura dos Testes

### Arquivos de Teste
- **login.robot** - Testes de autenticação e login
- **cadastro.robot** - Testes de cadastro de usuários
- **movies.robot** - Testes de navegação e visualização de filmes
- **assentos.robot** - Testes de seleção de assentos
- **fluxo_completo.robot** - Testes de fluxo end-to-end de compra
- **cobertura_elementos.robot** - Verificação de elementos UI

### Arquivos de Suporte
- **../resources/base.resource** - Configurações base e sessão do browser
- **../resources/env.resource** - Variáveis de ambiente
- **../resources/pages/** - Page Objects para cada tela
- **../resources/libs/database.py** - Funções para manipulação do banco de dados

## Pré-requisitos

### Dependências
```bash
pip install robotframework
pip install robotframework-browser
pip install playwright
```

### Inicialização do Browser Library
```bash
rfbrowser init
```

### Configuração
- Frontend rodando em `http://localhost:3002`
- Backend API rodando em `http://localhost:3000/api/v1`
- Banco de dados configurado e acessível

## Execução dos Testes

### Executar todos os testes
```bash
robot tests/
```

### Executar testes específicos
```bash
# Testes de login
robot tests/login.robot

# Testes de cadastro
robot tests/cadastro.robot

# Fluxo completo
robot tests/fluxo_completo.robot
```

### Executar com relatórios
```bash
robot --outputdir logs tests/
```

### Executar em modo headless
```bash
robot --variable HEADLESS:True tests/
```

## Cobertura de Testes

### Login (login.robot)
- ✅ Login com credenciais válidas
- ✅ Validação de senha inválida
- ✅ Validação de email inexistente
- ✅ Verificação de mensagens de erro

### Cadastro (cadastro.robot)
- ✅ Cadastro de novo usuário
- ✅ Validação de email duplicado
- ✅ Validação de campos obrigatórios
- ✅ Validação de senha muito curta

### Filmes (movies.robot)
- ✅ Visualização de detalhes do filme "The Avengers"
- ✅ Visualização de detalhes do filme "Inception"
- ✅ Visualização de detalhes do filme "The Shawshank Redemption"
- ✅ Navegação entre filmes

### Assentos (assentos.robot)
- ✅ Seleção de todos os assentos disponíveis
- ✅ Fluxo completo: login → filme → sessão → assentos

### Fluxo Completo (fluxo_completo.robot)
- ✅ Compra com cartão de crédito
- ✅ Compra com cartão de débito
- ✅ Compra com PIX
- ✅ Compra com transferência bancária
- ✅ Fluxo: cadastro → login → filme → sessão → assento → pagamento

### Cobertura de Elementos (cobertura_elementos.robot)
- ✅ Verificação de elementos da página de cadastro
- ✅ Verificação de elementos da página de login
- ✅ Verificação de elementos da página de filmes

## Arquitetura dos Testes

### Page Objects
- **LoginPage.resource** - Elementos e ações da página de login
- **CadastroPage.resource** - Elementos e ações da página de cadastro
- **MoviesPage.resource** - Elementos e ações da página de filmes
- **AssentosPage.resource** - Elementos e ações da seleção de assentos
- **CinemaFlow.resource** - Fluxo completo de compra
- **Notice.resource** - Validação de mensagens e notificações

### Configurações
- **base.resource** - Setup do browser e configurações gerais
- **env.resource** - URLs e variáveis de ambiente

## Funcionalidades Testadas

### Autenticação
- Login com credenciais válidas/inválidas
- Cadastro de novos usuários
- Validações de formulário

### Navegação
- Listagem de filmes
- Detalhes de filmes específicos
- Navegação entre páginas

### Seleção de Assentos
- Visualização de assentos disponíveis
- Seleção múltipla de assentos
- Validação de assentos ocupados

### Processo de Compra
- Seleção de sessão
- Escolha de assentos
- Métodos de pagamento (crédito, débito, PIX, transferência)
- Finalização da compra

## Screenshots e Evidências

### Captura Automática
- Screenshot automático após cada teste (Test Teardown)
- Evidências salvas na pasta `browser/screenshot/`
- Traces do Playwright para debug

### Localização dos Arquivos
```
logs/
├── browser/
│   ├── screenshot/
│   └── traces/
├── log.html
├── report.html
└── output.xml
```

## Dados de Teste

### Usuários de Teste
- Criação dinâmica de usuários para cada teste
- Limpeza automática do banco antes/depois dos testes
- IDs fixos para filmes e sessões existentes

### Gerenciamento de Estado
- Cada teste é independente
- Cleanup automático de dados
- Isolamento entre execuções

## Configuração do Browser

### Padrão
- Browser: Chromium
- Modo: Headless=False (visual)
- URL Base: http://localhost:3002

### Personalização
```robot
# No base.resource
New Browser    browser=chromium    headless=False
New Page    ${BASE_URL}
```

## Issues Conhecidas

### Problemas Identificados
1. **Login**: Mensagem de sucesso pode não aparecer consistentemente
2. **Assentos**: Seleção múltipla pode ter delay visual
3. **Pagamento**: Validação de métodos de pagamento pode variar

## Manutenção

### Limpeza de Dados
- Remoção automática de usuários de teste
- Reset de estado entre testes
- Verificação de elementos antes das ações

### Estabilidade
- Waits explícitos para elementos
- Verificação de estado dos elementos
- Retry automático em falhas temporárias

## Contribuição

Para adicionar novos testes:
1. Crie page objects no diretório `resources/pages/`
2. Adicione cenários no arquivo de teste apropriado
3. Use keywords reutilizáveis
4. Inclua limpeza de dados quando necessário
5. Adicione screenshots para evidências