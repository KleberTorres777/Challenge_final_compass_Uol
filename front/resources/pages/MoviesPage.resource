*** Settings ***
Documentation    Elementos e ações da página de filmes

Library    Browser
Resource    ../env.resource

*** Keywords ***
Go to movies page
    Go To    ${BASE_URL}/movies

Click movie details
    [Arguments]    ${movie_name}    ${movie_id}
    Click    css=a[href="/movies/${movie_id}"]