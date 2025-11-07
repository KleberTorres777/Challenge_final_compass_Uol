*** Settings ***
Documentation    Ações e elementos do componente de notificação

Library    Browser

*** Keywords ***
Notice should be
    [Arguments]    ${expected_text}

    ${element}    Set Variable    css=.notice p 

    Wait For Elements State    ${element}    
    ...    visible    5
    
    ${message}    Get Text    ${element}
    Should Be Equal    ${message}    ${expected_text}