*** Settings ***
Resource    ../variaveis/base.robot

Library    RequestsLibrary
Library    Collections
Library    ../libs/database.py

*** Variables ***
${ADMIN_EMAIL}    admin.teste@gmail.com
${ADMIN_PASSWORD}    admin123
${ADMIN_NAME}    Admin Teste
${THEATER_NAME}    Theater Teste Robot

*** Keywords ***
GET Theaters Sem Parametros
    [Arguments]    ${expected_status}
    ${response}=    GET On Session    api    /theaters    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

GET Theaters Com Parametros
    [Arguments]    ${params}    ${expected_status}
    ${response}=    GET On Session    api    /theaters    params=${params}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Theaters Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Contain    ${RESPONSE.json()}    data
    Should Contain    ${RESPONSE.json()}    count
    Should Be True    ${RESPONSE.json()['success']}

GET Theater Por ID
    [Arguments]    ${theater_id}    ${expected_status}
    ${response}=    GET On Session    api    /theaters/${theater_id}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Theater Por ID Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()['data']}    _id
    Should Contain    ${RESPONSE.json()['data']}    name
    Should Contain    ${RESPONSE.json()['data']}    capacity
    Should Contain    ${RESPONSE.json()['data']}    type
    Should Contain    ${RESPONSE.json()['data']}    createdAt

PUT Theater Com Token
    [Arguments]    ${theater_id}    ${token}    ${theater_data}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    PUT On Session    api    /theaters/${theater_id}    headers=${headers}    json=${theater_data}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

PUT Theater Sem Token
    [Arguments]    ${theater_id}    ${theater_data}    ${expected_status}
    ${response}=    PUT On Session    api    /theaters/${theater_id}    json=${theater_data}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Theater Atualizado Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()['data']}    _id
    Should Contain    ${RESPONSE.json()['data']}    name
    Should Contain    ${RESPONSE.json()['data']}    capacity
    Should Contain    ${RESPONSE.json()['data']}    type
    Should Contain    ${RESPONSE.json()['data']}    createdAt

DELETE Theater Com Token
    [Arguments]    ${theater_id}    ${token}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    DELETE On Session    api    /theaters/${theater_id}    headers=${headers}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

DELETE Theater Sem Token
    [Arguments]    ${theater_id}    ${expected_status}
    ${response}=    DELETE On Session    api    /theaters/${theater_id}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Theater Deletado Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()}    message

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

POST Theater Com Token
    [Arguments]    ${token}    ${theater_data}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    POST On Session    api    /theaters    headers=${headers}    json=${theater_data}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

POST Theater Sem Token
    [Arguments]    ${theater_data}    ${expected_status}
    ${response}=    POST On Session    api    /theaters    json=${theater_data}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

POST Cadastrar Theater
    [Arguments]    ${token}
    ${payload}=    Create Dictionary
    ...    name=${THEATER_NAME}
    ...    location=Local Teste
    ...    capacity=100
    ...    type=standard
    
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    POST On Session    api    /theaters    headers=${headers}    json=${payload}    expected_status=any
    Set Suite Variable    ${RESPONSE}    ${response}
    Set Suite Variable    ${THEATER_CREATED_NAME}    ${THEATER_NAME}

Validar Theater Criado Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    201
    Should Contain    ${RESPONSE.json()['data']}    _id
    Should Contain    ${RESPONSE.json()['data']}    name
    Should Contain    ${RESPONSE.json()['data']}    capacity
    Should Contain    ${RESPONSE.json()['data']}    type
    Should Contain    ${RESPONSE.json()['data']}    createdAt

Validar Theater Erro
    Should Be Equal    ${RESPONSE.json()['success']}    ${False}
    Should Contain    ${RESPONSE.json()}    message

Validar Status Code "${expected_status}"
    Should Be Equal As Strings    ${RESPONSE.status_code}    ${expected_status}