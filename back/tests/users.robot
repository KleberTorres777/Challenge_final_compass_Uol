*** Settings ***
Resource    ../variaveis/base.robot
Resource    ../resources/users.resource

Library    RequestsLibrary
Library    Collections

Suite Setup    Criar a sessão

*** Test Cases ***
Cenario: GET Users Com Token Admin 200
    [Tags]    GET    users
    Criar Admin Para Teste
    Fazer Login Admin
    GET Users Com Token    ${ADMIN_TOKEN}    200
    Validar Users Sucesso

Cenario: GET Users Sem Token 401
    [Tags]    GET    users
    GET Users Sem Token    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: GET Users Token Invalido 401
    [Tags]    GET    users
    GET Users Com Token    token_invalido    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: GET Users Com Filtro Por Role User
    [Tags]    GET    users    filter
    Criar Admin Para Teste
    Fazer Login Admin
    ${params}=    Create Dictionary    role=user
    GET Users Com Parametros    ${ADMIN_TOKEN}    ${params}    200
    Validar Users Sucesso

Cenario: GET Users Com Filtro Por Role Admin
    [Tags]    GET    users    filter
    Criar Admin Para Teste
    Fazer Login Admin
    ${params}=    Create Dictionary    role=admin
    GET Users Com Parametros    ${ADMIN_TOKEN}    ${params}    200
    Validar Users Sucesso

Cenario: GET Users Com Page
    [Tags]    GET    users    pagination
    Criar Admin Para Teste
    Fazer Login Admin
    ${params}=    Create Dictionary    page=2
    GET Users Com Parametros    ${ADMIN_TOKEN}    ${params}    200
    Validar Users Sucesso

Cenario: GET Users Com Limit
    [Tags]    GET    users    pagination
    Criar Admin Para Teste
    Fazer Login Admin
    ${params}=    Create Dictionary    limit=5
    GET Users Com Parametros    ${ADMIN_TOKEN}    ${params}    200
    Validar Users Sucesso

Cenario: GET Users Com Multiplos Parametros
    [Tags]    GET    users    complex
    Criar Admin Para Teste
    Fazer Login Admin
    ${params}=    Create Dictionary    
    ...    role=user
    ...    limit=5
    ...    page=1
    GET Users Com Parametros    ${ADMIN_TOKEN}    ${params}    200
    Validar Users Sucesso

Cenario: GET User Por ID Valido 200
    [Tags]    GET    user    id
    Criar Admin Para Teste
    Fazer Login Admin
    # Buscar um user existente
    GET Users Com Token    ${ADMIN_TOKEN}    200
    ${user_id}=    Set Variable    ${RESPONSE.json()['data'][0]['_id']}
    GET User Por ID Com Token    ${user_id}    ${ADMIN_TOKEN}    200
    Validar User Por ID Sucesso

Cenario: GET User Por ID Sem Token 401
    [Tags]    GET    user    id
    GET User Por ID Sem Token    68dc716c050c98523bcd9f90    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: GET User Por ID Token Invalido 401
    [Tags]    GET    user    id
    GET User Por ID Com Token    68dc716c050c98523bcd9f90    token_invalido    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: GET User Por ID Invalido 400
    [Tags]    GET    user    id
    Criar Admin Para Teste
    Fazer Login Admin
    GET User Por ID Com Token    id_invalido    ${ADMIN_TOKEN}    400
    Should Be Equal As Strings    ${RESPONSE.status_code}    400
    Validar User Erro

Cenario: GET User Por ID Inexistente 404
    [Tags]    GET    user    id
    Criar Admin Para Teste
    Fazer Login Admin
    GET User Por ID Com Token    60d0fe4f5311236168a109cc    ${ADMIN_TOKEN}    404
    Should Be Equal As Strings    ${RESPONSE.status_code}    404
    Validar User Erro

Cenario: PUT User Com Sucesso 200
    [Tags]    PUT    user
    Criar Admin Para Teste
    Fazer Login Admin
    # Buscar um user existente
    GET Users Com Token    ${ADMIN_TOKEN}    200
    ${user_id}=    Set Variable    ${RESPONSE.json()['data'][0]['_id']}
    ${user_data}=    Create Dictionary
    ...    name=User Atualizado
    ...    email=user.atualizado@example.com
    ...    role=user
    PUT User Com Token    ${user_id}    ${ADMIN_TOKEN}    ${user_data}    200
    Validar User Atualizado Sucesso

Cenario: PUT User Sem Token 401
    [Tags]    PUT    user
    ${user_data}=    Create Dictionary
    ...    name=User Atualizado
    ...    email=user.atualizado@example.com
    ...    role=user
    PUT User Sem Token    68dc716c050c98523bcd9f90    ${user_data}    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: PUT User Token Invalido 401
    [Tags]    PUT    user
    ${user_data}=    Create Dictionary
    ...    name=User Atualizado
    ...    email=user.atualizado@example.com
    ...    role=user
    PUT User Com Token    68dc716c050c98523bcd9f90    token_invalido    ${user_data}    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: PUT User ID Inexistente 404
    [Tags]    PUT    user
    Criar Admin Para Teste
    Fazer Login Admin
    ${user_data}=    Create Dictionary
    ...    name=User Atualizado
    ...    email=user.atualizado@example.com
    ...    role=user
    PUT User Com Token    60d0fe4f5311236168a109cc    ${ADMIN_TOKEN}    ${user_data}    404
    Should Be Equal As Strings    ${RESPONSE.status_code}    404
    Validar User Erro

Cenario: PUT User Email Ja Existe 409
    [Tags]    PUT    user    issue
    Criar Admin Para Teste
    Fazer Login Admin
    # Buscar um user existente
    GET Users Com Token    ${ADMIN_TOKEN}    200
    ${user_id}=    Set Variable    ${RESPONSE.json()['data'][1]['_id']}
    ${user_data}=    Create Dictionary
    ...    name=User Atualizado
    ...    email=admin@example.com
    ...    role=user
    PUT User Com Token    ${user_id}    ${ADMIN_TOKEN}    ${user_data}    409
    Should Be Equal As Strings    ${RESPONSE.status_code}    409
    Validar User Erro

Cenario: DELETE User Com Sucesso 200
    [Tags]    DELETE    user
    Criar Admin Para Teste
    Fazer Login Admin
    Criar User Para Teste
    # Buscar o user criado
    GET Users Com Token    ${ADMIN_TOKEN}    200
    ${users}=    Set Variable    ${RESPONSE.json()['data']}
    ${user_id}=    Set Variable    ${users[0]['_id']}
    DELETE User Com Token    ${user_id}    ${ADMIN_TOKEN}    200
    Validar User Deletado Sucesso

Cenario: DELETE User Sem Token 401
    [Tags]    DELETE    user
    DELETE User Sem Token    68dc716c050c98523bcd9f90    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: DELETE User Token Invalido 401
    [Tags]    DELETE    user
    DELETE User Com Token    68dc716c050c98523bcd9f90    token_invalido    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: DELETE User ID Inexistente 404
    [Tags]    DELETE    user
    # Verificar se a API está respondendo
    ${health_response}=    GET On Session    api    /    expected_status=any
    Log    Status da API: ${health_response.status_code}
    Criar Admin Para Teste
    Fazer Login Admin
    ${login_response}=    Set Variable    ${RESPONSE}
    Should Be Equal As Strings    ${login_response.status_code}    200    Login do admin deve ter sucesso
    DELETE User Com Token    60d0fe4f5311236168a109cc    ${ADMIN_TOKEN}    404
    Should Be Equal As Strings    ${RESPONSE.status_code}    404
    Validar User Erro

Cenario: DELETE User Com Reservas Ativas 409
    [Tags]    DELETE    user    issue
    Criar Admin Para Teste
    Fazer Login Admin
    # Usar um user existente que pode ter reservas
    GET Users Com Token    ${ADMIN_TOKEN}    200
    ${user_id}=    Set Variable    ${RESPONSE.json()['data'][0]['_id']}
    DELETE User Com Token    ${user_id}    ${ADMIN_TOKEN}    409
    Should Be Equal As Strings    ${RESPONSE.status_code}    409
    Validar User Erro