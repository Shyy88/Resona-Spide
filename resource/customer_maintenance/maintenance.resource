*** Settings ***
Documentation       Page Resource untuk halaman Login.

Library    SeleniumLibrary
Library    ScreenCapLibrary
Library    DateTime
Library    OperatingSystem
Resource            ../authentication/Login.resource
Resource            ../config.resource

*** Variables ***

${MENU_CUSTOMER_LI}                 //li[@id='Main_mnuCustomer']
${MENU_CUSTOMER}                    //li[@id='Main_mnuCustomer']/a
${MENU_CUSTOMER_MAINTENANCE}        //a[@id='Main_mnuMaintenance']

#### CUSTOMER MAINTENANCE PAGE ###
${HEADER_CUSTOMER_INFORMATION}      (//h4[@class='panel-title text-success'])[2]
${INPUT_CIF}                        //input[@id='Main_tbCIF']
${BTN_SEARCH}                       //span[@id='ctl00_Main_rbSearch']

### After Search ###
${CUSTOMER_CIF}                       //span[@id='Main_lblCIF']
${CUSTOMER_NAME}                      //span[@id='Main_lblName']
${CUSTOMER_ACCOUNT_TABLE}             //table[@id='ctl00_Main_rgAccount_ctl00']





*** Keywords ***

Open Customer Menu
    [Documentation]    Membuka (expand) menu "Customer" di sidebar kalau belum dalam kondisi
    ...                expanded. Menu dianggap sudah terbuka kalau <li id="Main_mnuCustomer">
    ...                punya class "active" (lihat hasil inspect: class="hasChild active").
    Switch To Dashboard Frame
    Wait Until Element Is Visible    ${MENU_CUSTOMER_LI}    ${TIMEOUT}
    ${classes}=    Get Element Attribute    ${MENU_CUSTOMER_LI}    class
    ${is_open}=    Run Keyword And Return Status    Should Contain    ${classes}    active
    IF    not ${is_open}
        Click Element    ${MENU_CUSTOMER}
        Wait Until Element Is Visible    ${MENU_CUSTOMER_MAINTENANCE}    ${TIMEOUT}
    END

Go To Customer Maintenance
    [Documentation]    Navigasi ke halaman Customer > Maintenance.
    Open Customer Menu
    Click Element    ${MENU_CUSTOMER_MAINTENANCE}

Click Edit Email Icon
    [Documentation]    Klik ikon edit email pada baris dengan Account No tertentu di grid Account Information.
    [Arguments]    ${account_no}
    ${locator}=    Set Variable
    ...    ${CUSTOMER_ACCOUNT_TABLE}//tr[td[normalize-space()='${account_no}']]//a[contains(@class,'sprites-16-edit')]
    Wait Until Element Is Visible    ${locator}    ${TIMEOUT}
    Click Element    ${locator}
