*** Settings ***
Documentation    Elementos e ações do fluxo de compra de ingressos

Library    Browser
Resource    ../env.resource

*** Keywords ***
Click movie details
    [Arguments]    ${movie_id}
    Go To    ${BASE_URL}/movies
    Click    css=a[href="/movies/${movie_id}"]

Select session
    [Arguments]    ${session_id}
    Click    css=a[href="/sessions/${session_id}"]

Select seat
    [Arguments]    ${seat}
    Click    css=button[title*="Fileira ${seat[0]}, Assento ${seat[1:]}"]

Continue to payment
    Click    css=.checkout-button

Select credit card payment
    Click    css=span:has-text("Cartão de Crédito")

Select debit card payment
    Click    css=span:has-text("Cartão de Débito")

Select pix payment
    Click    css=span:has-text("PIX")

Select bank transfer payment
    Click    css=span:has-text("Transferência Bancária")

Finalize purchase
    Click    css=.btn-checkout