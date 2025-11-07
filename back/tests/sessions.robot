*** Settings ***
Resource    ../variaveis/base.robot
Resource    ../resources/sessions.resource

Library    RequestsLibrary
Library    Collections

Suite Setup    Criar a sessão

*** Test Cases ***
Cenario: POST Cadastrar Session 201
    [Tags]    POST    session
    Criar Admin Para Teste
    Fazer Login Admin
    
    # Criar movie com todos os campos necessários
    ${genres_list}=    Create List    Action    Adventure
    ${movie_data}=    Create Dictionary
    ...    title=Filme Session Test
    ...    synopsis=Sinopse do filme para teste de session
    ...    director=Diretor Teste
    ...    genres=${genres_list}
    ...    duration=120
    ...    classification=PG-13
    ...    poster=poster_session_test.jpg
    ...    releaseDate=2024-12-01
    POST Movie Com Token    ${ADMIN_TOKEN}    ${movie_data}    201
    ${movie_id}=    Set Variable    ${RESPONSE.json()['data']['_id']}
    
    # Criar theater com todos os campos necessários
    ${theater_data}=    Create Dictionary
    ...    name=Teatro Session Test
    ...    location=Local Session Test
    ...    capacity=100
    ...    type=standard
    POST Theater Com Token    ${ADMIN_TOKEN}    ${theater_data}    201
    ${theater_id}=    Set Variable    ${RESPONSE.json()['data']['_id']}
    
    # Criar session com movie e theater válidos
    ${session_data}=    Create Dictionary
    ...    movie=${movie_id}
    ...    theater=${theater_id}
    ...    datetime=2025-12-20T18:30:00.000Z
    ...    fullPrice=20
    ...    halfPrice=10
    POST Session Com Token    ${ADMIN_TOKEN}    ${session_data}    201
    Should Be Equal As Strings    ${RESPONSE.status_code}    201
    Validar Session Criada Sucesso

Cenario: POST Session Sem Token 401
    [Tags]    POST    session
    ${session_data}=    Create Dictionary
    ...    movie=68dc716c050c98523bcd9f94
    ...    theater=60d0fe4f5311236168a109cc
    ...    datetime=2025-12-20T19:00:00.000Z
    ...    fullPrice=25
    ...    halfPrice=12
    POST Session Sem Token    ${session_data}    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: POST Session Token Invalido 401
    [Tags]    POST    session
    ${session_data}=    Create Dictionary
    ...    movie=68dc716c050c98523bcd9f94
    ...    theater=60d0fe4f5311236168a109cc
    ...    datetime=2025-12-20T20:00:00.000Z
    ...    fullPrice=25
    ...    halfPrice=12
    POST Session Com Token    token_invalido    ${session_data}    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: POST Session Movie Inexistente 404
    [Tags]    POST    session
    Criar Admin Para Teste
    Fazer Login Admin
    ${session_data}=    Create Dictionary
    ...    movie=60d0fe4f5311236168a109cc
    ...    theater=60d0fe4f5311236168a109cc
    ...    datetime=2025-12-20T21:00:00.000Z
    ...    fullPrice=25
    ...    halfPrice=12
    POST Session Com Token    ${ADMIN_TOKEN}    ${session_data}    404
    Should Be Equal As Strings    ${RESPONSE.status_code}    404
    Validar Session Erro

Cenario: POST Session Dados Invalidos 400
    [Tags]    POST    session
    Criar Admin Para Teste
    Fazer Login Admin
    ${session_data}=    Create Dictionary
    ...    movie=
    ...    theater=
    ...    fullPrice=0
    POST Session Com Token    ${ADMIN_TOKEN}    ${session_data}    400
    Should Be Equal As Strings    ${RESPONSE.status_code}    400
    Validar Session Erro

Cenario: GET Sessions Sem Parametros 200
    [Tags]    GET    sessions
    GET Sessions Sem Parametros    200
    Validar Sessions Sucesso

Cenario: GET Sessions Com Filtro Por Movie
    [Tags]    GET    sessions    filter
    ${params}=    Create Dictionary    movie=68dc716c050c98523bcd9f94
    GET Sessions Com Parametros    ${params}    200
    Validar Sessions Sucesso

Cenario: GET Sessions Com Filtro Por Theater
    [Tags]    GET    sessions    filter
    ${params}=    Create Dictionary    theater=68dc716d050c98523bcd9f97
    GET Sessions Com Parametros    ${params}    200
    Validar Sessions Sucesso

Cenario: GET Sessions Com Filtro Por Date
    [Tags]    GET    sessions    filter
    ${params}=    Create Dictionary    date=2025-06-20
    GET Sessions Com Parametros    ${params}    200
    Validar Sessions Sucesso

Cenario: GET Sessions Com Page
    [Tags]    GET    sessions    pagination
    ${params}=    Create Dictionary    page=2
    GET Sessions Com Parametros    ${params}    200
    Validar Sessions Sucesso

Cenario: GET Sessions Com Multiplos Parametros
    [Tags]    GET    sessions    complex
    ${params}=    Create Dictionary    
    ...    movie=68dc716c050c98523bcd9f94
    ...    theater=68dc716d050c98523bcd9f97
    ...    limit=5
    ...    page=1
    GET Sessions Com Parametros    ${params}    200
    Validar Sessions Sucesso

Cenario: GET Session Por ID Valido 200
    [Tags]    GET    session    id
    # Primeiro busca sessions existentes para pegar um ID válido
    GET Sessions Sem Parametros    200
    ${session_id}=    Set Variable    ${RESPONSE.json()['data'][0]['_id']}
    GET Session Por ID    ${session_id}    200
    Validar Session Por ID Sucesso

Cenario: GET Session Por ID Invalido 400
    [Tags]    GET    session    id    issue
    GET Session Por ID    id_invalido    400
    Should Be Equal As Strings    ${RESPONSE.status_code}    400
    Validar Session Erro

Cenario: GET Session Por ID Inexistente 404
    [Tags]    GET    session    id
    GET Session Por ID    60d0fe4f5311236168a109cc    404
    Should Be Equal As Strings    ${RESPONSE.status_code}    404
    Validar Session Erro

Cenario: PUT Session Com Sucesso 200
    [Tags]    PUT    session
    Criar Admin Para Teste
    Fazer Login Admin
    GET Sessions Sem Parametros    200
    ${session_id}=    Set Variable    ${RESPONSE.json()['data'][0]['_id']}
    ${session_data}=    Create Dictionary
    ...    movie=68dc716c050c98523bcd9f94
    ...    theater=68dc716d050c98523bcd9f97
    ...    datetime=2025-12-25T20:00:00.000Z
    ...    fullPrice=30
    ...    halfPrice=15
    PUT Session Com Token    ${session_id}    ${ADMIN_TOKEN}    ${session_data}    200
    Validar Session Atualizada Sucesso

Cenario: PUT Session Sem Token 401
    [Tags]    PUT    session
    GET Sessions Sem Parametros    200
    ${session_id}=    Set Variable    ${RESPONSE.json()['data'][0]['_id']}
    ${session_data}=    Create Dictionary
    ...    movie=68dc716c050c98523bcd9f94
    ...    theater=68dc716d050c98523bcd9f97
    ...    datetime=2025-12-25T20:00:00.000Z
    ...    fullPrice=30
    ...    halfPrice=15
    PUT Session Sem Token    ${session_id}    ${session_data}    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: PUT Session Token Invalido 401
    [Tags]    PUT    session
    GET Sessions Sem Parametros    200
    ${session_id}=    Set Variable    ${RESPONSE.json()['data'][0]['_id']}
    ${session_data}=    Create Dictionary
    ...    movie=68dc716c050c98523bcd9f94
    ...    theater=68dc716d050c98523bcd9f97
    ...    datetime=2025-12-25T20:00:00.000Z
    ...    fullPrice=30
    ...    halfPrice=15
    PUT Session Com Token    ${session_id}    token_invalido    ${session_data}    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: PUT Session ID Inexistente 404
    [Tags]    PUT    session
    Criar Admin Para Teste
    Fazer Login Admin
    ${session_data}=    Create Dictionary
    ...    movie=68dc716c050c98523bcd9f94
    ...    theater=68dc716d050c98523bcd9f97
    ...    datetime=2025-12-25T20:00:00.000Z
    ...    fullPrice=30
    ...    halfPrice=15
    PUT Session Com Token    60d0fe4f5311236168a109cc    ${ADMIN_TOKEN}    ${session_data}    404
    Should Be Equal As Strings    ${RESPONSE.status_code}    404
    Validar Session Erro

Cenario: PUT Session Com Reservas 409
    [Tags]    PUT    session    issue
    Criar Admin Para Teste
    Fazer Login Admin
    GET Sessions Sem Parametros    200
    ${session_id}=    Set Variable    ${RESPONSE.json()['data'][0]['_id']}
    ${session_data}=    Create Dictionary
    ...    movie=68dc716c050c98523bcd9f94
    ...    theater=68dc716d050c98523bcd9f97
    ...    datetime=2025-12-25T20:00:00.000Z
    ...    fullPrice=30
    ...    halfPrice=15
    PUT Session Com Token    ${session_id}    ${ADMIN_TOKEN}    ${session_data}    409
    Should Be Equal As Strings    ${RESPONSE.status_code}    409
    Validar Session Erro

Cenario: PUT Session Reset Seats Com Sucesso 200
    [Tags]    PUT    session    reset
    Criar Admin Para Teste
    Fazer Login Admin
    GET Sessions Sem Parametros    200
    ${session_id}=    Set Variable    ${RESPONSE.json()['data'][0]['_id']}
    PUT Session Reset Seats Com Token    ${session_id}    ${ADMIN_TOKEN}    200
    Should Be Equal As Strings    ${RESPONSE.status_code}    200