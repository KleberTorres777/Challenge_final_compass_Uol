*** Settings ***
Documentation     Elementos e ações da página de login

Library    Browser
Resource    ../env.resource

*** Keywords ***
Go to login page
    Go To    ${BASE_URL}/login
    
    # Checkpoint
    Wait For Elements State    css=h1:has-text("Login")    visible    5
    Get Text                   css=h1:has-text("Login")    equal    Login

Submit login form
    [Arguments]    ${user}

    Fill Text    id=email    ${user}[email]
    Fill Text    id=password    ${user}[password]

    Click    css=button[type="submit"]