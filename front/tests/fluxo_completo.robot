*** Settings ***
Documentation    cadastro, login e compra de ingresso

Resource    ../resources/base.resource
Resource    ../resources/pages/CadastroPage.resource
Resource    ../resources/pages/LoginPage.resource
Resource    ../resources/pages/CinemaFlow.resource

Test Setup    Start Session
Test Teardown    Take Screenshot
Library    String

*** Test Cases ***
Fluxo completo de compra de ingresso com cartão de crédito

    ${user}    Create Dictionary    
    ...    name=teste    
    ...    email=teste@gmail.com    
    ...    password=teste123
    ...    confirmPassword=teste123

    # Cadasto do usuário
    Go to signup page
    Submit signup from    ${user}

    # Fazer login
    Go to login page
    Submit login form    ${user}

    # Ver detalhes do filme The Avengers
    Click movie details    68e8f82e97de05f696275f08

    # Selecionar sessão
    Select session    68e8f82e97de05f696275f1b

    # Selecionar assento
    Select seat    E7

    # Continuar para pagamento
    Continue to payment

    # Selecionar cartão de crédito
    Select credit card payment

    # Finalizar compra
    Finalize purchase

Fluxo completo de compra de ingresso com cartão de débito

    ${user}    Create Dictionary    
    ...    name=teste2    
    ...    email=teste2@gmail.com    
    ...    password=teste123
    ...    confirmPassword=teste123

    # Cadastrar usuário
    Go to signup page
    Submit signup from    ${user}

    # Fazer login
    Go to login page
    Submit login form    ${user}

    # Ver detalhes do filme The Avengers
    Click movie details    68e8f82e97de05f696275f08

    # Selecionar sessão
    Select session    68e8f82e97de05f696275f1b

    # Selecionar assento
    Select seat    E6

    # Continuar para pagamento
    Continue to payment

    # Selecionar cartão de débito
    Select debit card payment

    # Finalizar compra
    Finalize purchase

Fluxo completo de compra de ingresso com PIX

    ${user}    Create Dictionary    
    ...    name=teste3    
    ...    email=teste3@gmail.com    
    ...    password=teste123
    ...    confirmPassword=teste123

    # Cadastrar usuário
    Go to signup page
    Submit signup from    ${user}

    # Fazer login
    Go to login page
    Submit login form    ${user}

    # Ver detalhes do filme The Avengers
    Click movie details    68e8f82e97de05f696275f08

    # Selecionar sessão
    Select session    68e8f82e97de05f696275f1b

    # Selecionar assento
    Select seat    E6

    # Continuar para pagamento
    Continue to payment

    # Selecionar PIX
    Select pix payment

    # Finalizar compra
    Finalize purchase

Fluxo completo de compra de ingresso com transferência bancária

    ${user}    Create Dictionary    
    ...    name=teste4    
    ...    email=teste4@gmail.com    
    ...    password=teste123
    ...    confirmPassword=teste123

    # Cadastrar usuário
    Go to signup page
    Submit signup from    ${user}

    # Fazer login
    Go to login page
    Submit login form    ${user}

    # Ver detalhes do filme The Avengers
    Click movie details    68e8f82e97de05f696275f08

    # Selecionar sessão
    Select session    68e8f82e97de05f696275f1b

    # Selecionar assento
    Select seat    E6

    # Continuar para pagamento
    Continue to payment

    # Selecionar transferência bancária
    Select bank transfer payment

    # Finalizar compra
    Finalize purchase