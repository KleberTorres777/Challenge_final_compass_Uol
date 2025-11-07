*** Settings ***
Resource    ../variaveis/base.robot

Library    RequestsLibrary
Library    Collections
Library    DateTime
*** Variables ***
${USER_EMAIL}    user.teste@gmail.com
${USER_PASSWORD}    user123
${USER_NAME}    User Teste
${ADMIN_EMAIL}    admin.teste@gmail.com
${VALID_SESSION_ID}    68dc716d050c98523bcd9f9c  

*** Keywords ***
Criar User Para Teste
    ${random}=    Evaluate    random.randint(1000, 9999)    random
    ${unique_email}=    Set Variable    user${random}@test.com
    ${user_data}=    Create Dictionary
    ...    name=User Teste
    ...    email=${unique_email}
    ...    password=user123456
    Log    Criando user via API: ${user_data}
    ${response}=    POST On Session    api    /auth/register    json=${user_data}    expected_status=any
    Log    Status da criação do user: ${response.status_code}
    Should Be Equal As Strings    ${response.status_code}    201    User deve ser criado
    Set Suite Variable    ${USER_EMAIL}    ${unique_email}

Fazer Login User
    ${payload}=    Create Dictionary
    ...    email=${USER_EMAIL}
    ...    password=user123456
    Log    Fazendo login com user criado: ${payload}
    ${response}=    POST On Session    api    /auth/login    json=${payload}    expected_status=any
    Log    Status do login: ${response.status_code}
    IF    '${response.status_code}' == '200'
        Set Suite Variable    ${USER_TOKEN}    ${response.json()['data']['token']}
        Log    Token obtido: ${USER_TOKEN}
    ELSE
        Set Suite Variable    ${USER_TOKEN}    token_invalido
        Log    Login falhou, token definido como inválido
    END
    Set Suite Variable    ${RESPONSE}    ${response}

POST Reservation Com Token
    [Arguments]    ${token}    ${reservation_data}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    POST On Session    api    /reservations    headers=${headers}    json=${reservation_data}    expected_status=any
    Set Suite Variable    ${RESPONSE}    ${response}

POST Reservation Sem Token
    [Arguments]    ${reservation_data}    ${expected_status}
    ${response}=    POST On Session    api    /reservations    json=${reservation_data}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

POST Cadastrar Reservation
    [Arguments]    ${token}
    ${seat1}=    Create Dictionary    row=Z    number=99    type=full
    ${seats}=    Create List    ${seat1}
    
    ${payload}=    Create Dictionary
    ...    session=68dc716d050c98523bcd9f9c
    ...    seats=${seats}
    ...    paymentMethod=credit_card
    
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    POST On Session    api    /reservations    headers=${headers}    json=${payload}    expected_status=400
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Reservation Criada Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    201
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()['data']}    _id
    Should Contain    ${RESPONSE.json()['data']}    user
    Should Contain    ${RESPONSE.json()['data']}    session
    Should Contain    ${RESPONSE.json()['data']}    seats
    Should Contain    ${RESPONSE.json()['data']}    totalPrice
    Should Contain    ${RESPONSE.json()['data']}    status
    Should Contain    ${RESPONSE.json()['data']}    paymentStatus
    Should Contain    ${RESPONSE.json()['data']}    paymentMethod

Validar Reservation Erro
    Should Be Equal    ${RESPONSE.json()['success']}    ${False}
    Should Contain    ${RESPONSE.json()}    message

Validar Status Code "${expected_status}"
    Should Be Equal As Strings    ${RESPONSE.status_code}    ${expected_status}

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

GET Session Para Ver Assentos
    [Arguments]    ${session_id}
    ${response}=    GET On Session    api    /sessions/${session_id}    expected_status=any
    Log    Session seats: ${response.json()}
    Set Suite Variable    ${RESPONSE}    ${response}

PUT Session Reset Seats Com Token
    [Arguments]    ${session_id}    ${token}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    PUT On Session    api    /sessions/${session_id}/reset-seats    headers=${headers}    expected_status=200
    Set Suite Variable    ${RESPONSE}    ${response}

GET Reservations Me Com Token
    [Arguments]    ${token}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    GET On Session    api    /reservations/me    headers=${headers}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

GET Reservations Me Sem Token
    [Arguments]    ${expected_status}
    ${response}=    GET On Session    api    /reservations/me    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Reservations Me Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()}    data
    Should Contain    ${RESPONSE.json()}    count

GET Reservations Com Token
    [Arguments]    ${token}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    GET On Session    api    /reservations    headers=${headers}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

GET Reservations Com Parametros
    [Arguments]    ${token}    ${params}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    GET On Session    api    /reservations    headers=${headers}    params=${params}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

GET Reservations Sem Token
    [Arguments]    ${expected_status}
    ${response}=    GET On Session    api    /reservations    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Reservations Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()}    data
    Should Contain    ${RESPONSE.json()}    count
    Should Contain    ${RESPONSE.json()}    pagination
GET Reservation Por ID Com Token
    [Arguments]    ${reservation_id}    ${token}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    GET On Session    api    /reservations/${reservation_id}    headers=${headers}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

GET Reservation Por ID Sem Token
    [Arguments]    ${reservation_id}    ${expected_status}
    ${response}=    GET On Session    api    /reservations/${reservation_id}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Reservation Por ID Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()['data']}    _id
    Should Contain    ${RESPONSE.json()['data']}    user
    Should Contain    ${RESPONSE.json()['data']}    session
    Should Contain    ${RESPONSE.json()['data']}    seats
    Should Contain    ${RESPONSE.json()['data']}    totalPrice
    Should Contain    ${RESPONSE.json()['data']}    status
    Should Contain    ${RESPONSE.json()['data']}    paymentStatus
    Should Contain    ${RESPONSE.json()['data']}    paymentMethod
    Should Contain    ${RESPONSE.json()['data']}    createdAt
PUT Reservation Com Token
    [Arguments]    ${reservation_id}    ${token}    ${reservation_data}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    PUT On Session    api    /reservations/${reservation_id}    headers=${headers}    json=${reservation_data}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

PUT Reservation Sem Token
    [Arguments]    ${reservation_id}    ${reservation_data}    ${expected_status}
    ${response}=    PUT On Session    api    /reservations/${reservation_id}    json=${reservation_data}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Reservation Atualizada Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()['data']}    _id
    Should Contain    ${RESPONSE.json()['data']}    user
    Should Contain    ${RESPONSE.json()['data']}    session
    Should Contain    ${RESPONSE.json()['data']}    seats
    Should Contain    ${RESPONSE.json()['data']}    totalPrice
    Should Contain    ${RESPONSE.json()['data']}    status
    Should Contain    ${RESPONSE.json()['data']}    paymentStatus
    Should Contain    ${RESPONSE.json()['data']}    paymentMethod
    Should Contain    ${RESPONSE.json()['data']}    createdAt
DELETE Reservation Com Token
    [Arguments]    ${reservation_id}    ${token}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    DELETE On Session    api    /reservations/${reservation_id}    headers=${headers}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

DELETE Reservation Sem Token
    [Arguments]    ${reservation_id}    ${expected_status}
    ${response}=    DELETE On Session    api    /reservations/${reservation_id}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Reservation Deletada Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()}    message
    Should Be Equal As Strings    ${RESPONSE.json()['message']}    Reservation removed