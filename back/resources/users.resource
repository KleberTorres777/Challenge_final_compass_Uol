*** Settings ***
Resource    ../variaveis/base.robot

Library    RequestsLibrary
Library    Collections
Library    ../libs/database.py

*** Variables ***
${ADMIN_EMAIL}    admin@example.com
${ADMIN_PASSWORD}    password123
${ADMIN_NAME}    Admin User

*** Keywords ***
GET Users Com Token
    [Arguments]    ${token}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    GET On Session    api    /users    headers=${headers}    expected_status=any
    Set Suite Variable    ${RESPONSE}    ${response}

GET Users Com Parametros
    [Arguments]    ${token}    ${params}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    GET On Session    api    /users    headers=${headers}    params=${params}    expected_status=any
    Set Suite Variable    ${RESPONSE}    ${response}

GET Users Sem Token
    [Arguments]    ${expected_status}
    ${response}=    GET On Session    api    /users    expected_status=any
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Users Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()}    data
    Should Contain    ${RESPONSE.json()}    count

Validar User Erro
    Should Be Equal    ${RESPONSE.json()['success']}    ${False}
    Should Contain    ${RESPONSE.json()}    message

GET User Por ID Com Token
    [Arguments]    ${user_id}    ${token}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    GET On Session    api    /users/${user_id}    headers=${headers}    expected_status=any
    Set Suite Variable    ${RESPONSE}    ${response}

GET User Por ID Sem Token
    [Arguments]    ${user_id}    ${expected_status}
    ${response}=    GET On Session    api    /users/${user_id}    expected_status=any
    Set Suite Variable    ${RESPONSE}    ${response}

Validar User Por ID Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()['data']}    _id
    Should Contain    ${RESPONSE.json()['data']}    name
    Should Contain    ${RESPONSE.json()['data']}    email
    Should Contain    ${RESPONSE.json()['data']}    role
    Should Contain    ${RESPONSE.json()['data']}    createdAt

PUT User Com Token
    [Arguments]    ${user_id}    ${token}    ${user_data}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    PUT On Session    api    /users/${user_id}    headers=${headers}    json=${user_data}    expected_status=any
    Set Suite Variable    ${RESPONSE}    ${response}

PUT User Sem Token
    [Arguments]    ${user_id}    ${user_data}    ${expected_status}
    ${response}=    PUT On Session    api    /users/${user_id}    json=${user_data}    expected_status=any
    Set Suite Variable    ${RESPONSE}    ${response}

Validar User Atualizado Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()['data']}    _id
    Should Contain    ${RESPONSE.json()['data']}    name
    Should Contain    ${RESPONSE.json()['data']}    email
    Should Contain    ${RESPONSE.json()['data']}    role

DELETE User Com Token
    [Arguments]    ${user_id}    ${token}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    DELETE On Session    api    /users/${user_id}    headers=${headers}    expected_status=any
    Set Suite Variable    ${RESPONSE}    ${response}

DELETE User Sem Token
    [Arguments]    ${user_id}    ${expected_status}
    ${response}=    DELETE On Session    api    /users/${user_id}    expected_status=any
    Set Suite Variable    ${RESPONSE}    ${response}

Validar User Deletado Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()}    message

Criar User Para Teste
    ${user_data}=    Create Dictionary
    ...    name=User Teste Delete
    ...    email=user.delete@example.com
    ...    password=user123456
    Clean user from database    user.delete@example.com
    Insert user in database    ${user_data}

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