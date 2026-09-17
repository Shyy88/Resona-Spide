*** Settings ***
Documentation       Page Resource untuk halaman Login.

Library    SeleniumLibrary
Library    ScreenCapLibrary
Library    DateTime
Library    OperatingSystem


*** Variables ***

${FRAME}                    //frame[@src='Home/Home.aspx']
${TIMEOUT}                  20s
${SCREENSHOT_DIR}           ${OUTPUT_DIR}/screenshots
${VIDEO_DIR}                ${OUTPUT_DIR}/videos

${USERNAME_INPUT}           //input[@id='tbUserName']
${PASSWORD_INPUT}           //input[@id='tbPassword']
${BTN_LOGIN}                //span[@id='rbtLogin']

#### AFTER LOGIN #####
${HEADER_DASHBOARD}         //header[@class='navbar header']
${BTN_LOGOUT}               //a[@id='lnkLogOut']


*** Keywords ***

Get Timestamp
    [Documentation]    Menghasilkan timestamp untuk penamaan file screenshot/video agar tidak tertimpa saat re-run.
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    RETURN    ${timestamp}

Input Username
    [Documentation]    Mengisi field username pada form login.
    [Arguments]    ${username}
    Wait Until Element Is Visible    ${USERNAME_INPUT}    ${TIMEOUT}
    Input Text    ${USERNAME_INPUT}    ${username}

Input Password
    [Documentation]    Mengisi field password pada form login.
    [Arguments]    ${password}
    Wait Until Element Is Visible    ${PASSWORD_INPUT}    ${TIMEOUT}
    Input Text    ${PASSWORD_INPUT}    ${password}

Click Login
    [Documentation]    Klik tombol/elemen login untuk submit form.
    Wait Until Element Is Visible    ${BTN_LOGIN}    ${TIMEOUT}
    Click Element    ${BTN_LOGIN}

Login
    [Documentation]    Melakukan proses login lengkap: switch frame, isi username & password, lalu submit.
    [Arguments]    ${username}    ${password}

    
    Input Username    ${username}
    Input Password    ${password}
    Click Login

Switch To Dashboard Frame
    [Documentation]    Berpindah ke frame dashboard setelah login berhasil.
    Unselect Frame
    Select Frame    ${FRAME}

Dashboard Header Should Be Visible
    [Documentation]    Helper: switch ke frame dashboard (FRESH dari top document setiap kali dipanggil),
    ...                lalu cek header dashboard sudah tampil. Dipanggil berulang oleh
    ...                "Wait Until Keyword Succeeds" di Verify Login Success, supaya tahan terhadap
    ...                frame yang masih dalam proses reload setelah login.
    Switch To Dashboard Frame
    Element Should Be Visible    ${HEADER_DASHBOARD}

Verify Login Success
    [Documentation]    Memverifikasi bahwa login berhasil dengan mengecek elemen header dan tombol logout di dashboard.
    ...                Frame di-select ULANG berkali-kali (bukan cuma sekali) karena setelah klik Login,
    ...                frame melakukan full page reload/postback. Kalau cuma Select Frame sekali lalu
    ...                langsung Wait Until Element Is Visible, Selenium bisa nyangkut di snapshot dokumen
    ...                frame yang LAMA (sebelum reload selesai), jadi elemen dashboard tidak pernah
    ...                ketemu walau ditunggu penuh ${TIMEOUT}.
    Wait Until Keyword Succeeds    ${TIMEOUT}    1s
    ...    Dashboard Header Should Be Visible
    Wait Until Element Is Visible    ${BTN_LOGOUT}    ${TIMEOUT}
    ${timestamp}=    Get Timestamp
    Create Directory    ${SCREENSHOT_DIR}
    ScreenCapLibrary.Set Screenshot Directory    ${SCREENSHOT_DIR}
    ScreenCapLibrary.Take Screenshot    login_success_${timestamp}

Verify Login Failed
    [Documentation]    Memverifikasi bahwa login gagal dengan mengecek native JS alert yang muncul.
    [Arguments]    ${expected_message}
    Wait Until Keyword Succeeds    5x    5s
    ...    Alert Should Be Present    text=${expected_message}
    ${timestamp}=    Get Timestamp
    Create Directory    ${SCREENSHOT_DIR}
    ScreenCapLibrary.Set Screenshot Directory    ${SCREENSHOT_DIR}
    ScreenCapLibrary.Take Screenshot    login_failed_${timestamp}

Start Test Recording
    [Documentation]    Memulai perekaman video untuk keseluruhan skenario test, dengan nama file mengandung timestamp.
    [Arguments]    ${test_name}
    ${timestamp}=    Get Timestamp
    Create Directory    ${VIDEO_DIR}
    ScreenCapLibrary.Set Screenshot Directory    ${VIDEO_DIR}
    Start Video Recording
    ...    name=${test_name}_${timestamp}
    ...    fps=8
    ...    size_percentage=0.5

Stop Test Recording
    [Documentation]    Menghentikan perekaman video setelah skenario test selesai.
    Stop Video Recording