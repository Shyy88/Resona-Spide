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

### Edit Account Customer with Add Email ###
${EMAIL_GRID_TABLE}                 //table[@id='ctl00_Main_gridEmail_ctl00']
${BTN_ADD_EMAIL_ROW}                //span[@id='ctl00_Main_rbAdd']
${BTN_REMOVE_EMAIL_ROW}             //span[@id='ctl00_Main_rbDelete']
${CHECKBOX_EMAIL_LAST_ROW}          (//table[@id='ctl00_Main_gridEmail_ctl00']//input[@type='checkbox'])[last()]
${INPUT_NEW_EMAIL_LAST_ROW}         (//table[@id='ctl00_Main_gridEmail_ctl00']//input[contains(@id,'tbNewEmail')])[last()]
${BTN_SAVE_EMAIL}                   //span[@id='ctl00_Main_rbSave']

### After Save Email ###
${EMAIL_DETAIL_TABLE}              //div[@id='ctl00_Main_gridEmail_GridData']
${BTN_CLOSE_EMAIL_DETAIL}          //span[@id='ctl00_Main_rbClose']


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

Input New Email By Current Email
    [Documentation]    Isi New Email pada baris grid Email yang match dengan Current Email
    ...                tertentu. Checkbox baris tsb WAJIB dicentang dulu, karena textbox New
    ...                Email disabled (attribute disabled="disabled") sampai checkbox-nya
    ...                dicentang (di-trigger JS onclick="checkItem(this);" pada checkbox).
    [Arguments]    ${current_email}    ${new_email}
    ${row}=    Set Variable    ${EMAIL_GRID_TABLE}//tr[td[normalize-space()='${current_email}']]
    ${checkbox}=    Set Variable    ${row}//input[@type='checkbox']
    ${input}=    Set Variable    ${row}//input[contains(@id,'tbNewEmail')]

    Wait Until Element Is Visible    ${checkbox}    ${TIMEOUT}
    Select Checkbox    ${checkbox}
    Wait Until Element Is Enabled    ${input}    ${TIMEOUT}
    Input Text    ${input}    ${new_email}

Add New Email Row
    [Documentation]    Klik tombol "+ Add" untuk menambah baris baru di grid Email, lalu
    ...                menunggu baris barunya benar-benar muncul (jumlah checkbox bertambah)
    ...                sebelum lanjut interaksi ke baris tersebut. Perlu ditunggu karena ini
    ...                RadButton (AJAX postback), bukan native button yang langsung instan.
    ${count_before}=    Get Element Count    ${EMAIL_GRID_TABLE}//input[@type='checkbox']
    Click Element    ${BTN_ADD_EMAIL_ROW}
    Wait Until Keyword Succeeds    ${TIMEOUT}    0.5s
    ...    Jumlah Baris Email Bertambah    ${count_before}

Jumlah Baris Email Bertambah
    [Documentation]    Helper untuk polling jumlah baris grid Email sampai bertambah dari
    ...                ${count_before}. Dipakai oleh "Add New Email Row".
    [Arguments]    ${count_before}
    ${count_now}=    Get Element Count    ${EMAIL_GRID_TABLE}//input[@type='checkbox']
    Should Be True    ${count_now} > ${count_before}

Tambah Email Baru
    [Documentation]    Flow lengkap menambah New Email pada baris baru: klik "+ Add" ->
    ...                centang checkbox baris paling akhir -> isi New Email di baris yang sama.
    ...                Urutan checkbox-dulu-baru-input WAJIB, karena textbox New Email disabled
    ...                sampai checkbox-nya dicentang (lihat onclick="checkItem(this);" di
    ...                checkbox-nya).
    [Arguments]    ${new_email}
    Add New Email Row
    Wait Until Element Is Visible    ${CHECKBOX_EMAIL_LAST_ROW}    ${TIMEOUT}
    Select Checkbox    ${CHECKBOX_EMAIL_LAST_ROW}
    Wait Until Element Is Enabled    ${INPUT_NEW_EMAIL_LAST_ROW}    ${TIMEOUT}
    Input Text    ${INPUT_NEW_EMAIL_LAST_ROW}    ${new_email}

Click Email Count Link
    [Documentation]    Klik link jumlah email (kolom "Email Address") pada baris dengan
    ...                Account No tertentu di grid Account Information, untuk membuka popup
    ...                "Detail" berisi grid Email. Locator dibuat dinamis berdasarkan Account No
    ...                (BUKAN hardcode index baris seperti "ctl05"), supaya tidak salah sasaran
    ...                kalau posisi/jumlah baris di grid berubah.
    [Arguments]    ${account_no}
    ${locator}=    Set Variable
    ...    ${CUSTOMER_ACCOUNT_TABLE}//tr[td[normalize-space()='${account_no}']]//a[contains(@id,'lbEmailCount')]
    Wait Until Element Is Visible    ${locator}    ${TIMEOUT}
    Click Element    ${locator}
    Wait Until Element Is Visible    ${EMAIL_DETAIL_TABLE}    ${TIMEOUT}

Save Email Changes
    [Documentation]    Klik tombol "Save" pada popup Detail Email untuk menyimpan perubahan
    ...                (email baru / email yang diupdate), lalu verifikasi alert konfirmasi
    ...                yang muncul setelahnya (alert otomatis di-accept setelah teks match,
    ...                cuma 1 alert -- beda dari flow Mass Maintenance yang ada 2 alert).
    Wait Until Element Is Visible    ${BTN_SAVE_EMAIL}    ${TIMEOUT}
    Click Element    ${BTN_SAVE_EMAIL}
    Alert Should Be Present    text=Are you sure you want to save changes?    timeout=${TIMEOUT}

Close Email Detail
    [Documentation]    Klik tombol "Close" pada popup Detail Email, lalu menunggu popup-nya
    ...                benar-benar hilang dari DOM (grid Email tidak lagi visible) supaya test
    ...                selanjutnya tidak nyangkut di state popup ini.
    Wait Until Element Is Visible    ${BTN_CLOSE_EMAIL_DETAIL}    ${TIMEOUT}
    Click Element    ${BTN_CLOSE_EMAIL_DETAIL}
    Wait Until Element Is Not Visible    ${EMAIL_DETAIL_TABLE}    ${TIMEOUT}