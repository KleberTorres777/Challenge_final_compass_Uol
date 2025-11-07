*** Settings ***
Resource    ../variaveis/base.robot

Library    RequestsLibrary
Library    Collections
Library    DateTime

*** Variables ***
${EMAIL}    user@example.com
${SENHA}    password123
${NOME}     User Test
${SENHA_CURTA}    12
${SENHA_LONGA}    unidunitêsalamêlinguê1234567890

*** Keywords ***
POST Cadastrar Usuario
    [Arguments]    ${endpoint}
    ${payload}=    Create Dictionary
    ...    name=${NOME}
    ...    email=${EMAIL}
    ...    password=${SENHA}

    ${response}=    POST On Session    api    ${endpoint}    json=${payload}    expected_status=201
    Set Suite Variable    ${RESPONSE}    ${response}

POST Cadastrar Usuario Com Campos Vazios
    [Arguments]    ${endpoint}    ${name}    ${email}    ${password}
    ${payload}=    Create Dictionary
    ...    name=${name}
    ...    email=${email}
    ...    password=${password}

    ${response}=    POST On Session    api    ${endpoint}    json=${payload}    expected_status=400
    Set Suite Variable    ${RESPONSE}    ${response}

POST Login com sucesso
    ${payload}=    Create Dictionary
    ...    email=${EMAIL}
    ...    password=${SENHA}
    ${response}=    POST On Session    api    /auth/login    json=${payload}
    Set Suite Variable    ${RESPONSE}    ${response}

POST Login Com Status
    [Arguments]    ${expected_status}
    ${payload}=    Create Dictionary
    ...    email=${EMAIL}
    ...    password=${SENHA}
    ${response}=    POST On Session    api    /auth/login    json=${payload}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

POST Login Com Credenciais
    [Arguments]    ${email}    ${password}    ${expected_status}
    ${payload}=    Create Dictionary
    ...    email=${email}
    ...    password=${password}
    ${response}=    POST On Session    api    /auth/login    json=${payload}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Criar Usuario Para Teste
    # Create user via API instead of direct database insertion
    ${user_data}=    Create Dictionary    
    ...    name=${NOME}
    ...    email=${EMAIL}
    ...    password=${SENHA}
    # Try to create user via API, ignore if already exists
    ${response}=    POST On Session    api    /auth/register    json=${user_data}    expected_status=any 


Validar Status Code "${expected_status}"
    Should Be Equal As Strings    ${RESPONSE.status_code}    ${expected_status}

Validar Se Cadastro Foi Bem Sucedido
    Should Be True    ${RESPONSE.json()['success']}
    Should Be Equal As Strings    ${RESPONSE.json()['data']['email']}    ${EMAIL}

Validar Login Bem Sucedido
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()['data']}    token

GET Auth Me Com Token
    [Arguments]    ${token}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    GET On Session    api    /auth/me    headers=${headers}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

GET Auth Me Sem Token
    [Arguments]    ${expected_status}
    ${response}=    GET On Session    api    /auth/me    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Auth Me Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()['data']}    _id
    Should Contain    ${RESPONSE.json()['data']}    name
    Should Contain    ${RESPONSE.json()['data']}    email
    Should Contain    ${RESPONSE.json()['data']}    role

Validar Auth Me Erro
    Should Be Equal    ${RESPONSE.json()['success']}    ${False}
    Should Contain    ${RESPONSE.json()}    message

PUT Auth Profile Com Token
    [Arguments]    ${token}    ${name}    ${current_password}    ${new_password}    ${expected_status}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${payload}=    Create Dictionary
    ...    name=${name}
    ...    currentPassword=${current_password}
    ...    newPassword=${new_password}
    ${response}=    PUT On Session    api    /auth/profile    headers=${headers}    json=${payload}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

PUT Auth Profile Sem Token
    [Arguments]    ${name}    ${current_password}    ${new_password}    ${expected_status}
    ${payload}=    Create Dictionary
    ...    name=${name}
    ...    currentPassword=${current_password}
    ...    newPassword=${new_password}
    ${response}=    PUT On Session    api    /auth/profile    json=${payload}    expected_status=${expected_status}
    Set Suite Variable    ${RESPONSE}    ${response}

Validar Profile Update Sucesso
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Should Be True    ${RESPONSE.json()['success']}
    Should Contain    ${RESPONSE.json()['data']}    _id
    Should Contain    ${RESPONSE.json()['data']}    name
    Should Contain    ${RESPONSE.json()['data']}    email
    Should Contain    ${RESPONSE.json()['data']}    role
