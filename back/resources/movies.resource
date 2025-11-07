*** Settings ***
Resource    ../variaveis/base.robot

Library    RequestsLibrary
Library    Collections
Library    DateTime

*** Variables ***
${MOVIE_TITLE}    Filme Teste Robot
${MOVIE_SYNOPSIS}    Sinopse do filme de teste
${MOVIE_DIRECTOR}    Diretor Teste
${ADMIN_EMAIL}    admin@example.com
${ADMIN_PASSWORD}    password123
${ADMIN_NAME}    Admin User

*** Keywords ***
GET Movies Sem Parametros
    [Arguments]    ${expected_status}
    ${response}=    GET On Session    api    /movies    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

GET Movies Com Parametros
    [Arguments]    ${params}    ${expected_status}
    ${response}=    GET On Session    api    /movies    params=${params}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Movies Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Contain    ${RESPONSE.json()}    data
    Should Contain    ${RESPONSE.json()}    count
    Should Contain    ${RESPONSE.json()}    pagination

GET Movie Por ID
    [Arguments]    ${movie_id}    ${expected_status}
    ${response}=    GET On Session    api    /movies/${movie_id}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Movie Por ID Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()['data']}    _id
    Should Contain    ${RESPONSE.json()['data']}    title
    Should Contain    ${RESPONSE.json()['data']}    synopsis
    Should Contain    ${RESPONSE.json()['data']}    director
    Should Contain    ${RESPONSE.json()['data']}    genres
    Should Contain    ${RESPONSE.json()['data']}    duration
    Should Contain    ${RESPONSE.json()['data']}    classification
    Should Contain    ${RESPONSE.json()['data']}    releaseDate

Validar Movie Erro
    Should Be Equal    ${RESPONSE.json()['success']}    ${False}
    Should Contain    ${RESPONSE.json()}    message

POST Movie Com Token
    [Arguments]    ${token}    ${movie_data}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    POST On Session    api    /movies    headers=${headers}    json=${movie_data}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

POST Movie Sem Token
    [Arguments]    ${movie_data}    ${expected_status}
    ${response}=    POST On Session    api    /movies    json=${movie_data}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Movie Criado Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    201
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()['data']}    _id
    Should Contain    ${RESPONSE.json()['data']}    title
    Should Contain    ${RESPONSE.json()['data']}    synopsis
    Should Contain    ${RESPONSE.json()['data']}    director
    Should Contain    ${RESPONSE.json()['data']}    genres
    Should Contain    ${RESPONSE.json()['data']}    duration
    Should Contain    ${RESPONSE.json()['data']}    classification
    Should Contain    ${RESPONSE.json()['data']}    releaseDate

POST Cadastrar Movie
    [Arguments]    ${token}
    ${payload}=    Create Dictionary
    ...    title=${MOVIE_TITLE}
    ...    synopsis=${MOVIE_SYNOPSIS}
    ...    director=${MOVIE_DIRECTOR}
    ...    genres=["Action", "Drama"]
    ...    duration=120
    ...    classification=PG-13
    ...    poster=teste.jpg
    ...    releaseDate=2024-01-01
    
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    POST On Session    api    /movies    headers=${headers}    json=${payload}    expected_status=any
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Se Movie Foi Criado
    Should Be True    ${RESPONSE.json()['success']}
    Should Be Equal As Strings    ${RESPONSE.json()['data']['title']}    ${MOVIE_TITLE}

Criar Movie Para Teste
    # Create admin and movie via API instead of direct database insertion
    Criar Admin Para Teste
    Fazer Login Admin
    POST Cadastrar Movie    ${ADMIN_TOKEN}

Criar Admin Para Teste
    ${random}=    Evaluate    random.randint(1000, 9999)    random
    ${unique_email}=    Set Variable    admin${random}@test.com
    ${admin_data}=    Create Dictionary
    ...    name=Admin Teste
    ...    email=${unique_email}
    ...    password=admin123456
    Log    Criando admin via /setup/admin: ${admin_data}
    ${response}=    POST On Session    api    /setup/admin    json=${admin_data}    expected_status=any
    Log    Status da criação do admin: ${response.status_code}
    Should Be Equal As Strings    ${response.status_code}    201    Admin deve ser criado via setup
    Set Suite Variable    ${ADMIN_EMAIL}    ${unique_email}
    Set Suite Variable    ${ADMIN_PASSWORD}    admin123456

Fazer Login Admin
    ${payload}=    Create Dictionary
    ...    email=${ADMIN_EMAIL}
    ...    password=${ADMIN_PASSWORD}
    Log    Fazendo login com admin criado: ${payload}
    ${response}=    POST On Session    api    /auth/login    json=${payload}    expected_status=any
    Log    Status do login: ${response.status_code}
    Log    Resposta do login: ${response.text}
    IF    '${response.status_code}' == '200'
        Set Suite Variable    ${ADMIN_TOKEN}    ${response.json()['data']['token']}
        Log    Token obtido: ${ADMIN_TOKEN}
        Log    Role do usuário: ${response.json()['data']['role']}
    ELSE
        Set Suite Variable    ${ADMIN_TOKEN}    token_invalido
        Log    Login falhou, token definido como inválido
    END
    Set Suite Variable    ${RESPONSE}    ${response}

PUT Movie Com Token
    [Arguments]    ${movie_id}    ${token}    ${movie_data}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    PUT On Session    api    /movies/${movie_id}    headers=${headers}    json=${movie_data}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

PUT Movie Sem Token
    [Arguments]    ${movie_id}    ${movie_data}    ${expected_status}
    ${response}=    PUT On Session    api    /movies/${movie_id}    json=${movie_data}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Movie Atualizado Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()['data']}    _id
    Should Contain    ${RESPONSE.json()['data']}    title
    Should Contain    ${RESPONSE.json()['data']}    synopsis
    Should Contain    ${RESPONSE.json()['data']}    director
    Should Contain    ${RESPONSE.json()['data']}    genres
    Should Contain    ${RESPONSE.json()['data']}    duration
    Should Contain    ${RESPONSE.json()['data']}    classification
    Should Contain    ${RESPONSE.json()['data']}    releaseDate

DELETE Movie Com Token
    [Arguments]    ${movie_id}    ${token}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    DELETE On Session    api    /movies/${movie_id}    headers=${headers}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

DELETE Movie Sem Token
    [Arguments]    ${movie_id}    ${expected_status}
    ${response}=    DELETE On Session    api    /movies/${movie_id}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Movie Deletado Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()}    message
    Should Be Equal As Strings    ${RESPONSE.json()['message']}    Movie removed

Validar Status Code "${expected_status}"
    Should Be Equal As Strings    ${RESPONSE.status_code}    ${expected_status}