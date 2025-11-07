*** Settings ***
Documentation    Cenários de testes de seleção de assentos

Resource    ../resources/base.resource
Resource    ../resources/pages/AssentosPage.resource
Resource    ../resources/pages/LoginPage.resource
Resource    ../resources/pages/MoviesPage.resource

Test Setup    Start Session
Test Teardown    Take Screenshot
Library    String

*** Test Cases ***
Deve selecionar todos os assentos disponíveis

    ${user}    Create Dictionary    
    ...    name=teste    
    ...    email=teste@gmail.com    
    ...    password=teste123

    # Fazer login (assumindo que o usuário já existe ou será criado via frontend)
    Go to login page
    Submit login form    ${user}

    # Ver detalhes do filme
    Click movie details by id    68e8f82e97de05f696275f07

    # Selecionar sessão
    Select session by id    68e8f82e97de05f696275f15

    # Selecionar todos os assentos
    Select all seats

    