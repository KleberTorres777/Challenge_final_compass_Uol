*** Settings ***
Resource    ../variaveis/base.robot

Library    RequestsLibrary
Library    Collections

*** Variables ***
${ADMIN_EMAIL}    admin.teste@gmail.com
${ADMIN_PASSWORD}    admin123
${ADMIN_NAME}    Admin Teste
${MOVIE_ID}    68dc716c050c98523bcd9f94
${THEATER_ID}    68dc716d050c98523bcd9f97

*** Keywords ***
GET Sessions Sem Parametros
    [Arguments]    ${expected_status}
    ${response}=    GET On Session    api    /sessions    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

GET Sessions Com Parametros
    [Arguments]    ${params}    ${expected_status}
    ${response}=    GET On Session    api    /sessions    params=${params}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Sessions Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()}    data
    Should Contain    ${RESPONSE.json()}    count
    Should Contain    ${RESPONSE.json()}    pagination

GET Session Por ID
    [Arguments]    ${session_id}    ${expected_status}
    ${response}=    GET On Session    api    /sessions/${session_id}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Session Por ID Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()['data']}    _id
    Should Contain    ${RESPONSE.json()['data']}    movie
    Should Contain    ${RESPONSE.json()['data']}    theater
    Should Contain    ${RESPONSE.json()['data']}    datetime
    Should Contain    ${RESPONSE.json()['data']}    fullPrice
    Should Contain    ${RESPONSE.json()['data']}    halfPrice
    Should Contain    ${RESPONSE.json()['data']}    seats
    Should Contain    ${RESPONSE.json()['data']}    createdAt

PUT Session Com Token
    [Arguments]    ${session_id}    ${token}    ${session_data}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    PUT On Session    api    /sessions/${session_id}    headers=${headers}    json=${session_data}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

PUT Session Sem Token
    [Arguments]    ${session_id}    ${session_data}    ${expected_status}
    ${response}=    PUT On Session    api    /sessions/${session_id}    json=${session_data}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Session Atualizada Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()['data']}    _id
    Should Contain    ${RESPONSE.json()['data']}    movie
    Should Contain    ${RESPONSE.json()['data']}    theater
    Should Contain    ${RESPONSE.json()['data']}    datetime
    Should Contain    ${RESPONSE.json()['data']}    fullPrice
    Should Contain    ${RESPONSE.json()['data']}    halfPrice
    Should Contain    ${RESPONSE.json()['data']}    seats
    Should Contain    ${RESPONSE.json()['data']}    createdAt

PUT Session Reset Seats Com Token
    [Arguments]    ${session_id}    ${token}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    PUT On Session    api    /sessions/${session_id}/reset-seats    headers=${headers}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

PUT Session Reset Seats Sem Token
    [Arguments]    ${session_id}    ${expected_status}
    ${response}=    PUT On Session    api    /sessions/${session_id}/reset-seats    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Session Reset Seats Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()}    message
    Should Contain    ${RESPONSE.json()['data']}    _id
    Should Contain    ${RESPONSE.json()['data']}    seats

DELETE Session Com Token
    [Arguments]    ${session_id}    ${token}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    DELETE On Session    api    /sessions/${session_id}    headers=${headers}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

DELETE Session Sem Token
    [Arguments]    ${session_id}    ${expected_status}
    ${response}=    DELETE On Session    api    /sessions/${session_id}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Session Deletada Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()}    message
    Should Be Equal As Strings    ${RESPONSE.json()['message']}    Session removed

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
    # Aceitar 201 (criado) ou 400 (já existe)
    Should Be True    '${response.status_code}' == '201' or '${response.status_code}' == '400'
    Set Suite Variable    ${ADMIN_EMAIL}    ${unique_email}

Fazer Login Admin
    ${payload}=    Create Dictionary
    ...    email=${ADMIN_EMAIL}
    ...    password=admin123456
    Log    Fazendo login com admin criado: ${payload}
    ${response}=    POST On Session    api    /auth/login    json=${payload}    expected_status=any
    Log    Status do login: ${response.status_code}
    IF    '${response.status_code}' == '200'
        Set Suite Variable    ${ADMIN_TOKEN}    ${response.json()['data']['token']}
        Log    Token obtido: ${ADMIN_TOKEN}
    ELSE
        Set Suite Variable    ${ADMIN_TOKEN}    token_invalido
        Log    Login falhou, token definido como inválido
    END
    Set Suite Variable    ${RESPONSE}    ${response}

POST Session Com Token
    [Arguments]    ${token}    ${session_data}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    POST On Session    api    /sessions    headers=${headers}    json=${session_data}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

POST Session Sem Token
    [Arguments]    ${session_data}    ${expected_status}
    ${response}=    POST On Session    api    /sessions    json=${session_data}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

POST Cadastrar Session
    [Arguments]    ${token}
    ${payload}=    Create Dictionary
    ...    movie=${MOVIE_ID}
    ...    theater=${THEATER_ID}
    ...    datetime=2025-12-20T18:30:00.000Z
    ...    fullPrice=20
    ...    halfPrice=10
    
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    POST On Session    api    /sessions    headers=${headers}    json=${payload}    expected_status=201
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Session Criada Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    201
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()['data']}    _id
    Should Contain    ${RESPONSE.json()['data']}    movie
    Should Contain    ${RESPONSE.json()['data']}    theater
    Should Contain    ${RESPONSE.json()['data']}    datetime
    Should Contain    ${RESPONSE.json()['data']}    fullPrice
    Should Contain    ${RESPONSE.json()['data']}    halfPrice
    Should Contain    ${RESPONSE.json()['data']}    seats

Validar Session Erro
    Should Be Equal    ${RESPONSE.json()['success']}    ${False}
    Should Contain    ${RESPONSE.json()}    message

Validar Status Code "${expected_status}"
    Should Be Equal As Strings    ${RESPONSE.status_code}    ${expected_status}

POST Movie Com Token
    [Arguments]    ${token}    ${movie_data}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    POST On Session    api    /movies    headers=${headers}    json=${movie_data}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

POST Theater Com Token
    [Arguments]    ${token}    ${theater_data}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    POST On Session    api    /theaters    headers=${headers}    json=${theater_data}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}