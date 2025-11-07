*** Settings ***
Library    RequestsLibrary

*** Variables ***
${BASE_URL}    http://localhost:3000/api/v1


*** Keywords ***
Criar a sessão
    Create Session    api    ${BASE_URL}
