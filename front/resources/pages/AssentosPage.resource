*** Settings ***
Documentation    Elementos e ações da página de assentos

Library    Browser
Resource    ../env.resource

*** Keywords ***
Click movie details by id
    [Arguments]    ${movie_id}
    Click    css=a[href="/movies/${movie_id}"]

Select session by id
    [Arguments]    ${session_id}
    Click    css=a[href="/sessions/${session_id}"]

Select all seats
    FOR    ${row}    IN    A    B    C    D    E    F    G
        FOR    ${seat}    IN RANGE    1    9
            Click    css=button[title*="Fileira ${row}, Assento ${seat}"]
        END
    END
    # Fileira H tem apenas 4 assentos
    FOR    ${seat}    IN RANGE    1    5
        Click    css=button[title*="Fileira H, Assento ${seat}"]
    END