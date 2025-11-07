*** Settings ***
Documentation    Ações e elementos base para os testes

Library    Browser

Resource    env.resource



*** Keywords ***
Start Session

    New Browser    browser=chromium    headless=False
    New Page    ${BASE_URL}
