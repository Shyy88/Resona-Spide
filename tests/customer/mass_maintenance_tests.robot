*** Settings ***
Documentation       Test case untuk fitur Customer > Mass Maintenance (upload file .xlsx).
...                 Mencakup skenario upload berhasil dan upload gagal karena data
...                 (email/account) sudah terdaftar sebelumnya.

Resource            ../../resource/config.resource
Resource            ../../resource/authentication/Login.resource
Resource            ../../resource/customer_maintenance/mass_maintenance.resource

Variables            ../../resource/env_variables.py
Variables            ../../data/customer_mass_maintenance.yaml

Suite Setup          Login Sebagai Maker
Suite Teardown        Close Application
Test Setup            Buka Halaman Mass Maintenance
Test Teardown         Stop Test Recording

Test Tags            customer    mass-maintenance


*** Test Cases ***
Upload File Mass Maintenance Berhasil
    [Documentation]    Memastikan upload file .xlsx yang valid (data belum pernah di-upload
    ...                sebelumnya) berhasil dan menampilkan pesan sukses.
    [Tags]    positive    smoke
    Upload Mass Maintenance File    ${UPLOAD_FILE_XLSX}
    Verify Mass Maintenance Upload Result    ${UPLOAD FILE MAINTENANCE SUCCESS MESSAGE}

Upload File Mass Maintenance Gagal Karena Data Sudah Ada
    [Documentation]    Memastikan upload file .xlsx yang datanya (email/account) sudah
    ...                pernah di-upload sebelumnya ditolak, dengan pesan error yang sesuai.
    [Tags]    negative
    Upload Mass Maintenance File    ${UPLOAD_FILE_ALREADY_EXIST}
    Verify Mass Maintenance Upload Result    ${DATA UPLOAD FILE ALREADY EXIST MESSAGE}


*** Keywords ***
Login Sebagai Maker
    [Documentation]    Suite setup: buka browser lalu login sekali untuk seluruh suite ini
    ...                (login tidak perlu diulang tiap test case, cukup navigasi halamannya
    ...                saja yang di-reset tiap test lewat Test Setup).
    Open Application
    Login    ${MAKER_USERNAME}    ${MAKER_PASSWORD}
    Verify Login Success

Buka Halaman Mass Maintenance
    [Documentation]    Test setup: mulai rekaman video, lalu navigasi FRESH ke halaman
    ...                Customer > Mass Maintenance untuk tiap test case, supaya file input
    ...                dari test sebelumnya tidak membawa state lama.
    Start Test Recording    ${TEST NAME}
    Go To Customer Mass Maintenance