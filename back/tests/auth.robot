*** Settings ***
Resource    ../variaveis/base.robot
Resource    ../resources/auth.resource

Library    RequestsLibrary
Library    Collections


Suite Setup    Criar a sessão

*** Test Cases ***
Cenario: POST Cadastrar Usuario 201
    [Tags]    POST
    POST Cadastrar Usuario    /auth/register
    Should Be Equal As Strings    ${RESPONSE.status_code}    201
    Validar Se Cadastro Foi Bem Sucedido

Cenario: POST Nao Permitir Cadastar Usuario Duplicado 400
    [Tags]    POST    dup
    # Primeiro cadastro
    ${payload}=    Create Dictionary
    ...    name=testedup
    ...    email=testedup@gmail.com
    ...    password=teste123
    ${response1}=    POST On Session    api    /auth/register    json=${payload}    expected_status=any
    
    # Segundo cadastro com mesmo email deve falhar
    ${response2}=    POST On Session    api    /auth/register    json=${payload}    expected_status=400
    Should Be Equal As Strings    ${response2.status_code}    400

Cenario: POST Nao Deve Cadastrar Com Nome Vazio 400
    [Tags]    POST    validation
    POST Cadastrar Usuario Com Campos Vazios    /auth/register    ${EMPTY}    ${EMAIL}    ${SENHA}
    Should Be Equal As Strings    ${RESPONSE.status_code}    400

Cenario: POST Nao Deve Cadastrar Com Email Vazio 400
    [Tags]    POST    validation
    POST Cadastrar Usuario Com Campos Vazios    /auth/register    ${NOME}    ${EMPTY}    ${SENHA}
    Should Be Equal As Strings    ${RESPONSE.status_code}    400

Cenario: POST Nao Deve Cadastrar Com Senha Vazia 400
    [Tags]    POST    validation
    POST Cadastrar Usuario Com Campos Vazios    /auth/register    ${NOME}    ${EMAIL}    ${EMPTY}
    Should Be Equal As Strings    ${RESPONSE.status_code}    400

Cenario: POST Nao Deve Cadastrar Com Senha Muito Curta 400
    [Tags]    POST    validation
    POST Cadastrar Usuario Com Campos Vazios    /auth/register    ${NOME}    ${EMAIL}    ${SENHA_CURTA}
    Should Be Equal As Strings    ${RESPONSE.status_code}    400

Cenario: POST Nao Deve Cadastrar Com Senha Muito Longa 400
    [Tags]    POST    validation
    POST Cadastrar Usuario Com Campos Vazios    /auth/register    ${NOME}    ${EMAIL}    ${SENHA_LONGA}
    Should Be Equal As Strings    ${RESPONSE.status_code}    400

Cenario: POST Login Com Sucesso 200
    [Tags]    POST    login
    Criar Usuario Para Teste
    POST Login Com Status    200
    Validar Login Bem Sucedido

Cenario: POST Login Com Email Invalido 401
    [Tags]    POST    login
    POST Login Com Credenciais    emailinexistente@gmail.com    ${SENHA}    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: POST Login Com Senha Invalida 401
    [Tags]    POST    login
    Criar Usuario Para Teste
    POST Login Com Credenciais    ${EMAIL}    senhaerrada    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: GET Auth Me Com Sucesso 200
    [Tags]    GET    auth
    Criar Usuario Para Teste
    POST Login Com Status    200
    ${token}=    Set Variable    ${RESPONSE.json()['data']['token']}
    GET Auth Me Com Token    ${token}    200
    Validar Auth Me Sucesso

Cenario: GET Auth Me Sem Token 401
    [Tags]    GET    auth
    GET Auth Me Sem Token    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401
    Validar Auth Me Erro

Cenario: GET Auth Me Token Invalido 401
    [Tags]    GET    auth
    GET Auth Me Com Token    token_invalido    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401
    Validar Auth Me Erro

Cenario: PUT Auth Profile Com Sucesso 200
    [Tags]    PUT    profile    issue
    Criar Usuario Para Teste
    POST Login Com Status    200
    ${token}=    Set Variable    ${RESPONSE.json()['data']['token']}
    
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${payload}=    Create Dictionary
    ...    name=NovoNome
    ...    currentPassword=${SENHA}
    ...    newPassword=newpassword123
    ${response}=    PUT On Session    api    /auth/profile    headers=${headers}    json=${payload}    expected_status=200
    Set Suite Variable    ${RESPONSE}    ${response}
    
    Should Be Equal As Strings    ${RESPONSE.status_code}    200
    Validar Profile Update Sucesso

Cenario: PUT Auth Profile Senha Atual Incorreta 401
    [Tags]    PUT    profile    issue
    Criar Usuario Para Teste
    POST Login Com Status    200
    ${token}=    Set Variable    ${RESPONSE.json()['data']['token']}
    PUT Auth Profile Com Token    ${token}    NovoNome    senhaerrada    novasenha123    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: PUT Auth Profile Sem Token 401
    [Tags]    PUT    profile
    PUT Auth Profile Sem Token    NovoNome    ${SENHA}    novasenha123    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: PUT Auth Profile Token Invalido 401
    [Tags]    PUT    profile
    PUT Auth Profile Com Token    token_invalido    NovoNome    ${SENHA}    novasenha123    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401
    