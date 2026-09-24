*** Settings ***
Documentation       Keyword umum yang dipakai lintas modul (browser setup, navigasi dasar).

Library    SeleniumLibrary
Library    ./webdriver_setup.py


*** Variables ***

${URL}              http://dev.profescipta.com/SPIDER/Security/Login.aspx?ReturnUrl=%2fSPIDER
${BROWSER}          firefox

${TIMEOUT}          40s
${IMPLICIT_WAIT}    15s


*** Keywords ***

Open Application
    [Documentation]    Membuka browser dan mengarah ke halaman awal aplikasi.
    ...                Driver browser (geckodriver/chromedriver/msedgedriver)
    ...                di-download & dicocokkan otomatis dengan versi browser
    ...                yang terpasang lewat webdriver-manager (lihat
    ...                resource/webdriver_setup.py), jadi tidak perlu
    ...                download/setup driver manual ke PATH.
    ${driver_path}=    Get Driver Path    ${BROWSER}
    Open Browser    ${URL}    ${BROWSER}    executable_path=${driver_path}
    Maximize Browser Window
    Set Selenium Timeout    ${TIMEOUT}
    Set Selenium Implicit Wait    ${IMPLICIT_WAIT}


Close Application
    [Documentation]    Menutup browser yang sedang terbuka.
    Close Browser








