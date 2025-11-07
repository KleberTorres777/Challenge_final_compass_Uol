*** Settings ***
Documentation    Cenários de testes do cadastro de usuários

Resource    ../resources/base.resource
Resource    ../resources/pages/CadastroPage.resource
Resource    ../resources/pages/Notice.resource

Test Setup    Start Session
Test Teardown    Take Screenshot
Library    String

*** Test Cases ***
Deve poder cadastrar um novo usuário

    ${user}    Create Dictionary    
    ...    name=teste    
    ...    email=teste@gmail.com    
    ...    password=teste123
    ...    confirmPassword=teste123

    Go to signup page
    Submit signup from    ${user}


Não deve poder cadastrar com email duplicado

    ${user}    Create Dictionary    
    ...    name=teste    
    ...    email=teste@gmail.com    
    ...    password=teste123
    ...    confirmPassword=teste123

    # Primeiro cadastro
    Go to signup page
    Submit signup from    ${user}
    
    # Segundo cadastro com mesmo email deve falhar
    Go to signup page
    Submit signup from    ${user}


Não deve cadastrar com campos vazios

    ${user}    Create Dictionary    
    ...    name=    
    ...    email=    
    ...    password=    
    ...    confirmPassword=

    Go to signup page
    Submit signup from    ${user}
    Notice should be    All fields are required

Não deve cadastrar com senha muito curta

    ${user}    Create Dictionary    
    ...    name=teste    
    ...    email=teste@gmail.com    
    ...    password=123    
    ...    confirmPassword=123

    Go to signup page
    Submit signup from    ${user}


