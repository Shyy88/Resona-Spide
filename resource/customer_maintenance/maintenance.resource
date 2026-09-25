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
${MENU_DASHBOARD}                   //a[@href='../Home/Home.aspx']

#### CUSTOMER MAINTENANCE PAGE ###
${HEADER_CUSTOMER_INFORMATION}      (//h4[@class='panel-title text-success'])[2]
${INPUT_CIF}                        //input[@id='Main_tbCIF']
${BTN_SEARCH}                       //span[@id='ctl00_Main_rbSearch']

### After Search ###
${CUSTOMER_CIF}                       //span[@id='Main_lblCIF']
${CUSTOMER_NAME}                      //span[@id='Main_lblName']
${CUSTOMER_ACCOUNT_TABLE}             //table[@id='ctl00_Main_rgAccount_ctl00']

### Edit Account Customer with Add Email ###
${EMAIL_POPUP_FRAME}                //iframe[@name='PopUpWindow']
${EMAIL_GRID_TABLE}                 //table[@id='ctl00_Main_gridEmail_ctl00']
${BTN_ADD_EMAIL_ROW}                //span[@id='ctl00_Main_rbAdd']
${BTN_REMOVE_EMAIL_ROW}             //span[@id='ctl00_Main_rbDelete']
${CHECKBOX_EMAIL_LAST_ROW}          (//table[@id='ctl00_Main_gridEmail_ctl00']//input[@type='checkbox'])[last()]
${INPUT_NEW_EMAIL_LAST_ROW}         (//table[@id='ctl00_Main_gridEmail_ctl00']//input[contains(@id,'tbNewEmail')])[last()]
${BTN_SAVE_EMAIL}                   //span[@id='ctl00_Main_rbSave']

### After Save Email Open Detail Email ###
${EMAIL_DETAIL_TABLE}              //div[@id='ctl00_Main_gridEmail_GridData']
${BTN_CLOSE_EMAIL_DETAIL}          //span[@id='ctl00_Main_rbClose']

### Submit Changes ###
${BTN_SUBMIT_CHANGES}              //span[@id='ctl00_Main_rbSave']

### Validasi Format Email ###
${EMAIL_VALIDATION_MSG_LAST_ROW}    (//table[@id='ctl00_Main_gridEmail_ctl00']//span[@class='Validation'])[last()]

*** Keywords ***

Klik Elemen Dengan Javascript
    [Documentation]    Klik elemen via JavaScript (element.click()), bypass pengecekan
    ...                overlap/visibility Selenium. Dipakai untuk elemen di baris top-nav yang
    ...                ketutupan <div class="col-sm-12"> -- kemungkinan besar itu container
    ...                widget/card Dashboard, yang cuma nutupin baris nav SELAGI konten
    ...                Dashboard masih ditampilkan (begitu pindah halaman, area nav bersih).
    [Arguments]    ${locator}
    ${element}=    Get WebElement    ${locator}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${element}

Kembali Ke Dashboard
    [Documentation]    Reset state halaman ke Dashboard sebelum membuka menu Customer -- TAPI
    ...                cuma kalau belum di Dashboard. Kalau sidebar (Main_mnuCustomer) sudah
    ...                visible, berarti kita SUDAH di Dashboard (mis. baru saja login), jadi
    ...                skip klik sama sekali -- gak perlu, dan menghindari klik redundan di
    ...                zona rawan overlap (lihat "Klik Elemen Dengan Javascript").
    Switch To Dashboard Frame
    ${sudah_di_dashboard}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${MENU_CUSTOMER_LI}    3s
    IF    not ${sudah_di_dashboard}
        Wait Until Element Is Visible    ${MENU_DASHBOARD}    ${TIMEOUT}
        Klik Elemen Dengan Javascript    ${MENU_DASHBOARD}
        Wait Until Element Is Visible    ${MENU_CUSTOMER_LI}    ${TIMEOUT}
    END

Open Customer Menu
    [Documentation]    Membuka (expand) menu "Customer" di sidebar kalau belum dalam kondisi
    ...                expanded. Menu dianggap sudah terbuka kalau <li id="Main_mnuCustomer">
    ...                punya class "active". Klik pakai JS karena langkah ini SELALU terjadi
    ...                selagi konten Dashboard masih tampil (zona rawan overlap).
    Switch To Dashboard Frame
    Wait Until Element Is Visible    ${MENU_CUSTOMER_LI}    ${TIMEOUT}
    ${classes}=    Get Element Attribute    ${MENU_CUSTOMER_LI}    class
    ${is_open}=    Run Keyword And Return Status    Should Contain    ${classes}    active
    IF    not ${is_open}
        Klik Elemen Dengan Javascript    ${MENU_CUSTOMER}
        Wait Until Element Is Visible    ${MENU_CUSTOMER_MAINTENANCE}    ${TIMEOUT}
    END

Go To Customer Maintenance
    [Documentation]    Navigasi ke halaman Customer > Maintenance. Selalu diawali balik ke
    ...                Dashboard dulu (lihat "Kembali Ke Dashboard") supaya konsisten baik
    ...                dipanggil dari state awal maupun dari state sisa test case sebelumnya.
    ...                "Set Selenium Speed" ditaruh di sini supaya SEMUA aksi (klik, input
    ...                text, dll) di seluruh resource ini otomatis dikasih jeda -- membantu
    ...                elemen yang butuh waktu render/AJAX postback (RadControls) selesai
    ...                dulu sebelum aksi berikutnya, tanpa perlu nambah Sleep manual di tiap
    ...                keyword satu-satu.
    Set Selenium Speed    0.5s
    Kembali Ke Dashboard
    Open Customer Menu
    Click Element    ${MENU_CUSTOMER_MAINTENANCE}

Search Customer By CIF
    [Documentation]    Isi CIF di kolom pencarian lalu klik Search, kemudian menunggu data
    ...                customer (CIF & Name) muncul sebagai konfirmasi pencarian berhasil.
    [Arguments]    ${cif}
    Wait Until Element Is Visible    ${INPUT_CIF}    ${TIMEOUT}
    Input Text    ${INPUT_CIF}    ${cif}
    Click Element    ${BTN_SEARCH}
    Wait Until Element Is Visible    ${CUSTOMER_CIF}    ${TIMEOUT}

Click Edit Email Icon
    [Documentation]    Klik ikon edit email (pensil) pada baris dengan Account No tertentu di
    ...                grid Account Information, lalu SWITCH ke iframe "PopUpWindow" tempat
    ...                popup Detail (Add/Remove/Current Email/New Email/Save/Close) dirender
    ...                (halaman EmailDetail.aspx?Type=Edit...). PENTING: iframe ini nested DI
    ...                DALAM frame Home/Home.aspx (bukan di top-level document), jadi kita
    ...                TETAP di context frame Home/Home.aspx (tidak perlu Unselect Frame),
    ...                cukup Select Frame langsung ke iframe PopUpWindow ini.
    [Arguments]    ${account_no}
    ${locator}=    Set Variable
    ...    ${CUSTOMER_ACCOUNT_TABLE}//tr[td[normalize-space()='${account_no}']]//a[contains(@class,'sprites-16-edit')]
    Wait Until Element Is Visible    ${locator}    ${TIMEOUT}
    Klik Elemen Dengan Javascript    ${locator}
    Wait Until Element Is Visible    ${EMAIL_POPUP_FRAME}    ${TIMEOUT}
    Select Frame    ${EMAIL_POPUP_FRAME}
    Wait Until Element Is Visible    ${EMAIL_GRID_TABLE}    ${TIMEOUT}

Click Email Count Link
    [Documentation]    Klik link "Detail Email" (angka di kolom "Email Address") pada baris
    ...                dengan Account No tertentu -- membuka popup DETAIL EMAIL (view). Popup
    ...                ini kemungkinan pakai RadWindow + iframe yang sama dengan popup Edit
    ...                (PopUpWindow), cuma src beda (Type=View), jadi perlu Select Frame lagi
    ...                ke situ sebelum mencari ${EMAIL_DETAIL_TABLE}.
    [Arguments]    ${account_no}
    ${locator}=    Set Variable
    ...    ${CUSTOMER_ACCOUNT_TABLE}//tr[td[normalize-space()='${account_no}']]//a[contains(@id,'lbEmailCount')]
    Wait Until Element Is Visible    ${locator}    ${TIMEOUT}
    Klik Elemen Dengan Javascript    ${locator}
    Wait Until Element Is Visible    ${EMAIL_POPUP_FRAME}    ${TIMEOUT}
    Select Frame    ${EMAIL_POPUP_FRAME}
    Wait Until Element Is Visible    ${EMAIL_DETAIL_TABLE}    ${TIMEOUT}

Close Email Detail
    [Documentation]    Klik tombol "Close" pada popup Detail Email (masih di dalam iframe
    ...                PopUpWindow), lalu KEMBALI ke frame Dashboard -- supaya konteks frame
    ...                bersih untuk test/langkah berikutnya, sama seperti pola di
    ...                "Save Email Changes".
    Wait Until Element Is Visible    ${BTN_CLOSE_EMAIL_DETAIL}    ${TIMEOUT}
    Klik Elemen Dengan Javascript    ${BTN_CLOSE_EMAIL_DETAIL}
    Switch To Dashboard Frame

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
    ...                Catatan: seluruh langkah setelah "Add New Email Row" dibungkus
    ...                "Wait Until Keyword Succeeds" -- RadGrid Telerik ini AJAX postback-nya
    ...                bisa lebih dari 1 tahap render, jadi walau jumlah baris sudah bertambah
    ...                (dicek "Jumlah Baris Email Bertambah"), DOM-nya masih bisa berubah lagi
    ...                sesaat kemudian, bikin locator [last()] sempat "not found" kalau kita
    ...                langsung Input Text tepat di celah re-render itu.
    [Arguments]    ${new_email}
    Add New Email Row
    Wait Until Keyword Succeeds    ${TIMEOUT}    0.5s
    ...    Centang Checkbox Dan Isi Email Baris Terakhir    ${new_email}

Centang Checkbox Dan Isi Email Baris Terakhir
    [Documentation]    Helper: centang checkbox + isi New Email di baris terakhir grid Email.
    ...                Dipakai oleh "Tambah Email Baru", dibungkus retry karena rawan kena
    ...                celah re-render RadGrid (lihat dokumentasi "Tambah Email Baru").
    [Arguments]    ${new_email}
    Wait Until Element Is Visible    ${CHECKBOX_EMAIL_LAST_ROW}    3s
    Select Checkbox    ${CHECKBOX_EMAIL_LAST_ROW}
    Wait Until Element Is Enabled    ${INPUT_NEW_EMAIL_LAST_ROW}    3s
    Input Text    ${INPUT_NEW_EMAIL_LAST_ROW}    ${new_email}

Save Email Changes
    [Documentation]    Klik tombol "Save" pada popup Detail Email (masih di dalam iframe
    ...                PopUp) untuk menyimpan perubahan, verifikasi alert konfirmasi, ambil
    ...                screenshot sebagai bukti, lalu KEMBALI ke frame Dashboard -- karena
    ...                popup ini otomatis tertutup setelah Save, dan langkah selanjutnya
    ...                (Click Email Count Link) perlu mengakses grid Account yang ada di level
    ...                Dashboard, bukan di iframe ini.
    Wait Until Element Is Visible    ${BTN_SAVE_EMAIL}    ${TIMEOUT}
    Click Element    ${BTN_SAVE_EMAIL}
    Alert Should Be Present    text=Are you sure you want to save changes?    timeout=${TIMEOUT}
    Take Timestamped Screenshot    save_email_changes
    Switch To Dashboard Frame

Submit Changes For Approval
    [Documentation]    Klik tombol "Save"/Submit di halaman Customer Maintenance (bukan di
    ...                dalam popup Email) untuk mengirim perubahan ke approval. Muncul 2 alert
    ...                berurutan: alert pertama konfirmasi submit (teks belum diverifikasi,
    ...                masih di-accept generik), alert kedua pesan sukses "Update successfully
    ...                processed to approval" yang divalidasi teksnya, lalu ambil screenshot
    ...                sebagai bukti hasil akhir.
    ...                Catatan: elemen ini butuh di-scroll dulu supaya visible (kemungkinan
    ...                lazy-render/CSS yang baru aktif saat masuk viewport). Scroll-nya pakai
    ...                JavaScript (element.scrollIntoView()), BUKAN "Scroll Element Into View"
    ...                bawaan Selenium -- yang itu sempat menyebabkan
    ...                MoveTargetOutOfBoundsException (native mouse-move action Selenium/
    ...                geckodriver salah hitung posisi viewport).
    ${element}=    Get WebElement    ${BTN_SUBMIT_CHANGES}
    Execute Javascript    arguments[0].scrollIntoView(true);    ARGUMENTS    ${element}
    Wait Until Element Is Visible    ${BTN_SUBMIT_CHANGES}    ${TIMEOUT}
    Klik Elemen Dengan Javascript    ${BTN_SUBMIT_CHANGES}
    Handle Alert    action=ACCEPT    timeout=${TIMEOUT}
    Alert Should Be Present    text=Update successfully processed to approval    timeout=${TIMEOUT}
    Take Timestamped Screenshot    submit_changes_success

Verify Email Format Invalid
    [Documentation]    Memverifikasi validasi client-side "* Invalid format" muncul pada baris
    ...                New Email paling akhir, ditandai icon warning kuning + tooltip, lalu
    ...                ambil screenshot sebagai bukti validasi ter-trigger.
    ...                PENTING: "Press Keys ... TAB" wajib dipanggil sebelum cek visibility --
    ...                validator ASP.NET/Telerik ini biasanya baru ter-trigger saat field
    ...                kehilangan fokus (event onblur), bukan langsung setelah Input Text.
    ...                Tanpa blur ini, validasi gak pernah muncul dan Wait Until Element Is
    ...                Visible bakal timeout walau input-nya memang invalid.
    Press Keys    ${INPUT_NEW_EMAIL_LAST_ROW}    TAB
    Wait Until Element Is Visible    ${EMAIL_VALIDATION_MSG_LAST_ROW}    ${TIMEOUT}
    ${title}=    Get Element Attribute    ${EMAIL_VALIDATION_MSG_LAST_ROW}    title
    Should Contain    ${title}    Invalid format
    Take Timestamped Screenshot    email_format_invalid

Take Timestamped Screenshot
    [Documentation]    Ambil screenshot dengan nama file mengandung Test Name + label + timestamp,
    ...                disimpan di ${SCREENSHOT_DIR} -- folder yang sama dipakai semua screenshot
    ...                di suite ini (pola sama seperti login_success/login_failed di Login.resource).
    [Arguments]    ${label}
    ${timestamp}=    Get Timestamp
    Create Directory    ${SCREENSHOT_DIR}
    ScreenCapLibrary.Set Screenshot Directory    ${SCREENSHOT_DIR}
    ScreenCapLibrary.Take Screenshot    ${TEST NAME}_${label}_${timestamp}