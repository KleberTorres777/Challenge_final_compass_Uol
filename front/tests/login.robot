*** Settings ***
Documentation    Cenários de testes do login de usuários

Resource    ../resources/base.resource
Resource    ../resources/pages/LoginPage.resource
Resource    ../resources/pages/Notice.resource

Test Setup    Start Session
Library    String

*** Test Cases ***
Deve poder fazer login com credenciais válidas

    ${user}    Create Dictionary    
    ...    name=teste    
    ...    email=teste@gmail.com    
    ...    password=teste123

    # Assumindo que o usuário já existe ou será criado via cadastro
    Go to login page
    Submit login form    ${user}
    # Notice should be    Login realizado com sucesso!

Não deve logar com senha inválida

    ${invalid_user}    Create Dictionary    
    ...    email=teste@gmail.com    
    ...    password=senhaerrada

    # Testa login com senha incorreta
    Go to login page
    Submit login form    ${invalid_user}
    Notice should be    Invalid credentials

Não deve logar com email inválido

    ${invalid_user}    Create Dictionary    
    ...    email=emailinexistente@gmail.com    
    ...    password=qualquersenha

    Go to login page
    Submit login form    ${invalid_user}