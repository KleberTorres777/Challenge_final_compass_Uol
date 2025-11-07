*** Settings ***
Documentation     Elementos e ações da página de cadastro

Library    Browser
Resource    ../env.resource

*** Keywords ***
Go to signup page
    Go To    ${BASE_URL}/register
    
    # Checkpoint
    Wait For Elements State    css=h1:has-text("Cadastro")    visible    5
    Get Text                   css=h1:has-text("Cadastro")    equal    Cadastro

Submit signup from
    [Arguments]    ${user}

    Fill Text    id=name    ${user}[name]
    Fill Text    id=email    ${user}[email]
    Fill Text    id=password    ${user}[password]
    Fill Text    id=confirmPassword    ${user}[password]

    Click    css=button[type="submit"]