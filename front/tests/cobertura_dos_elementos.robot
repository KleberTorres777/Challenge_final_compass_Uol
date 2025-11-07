*** Settings ***
Documentation    Verificação de cobertura de elementos UI

Resource    ../resources/base.resource

Test Setup    Start Session
Test Teardown    Take Screenshot

*** Test Cases ***
Verificar elementos da página de cadastro

    Go To    ${BASE_URL}/register
    
    # Verificar se todos os elementos existem
    Wait For Elements State    id=name    visible
    Wait For Elements State    id=email    visible  
    Wait For Elements State    id=password    visible
    Wait For Elements State    id=confirmPassword    visible
    Wait For Elements State    css=button[type="submit"]    visible
    
    Log    Todos os elementos de cadastro estão presentes

Verificar elementos da página de login

    Go To    ${BASE_URL}/login
    
    Wait For Elements State    id=email    visible
    Wait For Elements State    id=password    visible
    Wait For Elements State    css=button[type="submit"]    visible
    
    Log    Todos os elementos de login estão presentes

Verificar elementos da página de filmes

    Go To    ${BASE_URL}/movies
    
    Wait For Elements State    css=a[href*="/movies/"]    visible
    
    Log    Elementos de filmes estão presentes