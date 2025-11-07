*** Settings ***
Resource    ../variaveis/base.robot
Resource    ../resources/theaters.resource

Library    RequestsLibrary
Library    Collections

Suite Setup    Criar a sessão

*** Test Cases ***
Cenario: POST Cadastrar Theater 201
    [Tags]    POST    theater
    Criar Admin Para Teste
    Fazer Login Admin
    POST Cadastrar Theater    ${ADMIN_TOKEN}
    Should Be Equal As Strings    ${RESPONSE.status_code}    201
    Validar Theater Criado Sucesso

Cenario: POST Theater Sem Token 401
    [Tags]    POST    theater
    ${theater_data}=    Create Dictionary
    ...    name=Theater Teste
    ...    capacity=80
    ...    type=IMAX
    POST Theater Sem Token    ${theater_data}    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: POST Theater Token Invalido 401
    [Tags]    POST    theater
    ${theater_data}=    Create Dictionary
    ...    name=Theater Teste
    ...    capacity=80
    ...    type=IMAX
    POST Theater Com Token    token_invalido    ${theater_data}    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: POST Theater Dados Invalidos 400
    [Tags]    POST    theater
    Criar Admin Para Teste
    Fazer Login Admin
    ${theater_data}=    Create Dictionary
    ...    name=
    ...    capacity=0
    POST Theater Com Token    ${ADMIN_TOKEN}    ${theater_data}    400
    Should Be Equal As Strings    ${RESPONSE.status_code}    400
    Validar Theater Erro

Cenario: GET Theaters Sem Parametros 200
    [Tags]    GET    theaters
    GET Theaters Sem Parametros    200
    Validar Theaters Sucesso

Cenario: GET Theaters Com Filtro Por Type
    [Tags]    GET    theaters    filter
    ${params}=    Create Dictionary    type=IMAX
    GET Theaters Com Parametros    ${params}    200
    Validar Theaters Sucesso

Cenario: GET Theaters Com Sort Por Name
    [Tags]    GET    theaters    sort
    ${params}=    Create Dictionary    sort=name
    GET Theaters Com Parametros    ${params}    200
    Validar Theaters Sucesso

Cenario: GET Theaters Com Sort Por Capacity
    [Tags]    GET    theaters    sort
    ${params}=    Create Dictionary    sort=capacity
    GET Theaters Com Parametros    ${params}    200
    Validar Theaters Sucesso

Cenario: GET Theaters Com Page
    [Tags]    GET    theaters    pagination
    ${params}=    Create Dictionary    page=2
    GET Theaters Com Parametros    ${params}    200
    Validar Theaters Sucesso

Cenario: GET Theaters Com Multiplos Parametros
    [Tags]    GET    theaters    complex
    ${params}=    Create Dictionary    
    ...    type=standard
    ...    sort=name
    ...    limit=5
    ...    page=1
    GET Theaters Com Parametros    ${params}    200
    Validar Theaters Sucesso

Cenario: GET Theater Por ID Valido 200
    [Tags]    GET    theater    id
    # Primeiro buscar theaters existentes
    GET Theaters Sem Parametros    200
    ${theaters}=    Set Variable    ${RESPONSE.json()['data']}
    ${theater_id}=    Run Keyword If    ${theaters}
    ...    Set Variable    ${theaters[0]['_id']}
    ...    ELSE    Set Variable    60d0fe4f5311236168a109cc
    # Se não há theaters, o teste deve retornar 404
    ${expected_status}=    Run Keyword If    ${theaters}    Set Variable    200    ELSE    Set Variable    404
    GET Theater Por ID    ${theater_id}    ${expected_status}
    Run Keyword If    '${expected_status}' == '200'    Validar Theater Por ID Sucesso
    ...    ELSE    Validar Theater Erro

Cenario: GET Theater Por ID Invalido 400
    [Tags]    GET    theater    id    issue
    GET Theater Por ID    id_invalido    400
    Should Be Equal As Strings    ${RESPONSE.status_code}    400
    Validar Theater Erro

Cenario: GET Theater Por ID Inexistente 404
    [Tags]    GET    theater    id
    GET Theater Por ID    60d0fe4f5311236168a109cc    404
    Should Be Equal As Strings    ${RESPONSE.status_code}    404
    Validar Theater Erro

Cenario: PUT Theater Com Sucesso 200
    [Tags]    PUT    theater
    Criar Admin Para Teste
    Fazer Login Admin
    # Primeiro buscar theaters existentes
    GET Theaters Sem Parametros    200
    ${theaters}=    Set Variable    ${RESPONSE.json()['data']}
    ${theater_id}=    Run Keyword If    ${theaters}
    ...    Set Variable    ${theaters[0]['_id']}
    ...    ELSE    Set Variable    60d0fe4f5311236168a109cc
    ${theater_data}=    Create Dictionary
    ...    name=Theater Atualizado
    ...    capacity=150
    ...    type=VIP
    # Se não há theaters, o teste deve retornar 404
    ${expected_status}=    Run Keyword If    ${theaters}    Set Variable    200    ELSE    Set Variable    404
    PUT Theater Com Token    ${theater_id}    ${ADMIN_TOKEN}    ${theater_data}    ${expected_status}
    Run Keyword If    '${expected_status}' == '200'    Validar Theater Atualizado Sucesso
    ...    ELSE    Validar Theater Erro

Cenario: PUT Theater Sem Token 401
    [Tags]    PUT    theater
    ${theater_data}=    Create Dictionary
    ...    name=Theater Atualizado
    ...    capacity=150
    ...    type=VIP
    PUT Theater Sem Token    68dc716d050c98523bcd9f97    ${theater_data}    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: PUT Theater Token Invalido 401
    [Tags]    PUT    theater
    ${theater_data}=    Create Dictionary
    ...    name=Theater Atualizado
    ...    capacity=150
    ...    type=VIP
    PUT Theater Com Token    68dc716d050c98523bcd9f97    token_invalido    ${theater_data}    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: PUT Theater ID Inexistente 404
    [Tags]    PUT    theater
    Criar Admin Para Teste
    Fazer Login Admin
    ${theater_data}=    Create Dictionary
    ...    name=Theater Atualizado
    ...    capacity=150
    ...    type=VIP
    PUT Theater Com Token    60d0fe4f5311236168a109cc    ${ADMIN_TOKEN}    ${theater_data}    404
    Should Be Equal As Strings    ${RESPONSE.status_code}    404
    Validar Theater Erro

Cenario: PUT Theater Nome Ja Existe 409
    [Tags]    PUT    theater    issue
    Criar Admin Para Teste
    Fazer Login Admin
    ${theater_data}=    Create Dictionary
    ...    name=Theater 1
    ...    capacity=150
    ...    type=VIP
    PUT Theater Com Token    68dc716d050c98523bcd9f98    ${ADMIN_TOKEN}    ${theater_data}    409
    Should Be Equal As Strings    ${RESPONSE.status_code}    409
    Validar Theater Erro

Cenario: DELETE Theater ID Inexistente 404
    [Tags]    DELETE    theater    issue
    Criar Admin Para Teste
    Fazer Login Admin
    # Como não há theaters no sistema, testar com ID inexistente retorna 404
    DELETE Theater Com Token    60d0fe4f5311236168a109cc    ${ADMIN_TOKEN}    404
    Should Be Equal As Strings    ${RESPONSE.status_code}    404
    Validar Theater Erro

Cenario: DELETE Theater Sem Token 401
    [Tags]    DELETE    theater
    DELETE Theater Sem Token    68dc716d050c98523bcd9f97    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: DELETE Theater Token Invalido 401
    [Tags]    DELETE    theater
    DELETE Theater Com Token    68dc716d050c98523bcd9f97    token_invalido    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: DELETE Theater Com Sessoes Ativas 409
    [Tags]    DELETE    theater    issue
    Criar Admin Para Teste
    Fazer Login Admin
    DELETE Theater Com Token    68dc716d050c98523bcd9f97    ${ADMIN_TOKEN}    409
    Should Be Equal As Strings    ${RESPONSE.status_code}    409
    Validar Theater Erro