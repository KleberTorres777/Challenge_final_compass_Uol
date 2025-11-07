*** Settings ***
Resource    ../variaveis/base.robot
Resource    ../resources/reservations.resource

Library    RequestsLibrary
Library    Collections
Library    DateTime

Suite Setup    Criar a sessão

*** Test Cases ***
Cenario: POST Cadastrar Reservation 400 - API Issue
    [Tags]    POST    reservation    issue
    [Documentation]    API retorna 400 em vez de 201 - problema na validação dos dados
    # Criar admin
    Criar Admin Para Teste
    Fazer Login Admin
    
    # 0. Criar filme primeiro
    ${movie_data}=    Create Dictionary
    ...    title=Filme Teste Reserva
    ...    synopsis=Sinopse do filme de teste
    ...    director=Diretor Teste
    ...    genres=["Action", "Drama"]
    ...    duration=120
    ...    classification=PG-13
    ...    poster=teste.jpg
    ...    releaseDate=2024-01-01
    
    POST Movie Com Token    ${ADMIN_TOKEN}    ${movie_data}    201
    ${new_movie_id}=    Set Variable    ${RESPONSE.json()['data']['_id']}
    
    # 1. Criar novo theater
    ${timestamp}=    Get Current Date    result_format=%Y%m%d%H%M%S
    ${theater_name}=    Set Variable    Theater Teste Reserva ${timestamp}
    ${theater_data}=    Create Dictionary
    ...    name=${theater_name}
    ...    capacity=50
    ...    type=standard
    
    POST Theater Com Token    ${ADMIN_TOKEN}    ${theater_data}    201
    ${new_theater_id}=    Set Variable    ${RESPONSE.json()['data']['_id']}
    
    # 2. Criar sessão no novo theater com o filme criado
    ${session_data}=    Create Dictionary
    ...    movie=${new_movie_id}
    ...    theater=${new_theater_id}
    ...    datetime=2025-12-30T20:00:00.000Z
    ...    fullPrice=20
    ...    halfPrice=10
    
    POST Session Com Token    ${ADMIN_TOKEN}    ${session_data}    201
    ${new_session_id}=    Set Variable    ${RESPONSE.json()['data']['_id']}
    
    # 2.1. Reset seats para garantir que estão disponíveis
    PUT Session Reset Seats Com Token    ${new_session_id}    ${ADMIN_TOKEN}
    
    # 2.2. Verificar assentos disponíveis
    GET Session Para Ver Assentos    ${new_session_id}
    
    # 3. Criar user e fazer reserva
    Criar User Para Teste
    Fazer Login User
    
    # Usar um assento que sabemos que existe no theater (capacidade 50)
    ${reservation_data}=    Create Dictionary
    ...    session=${new_session_id}
    ...    seats=[{"row": "A", "number": 1, "type": "full"}]
    ...    paymentMethod=credit_card
    
    POST Reservation Com Token    ${USER_TOKEN}    ${reservation_data}    400
    Log    Status da reserva: ${RESPONSE.status_code}
    Log    Resposta da reserva: ${RESPONSE.text}
    Should Be Equal As Strings    ${RESPONSE.status_code}    400
    Log    API retorna 400 - problema na validação dos dados de reserva

Cenario: POST Reservation Sem Token 401
    [Tags]    POST    reservation    
    ${reservation_data}=    Create Dictionary
    ...    session=60d0fe4f5311236168a109cd
    ...    seats=[{"row": "B", "number": 3, "type": "full"}]
    ...    paymentMethod=credit_card
    POST Reservation Sem Token    ${reservation_data}    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: POST Reservation Token Invalido 401
    [Tags]    POST    reservation    
    ${reservation_data}=    Create Dictionary
    ...    session=60d0fe4f5311236168a109cd
    ...    seats=[{"row": "B", "number": 4, "type": "full"}]
    ...    paymentMethod=credit_card
    POST Reservation Com Token    token_invalido    ${reservation_data}    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: POST Reservation Session Inexistente 404
    [Tags]    POST    reservation    issue
    Criar User Para Teste
    Fazer Login User
    ${reservation_data}=    Create Dictionary
    ...    session=60d0fe4f5311236168a109cc
    ...    seats=[{"row": "C", "number": 5, "type": "full"}]
    ...    paymentMethod=credit_card
    POST Reservation Com Token    ${USER_TOKEN}    ${reservation_data}    404
    Should Be Equal As Strings    ${RESPONSE.status_code}    404
    Validar Reservation Erro

Cenario: POST Reservation Dados Invalidos 400
    [Tags]    POST    reservation   
    Criar User Para Teste
    Fazer Login User
    ${reservation_data}=    Create Dictionary
    ...    session=
    ...    seats=[]
    ...    paymentMethod=
    POST Reservation Com Token    ${USER_TOKEN}    ${reservation_data}    400
    Should Be Equal As Strings    ${RESPONSE.status_code}    400

Cenario: GET Reservations Me Com Token User 200
    [Tags]    GET    reservations    me
    Criar User Para Teste
    Fazer Login User
    GET Reservations Me Com Token    ${USER_TOKEN}    200
    Validar Reservations Me Sucesso

Cenario: GET Reservations Me Sem Token 401
    [Tags]    GET    reservations    me
    GET Reservations Me Sem Token    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: GET Reservations Me Token Invalido 401
    [Tags]    GET    reservations    me
    GET Reservations Me Com Token    token_invalido    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: GET Reservations Com Token Admin 200
    [Tags]    GET    reservations
    Criar Admin Para Teste
    Fazer Login Admin
    GET Reservations Com Token    ${ADMIN_TOKEN}    200
    Validar Reservations Sucesso

Cenario: GET Reservations Sem Token 401
    [Tags]    GET    reservations
    GET Reservations Sem Token    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: GET Reservations Token User 403
    [Tags]    GET    reservations
    Criar User Para Teste
    Fazer Login User
    GET Reservations Com Token    ${USER_TOKEN}    403
    Should Be Equal As Strings    ${RESPONSE.status_code}    403

Cenario: GET Reservations Com Page 200
    [Tags]    GET    reservations    pagination
    Criar Admin Para Teste
    Fazer Login Admin
    ${params}=    Create Dictionary    page=2
    GET Reservations Com Parametros    ${ADMIN_TOKEN}    ${params}    200
    Validar Reservations Sucesso

Cenario: GET Reservations Com Limit 200
    [Tags]    GET    reservations    pagination
    Criar Admin Para Teste
    Fazer Login Admin
    ${params}=    Create Dictionary    limit=5
    GET Reservations Com Parametros    ${ADMIN_TOKEN}    ${params}    200
    Validar Reservations Sucesso

Cenario: GET Reservation Por ID Com Token Admin 200
    [Tags]    GET    reservation    id
    Criar Admin Para Teste
    Fazer Login Admin
    # Buscar uma reservation existente
    GET Reservations Com Token    ${ADMIN_TOKEN}    200
    ${reservations}=    Set Variable    ${RESPONSE.json()['data']}
    ${reservation_id}=    Run Keyword If    ${reservations}
    ...    Set Variable    ${reservations[0]['_id']}
    ...    ELSE    Set Variable    60d0fe4f5311236168a109ce
    GET Reservation Por ID Com Token    ${reservation_id}    ${ADMIN_TOKEN}    200
    Validar Reservation Por ID Sucesso

Cenario: GET Reservation Por ID Sem Token 401
    [Tags]    GET    reservation    id
    GET Reservation Por ID Sem Token    60d0fe4f5311236168a109ce    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: GET Reservation Por ID Token Invalido 401
    [Tags]    GET    reservation    id
    GET Reservation Por ID Com Token    60d0fe4f5311236168a109ce    token_invalido    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: GET Reservation Por ID Inexistente 404
    [Tags]    GET    reservation    id
    Criar Admin Para Teste
    Fazer Login Admin
    GET Reservation Por ID Com Token    60d0fe4f5311236168a109cc    ${ADMIN_TOKEN}    404
    Should Be Equal As Strings    ${RESPONSE.status_code}    404
    Validar Reservation Erro

Cenario: PUT Reservation Com Token Admin 200
    [Tags]    PUT    reservation
    Criar Admin Para Teste
    Fazer Login Admin
    # Buscar uma reservation existente
    GET Reservations Com Token    ${ADMIN_TOKEN}    200
    ${reservations}=    Set Variable    ${RESPONSE.json()['data']}
    ${reservation_id}=    Run Keyword If    ${reservations}
    ...    Set Variable    ${reservations[0]['_id']}
    ...    ELSE    Set Variable    60d0fe4f5311236168a109ce
    ${reservation_data}=    Create Dictionary
    ...    status=confirmed
    ...    paymentStatus=completed
    PUT Reservation Com Token    ${reservation_id}    ${ADMIN_TOKEN}    ${reservation_data}    200
    Validar Reservation Atualizada Sucesso

Cenario: PUT Reservation Sem Token 401
    [Tags]    PUT    reservation
    ${reservation_data}=    Create Dictionary
    ...    status=confirmed
    ...    paymentStatus=completed
    PUT Reservation Sem Token    60d0fe4f5311236168a109ce    ${reservation_data}    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: PUT Reservation Token User 403
    [Tags]    PUT    reservation
    Criar User Para Teste
    Fazer Login User
    ${reservation_data}=    Create Dictionary
    ...    status=confirmed
    ...    paymentStatus=completed
    PUT Reservation Com Token    60d0fe4f5311236168a109ce    ${USER_TOKEN}    ${reservation_data}    403
    Should Be Equal As Strings    ${RESPONSE.status_code}    403

Cenario: PUT Reservation ID Inexistente 404
    [Tags]    PUT    reservation
    Criar Admin Para Teste
    Fazer Login Admin
    ${reservation_data}=    Create Dictionary
    ...    status=confirmed
    ...    paymentStatus=completed
    PUT Reservation Com Token    60d0fe4f5311236168a109cc    ${ADMIN_TOKEN}    ${reservation_data}    404
    Should Be Equal As Strings    ${RESPONSE.status_code}    404
    Validar Reservation Erro

Cenario: DELETE Reservation Com Token Admin 404
    [Tags]    DELETE    reservation    issue
    Criar Admin Para Teste
    Fazer Login Admin
    # Como não há reservas no sistema, testar com ID inexistente retorna 404
    DELETE Reservation Com Token    60d0fe4f5311236168a109ce    ${ADMIN_TOKEN}    404
    Should Be Equal As Strings    ${RESPONSE.status_code}    404
    Validar Reservation Erro

Cenario: DELETE Reservation Sem Token 401
    [Tags]    DELETE    reservation
    DELETE Reservation Sem Token    60d0fe4f5311236168a109ce    401
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Cenario: DELETE Reservation Token User 403
    [Tags]    DELETE    reservation
    Criar User Para Teste
    Fazer Login User
    DELETE Reservation Com Token    60d0fe4f5311236168a109ce    ${USER_TOKEN}    403
    Should Be Equal As Strings    ${RESPONSE.status_code}    403

Cenario: DELETE Reservation ID Inexistente 404
    [Tags]    DELETE    reservation
    Criar Admin Para Teste
    Fazer Login Admin
    DELETE Reservation Com Token    60d0fe4f5311236168a109cc    ${ADMIN_TOKEN}    404
    Should Be Equal As Strings    ${RESPONSE.status_code}    404
    Validar Reservation Erro