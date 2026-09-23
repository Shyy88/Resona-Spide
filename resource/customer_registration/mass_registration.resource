*** Settings ***
Documentation       Page Resource untuk halaman Customer > Mass Registration
...                 (upload file .xlsx untuk maintenance data customer secara massal).

Library    SeleniumLibrary
Library    ScreenCapLibrary
Library    DateTime
Library    OperatingSystem

Resource            ../authentication/Login.resource
Resource            ../config.resource


*** Variables ***

### Sidebar Menu ###
${MENU_CUSTOMER_LI}                    //li[@id='Main_mnuCustomer']
${MENU_CUSTOMER}                       //li[@id='Main_mnuCustomer']/a
${MENU_CUSTOMER_MASS_REGISTRATION}     //a[@id='Main_mnuMassRegistration']
${MENU_DASHBOARD}                      //a[@href='../Home/Home.aspx']

### Customer Mass Registration Page ###
${HEADER_CUSTOMER_MASS_REGISTRATION}   (//h1[@class='title m-0'])[1]
${BROWSE_FILE}                         //input[@id='Main_fuBrowse']
${BTN_UPLOAD_FILE}                     id=ctl00_Main_rbUpload

${UPLOAD_FILE_XLSX}                    ${EXECDIR}${/}data${/}Uploads${/}CustomerRegist.xlsx
${UPLOAD_FILE_ALREADY_EXIST}           ${EXECDIR}${/}data${/}Uploads${/}CustomerMaintc_03.xlsx


*** Keywords ***

Kembali Ke Dashboard
    [Documentation]    Reset state halaman ke Dashboard sebelum membuka menu Customer, dengan
    ...                klik link "Dashboard" di top nav (<a href="../Home/Home.aspx">, lihat
    ...                hasil inspect DevTools: elemen ini ada di dalam <ol id="top-nav">).
    ...                PENTING: dibutuhkan karena elemen sidebar (Main_mnuCustomer) cuma ada
    ...                di view Dashboard. Kalau test sebelumnya berakhir di halaman module lain
    ...                (mis. Mass Maintenance) dan Test Setup langsung coba "Open Customer Menu"
    ...                tanpa reset dulu, sidebar-nya sudah tidak ada di DOM dan
    ...                "Wait Until Element Is Visible" akan timeout/gagal.

    Switch To Dashboard Frame
    Wait Until Element Is Visible    ${MENU_DASHBOARD}    ${TIMEOUT}
    Click Element    ${MENU_DASHBOARD}
    Wait Until Element Is Visible    ${MENU_CUSTOMER_LI}    ${TIMEOUT}

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
        Wait Until Element Is Visible    ${MENU_CUSTOMER_MASS_REGISTRATION}    ${TIMEOUT}
    END

Go To Customer Mass Registration
    [Documentation]    Navigasi ke halaman Customer > Mass Maintenance. Selalu diawali balik
    ...                ke Dashboard dulu (lihat "Kembali Ke Dashboard") supaya navigasi ini
    ...                konsisten baik dipanggil dari state awal (Dashboard segar) maupun dari
    ...                state sisa test case sebelumnya (mis. masih di halaman Mass Maintenance).
    Kembali Ke Dashboard
    Open Customer Menu
    Click Element    ${MENU_CUSTOMER_MASS_REGISTRATION}

Upload Mass Registration File
    [Documentation]    Pilih file .xlsx, klik tombol Upload, lalu terima alert KONFIRMASI upload
    ...                (alert pertama, contoh: "Are you sure you want to upload this file?").
    ...                Alert KEDUA (pesan sukses/gagal) ditangani terpisah lewat
    ...                "Verify Mass Maintenance Upload Result", supaya isi pesannya bisa di-assert.
    [Arguments]    ${file_path}
    File Should Exist    ${file_path}
    Wait Until Element Is Visible    ${BROWSE_FILE}    ${TIMEOUT}
    Choose File    ${BROWSE_FILE}    ${file_path}

    Sleep    1s
    Scroll Element Into View    ${BTN_UPLOAD_FILE}
    Wait Until Element Is Visible    ${BTN_UPLOAD_FILE}    ${TIMEOUT}
    Wait Until Element Is Enabled    ${BTN_UPLOAD_FILE}    ${TIMEOUT}

    Click Element    ${BTN_UPLOAD_FILE}

    Handle Alert    action=ACCEPT    timeout=${TIMEOUT}

Verify Mass Registration Upload Result
    [Documentation]    Menunggu alert KEDUA (pesan sukses/error) muncul, memverifikasi isi
    ...                teksnya sesuai ekspektasi (alert otomatis di-accept setelah match),
    ...                lalu ambil screenshot. Catatan: screenshot diambil SETELAH alert
    ...                di-accept karena native alert browser tidak ikut ter-capture di
    ...                screenshot Selenium (sama seperti kasus Verify Login Failed).
    [Arguments]    ${expected_message}
    Alert Should Be Present    text=${expected_message}    timeout=${TIMEOUT}
    ${timestamp}=    Get Timestamp
    Create Directory    ${SCREENSHOT_DIR}
    ScreenCapLibrary.Set Screenshot Directory    ${SCREENSHOT_DIR}
    ScreenCapLibrary.Take Screenshot    mass_registration_upload_${timestamp}