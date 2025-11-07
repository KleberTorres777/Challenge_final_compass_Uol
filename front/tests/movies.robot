*** Settings ***
Documentation    Cenários de testes da página de filmes

Resource    ../resources/base.resource
Resource    ../resources/pages/MoviesPage.resource

Test Setup    Start Session
Test Teardown    Take Screenshot
Library    String

*** Test Cases ***
Deve visualizar detalhes do filme The Avengers

    Go to movies page
    Click movie details    The Avengers    68e8f82e97de05f696275f08

Deve visualizar detalhes do filme Inception

    Go to movies page
    Click movie details    Inception    68e8f82e97de05f696275f07

Deve visualizar detalhes do filme The Shawshank Redemption

    Go to movies page
    Click movie details    The Shawshank Redemption    68e8f82e97de05f696275f09