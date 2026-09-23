*** Settings ***
Documentation       Test case untuk fitur Customer > Maintenance, khusus bagian update Email
...                 pada Account customer (tambah email baru & simpan perubahan).

Resource            ../../resource/config.resource
Resource            ../../resource/authentication/Login.resource
Resource            ../../resource/customer_maintenance/maintenance.resource

Variables            ../../resource/env_variables.py
Variables            ../../data/customer_maintenance.yaml

Suite Setup          Login Sebagai Maker
Suite Teardown        Close Application
Test Setup            Buka Halaman Customer Maintenance
Test Teardown         Stop Test Recording

Test Tags            customer    maintenance


*** Test Cases ***
Tambah Email Baru Pada Account Customer Berhasil
    [Documentation]    Memastikan penambahan New Email pada Account customer berhasil disimpan
    ...                (alert konfirmasi setelah Save), popup Detail Email menampilkan hasilnya
    ...                dan bisa ditutup, lalu perubahan berhasil di-submit untuk approval.
    [Tags]    positive    smoke
    Search Customer By CIF    ${CIF}
    Click Edit Email Icon    ${ACCOUNT_NUMBER}
    Tambah Email Baru    ${EMAIL_ADDRESS}
    Save Email Changes
    Click Email Count Link    ${ACCOUNT_NUMBER}
    Close Email Detail
    Submit Changes For Approval

*** Keywords ***
Login Sebagai Maker
    [Documentation]    Suite setup: buka browser lalu login sekali untuk seluruh suite ini
    ...                (login tidak perlu diulang tiap test case, cukup navigasi halamannya
    ...                saja yang di-reset tiap test lewat Test Setup).
    Open Application
    Login    ${MAKER_USERNAME}    ${MAKER_PASSWORD}
    Verify Login Success

Buka Halaman Customer Maintenance
    [Documentation]    Test setup: mulai rekaman video, lalu navigasi FRESH ke halaman
    ...                Customer > Maintenance untuk tiap test case, supaya state pencarian
    ...                CIF / popup Detail Email dari test sebelumnya tidak terbawa.
    Start Test Recording    ${TEST NAME}
    Go To Customer Maintenance