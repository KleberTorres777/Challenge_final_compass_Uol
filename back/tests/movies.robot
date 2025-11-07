*** Settings ***
Resource    ../variaveis/base.robot
Resource    ../resources/movies.resource

Library    RequestsLibrary
Library    Collections

Suite Setup    Criar a sessão

*** Test Cases ***
Cenario: GET Movies Sem Parametros 200
    [Tags]    GET    movies
    GET Movies Sem Parametros    200
    Validar Movies Sucesso

Cenario: GET Movies Com Filtro Por Title
    [Tags]    GET    movies    filter
    ${params}=    Create Dictionary    title=Shawshank
    GET Movies Com Parametros    ${params}    200
    Validar Movies Sucesso

Cenario: GET Movies Com Filtro Por Genre
    [Tags]    GET    movies    filter
    ${params}=    Create Dictionary    genre=Drama
    GET Movies Com Parametros    ${params}    200
    Validar Movies Sucesso

Cenario: GET Movies Com Sort Por Title
    [Tags]    GET    movies    sort
    ${params}=    Create Dictionary    sort=title
    GET Movies Com Parametros    ${params}    200
    Validar Movies Sucesso

Cenario: GET Movies Com Sort Por ReleaseDate
    [Tags]    GET    movies    sort
    ${params}=    Create Dictionary    sort=releaseDate
    GET Movies Com Parametros    ${params}    200
    Validar Movies Sucesso

Cenario: GET Movies Com Page
    [Tags]    GET    movies    pagination
    ${params}=    Create Dictionary    page=2
    GET Movies Com Parametros    ${params}    200
    Validar Movies Sucesso

Cenario: GET Movies Com Multiplos Parametros
    [Tags]    GET    movies    complex
    ${params}=    Create Dictionary    
    ...    genre=Drama
    ...    sort=title
    ...    limit=5
    ...    page=1
    GET Movies Com Parametros    ${params}    200
    Validar Movies Sucesso

Cenario: GET Movie Por ID Valido 200
    [Tags]    GET    movie    id
    GET Movie Por ID    68dc716c050c98523bcd9f94    200
    Validar Movie Por ID Sucesso

Cenario: GET Movie Por ID Invalido 400
    [Tags]    GET    movie    id    issue
    GET Movie Por ID    id_invalido    400
    Should Be Equal As Strings    ${RESPONSE.status_code}    400
    Validar Movie Erro

Cenario: GET Movie Por ID Inexistente 404
    [Tags]    GET    movie    id
    GET Movie Por ID    60d0fe4f5311236168a109cc    404
    Should Be Equal As Strings    ${RESPONSE.status_code}    404
    Validar Movie Erro

Cenario: POST Cadastrar Movie 201 - Admin Com Sucesso
    [Tags]    POST    movie    admin
    Criar Admin Para Teste
    Fazer Login Admin
    ${login_response}=    Set Variable    ${RESPONSE}
    Should Be Equal As Strings    ${login_response.status_code}    200    Login deve ter sucesso
    Should Be Equal As Strings    ${login_response.json()['data']['role']}    admin    Deve ser admin real
    POST Cadastrar Movie    ${ADMIN_TOKEN}
    Should Be Equal As Strings    ${RESPONSE.status_code}    201
    Validar Se Movie Foi Criado

Cenario: POST Movie Sem Token 401
    [Tags]    POST    movie
    ${movie_data}=    Create Dictionary
    ...    title=Filme Teste
    ...    synopsis=Sinopse do filme teste
    ...    director=Diretor Teste
    ...    genres=["Action"]
    ...    duration=120
    ...    classification=PG-13
    ...    poster=teste.jpg
    ...    releaseDate=2024-01-01
    POST Movie Sem Token    ${movie_data}    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: POST Movie Token Invalido 401
    [Tags]    POST    movie
    ${movie_data}=    Create Dictionary
    ...    title=Filme Teste
    ...    synopsis=Sinopse do filme teste
    ...    director=Diretor Teste
    ...    genres=["Action"]
    ...    duration=120
    ...    classification=PG-13
    ...    poster=teste.jpg
    ...    releaseDate=2024-01-01
    POST Movie Com Token    token_invalido    ${movie_data}    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: POST Movie Dados Invalidos 401
    [Tags]    POST    movie
    ${movie_data}=    Create Dictionary
    ...    title=
    ...    synopsis=
    POST Movie Com Token    token_admin    ${movie_data}    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: PUT Movie Com Sucesso 200
    [Tags]    PUT    movie
    Criar Admin Para Teste
    Fazer Login Admin
    # Primeiro criar um filme
    POST Cadastrar Movie    ${ADMIN_TOKEN}
    Should Be Equal As Strings    ${RESPONSE.status_code}    201
    ${movie_id}=    Set Variable    ${RESPONSE.json()['data']['_id']}
    # Depois atualizar o filme criado
    ${movie_data}=    Create Dictionary
    ...    title=Filme Atualizado
    ...    synopsis=Nova sinopse
    ...    director=Novo Diretor
    ...    genres=["Action", "Thriller"]
    ...    duration=130
    ...    classification=R
    ...    poster=novo.jpg
    ...    releaseDate=2024-12-01
    PUT Movie Com Token    ${movie_id}    ${ADMIN_TOKEN}    ${movie_data}    200
    Validar Movie Atualizado Sucesso

Cenario: PUT Movie Sem Token 401
    [Tags]    PUT    movie
    ${movie_data}=    Create Dictionary
    ...    title=Filme Atualizado
    ...    synopsis=Nova sinopse
    ...    director=Novo Diretor
    ...    genres=["Action"]
    ...    duration=130
    ...    classification=R
    ...    poster=novo.jpg
    ...    releaseDate=2024-12-01
    PUT Movie Sem Token    68dc716c050c98523bcd9f94    ${movie_data}    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: PUT Movie Token Invalido 401
    [Tags]    PUT    movie
    ${movie_data}=    Create Dictionary
    ...    title=Filme Atualizado
    ...    synopsis=Nova sinopse
    ...    director=Novo Diretor
    ...    genres=["Action"]
    ...    duration=130
    ...    classification=R
    ...    poster=novo.jpg
    ...    releaseDate=2024-12-01
    PUT Movie Com Token    68dc716c050c98523bcd9f94    token_invalido    ${movie_data}    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: PUT Movie ID Inexistente 404
    [Tags]    PUT    movie
    Criar Admin Para Teste
    Fazer Login Admin
    ${movie_data}=    Create Dictionary
    ...    title=Filme Atualizado
    ...    synopsis=Nova sinopse
    ...    director=Novo Diretor
    ...    genres=["Action"]
    ...    duration=130
    ...    classification=R
    ...    poster=novo.jpg
    ...    releaseDate=2024-12-01
    PUT Movie Com Token    60d0fe4f5311236168a109cc    ${ADMIN_TOKEN}    ${movie_data}    404
    Should Be Equal As Strings    ${RESPONSE.status_code}    404
    Validar Movie Erro
    # Não limpar admin existente

Cenario: DELETE Movie Com Sucesso 200
    [Tags]    DELETE    movie
    Criar Movie Para Teste
    # Primeiro cria o filme via API para ter um ID válido
    POST Cadastrar Movie    ${ADMIN_TOKEN}
    ${movie_id}=    Set Variable    ${RESPONSE.json()['data']['_id']}
    # Depois deleta o filme criado
    DELETE Movie Com Token    ${movie_id}    ${ADMIN_TOKEN}    200
    Validar Movie Deletado Sucesso

Cenario: DELETE Movie Sem Token 401
    [Tags]    DELETE    movie
    DELETE Movie Sem Token    68dc716c050c98523bcd9f94    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: DELETE Movie Token Invalido 401
    [Tags]    DELETE    movie
    DELETE Movie Com Token    68dc716c050c98523bcd9f94    token_invalido    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: DELETE Movie ID Inexistente 404
    [Tags]    DELETE    movie
    Criar Admin Para Teste
    Fazer Login Admin
    DELETE Movie Com Token    60d0fe4f5311236168a109cc    ${ADMIN_TOKEN}    404
    Should Be Equal As Strings    ${RESPONSE.status_code}    404
    Validar Movie Erro
    # Não limpar admin existente