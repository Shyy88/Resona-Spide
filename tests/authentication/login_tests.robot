*** Settings ***
Documentation       Test case untuk fitur Login SPIDER.
...                 Mencakup skenario login sukses (maker & checker) dan
...                 skenario login gagal (username salah, password salah,
...                 dan field kosong).

Resource            ../../resource/config.resource
Resource            ../../resource/authentication/Login.resource

Variables           ../../resource/env_variables.py
Variables           ../../data/maker_checker_credentials.yaml

Suite Setup         Open Application
Suite Teardown      Close Application
Test Setup          Start Test Recording    ${TEST NAME}
Test Teardown       Run Keywords
...                     Stop Test Recording
...                     AND
...                     Reload Login Page

Test Tags           login    authentication


*** Variables ***
${INVALID_USERNAME}        user_tidak_terdaftar
${INVALID_PASSWORD}        PasswordSalah123



*** Test Cases ***
Login Sukses Dengan Kredensial Maker Yang Valid
    [Documentation]    Memastikan user dengan role Maker dapat login dan
    ...                masuk ke halaman dashboard.
    [Tags]    positive    smoke
    Login    ${MAKER_USERNAME}    ${MAKER_PASSWORD}
    Verify Login Success

Login Sukses Dengan Kredensial Checker Yang Valid
    [Documentation]    Memastikan user dengan role Checker dapat login dan
    ...                masuk ke halaman dashboard.
    [Tags]    positive    smoke
    Login    ${CHECKER_USERNAME}    ${CHECKER_PASSWORD}
    Verify Login Success

Login Gagal Dengan Username Salah
    [Documentation]    Memastikan sistem menolak login dengan username yang
    ...                tidak terdaftar dan menampilkan pesan error yang sesuai.
    [Tags]    negative
    Login    ${INVALID_USERNAME}    ${MAKER_PASSWORD}
    Verify Login Failed    ${INVALID LOGIN ERROR MESSAGE}

Login Gagal Dengan Password Salah
    [Documentation]    Memastikan sistem menolak login dengan password yang
    ...                salah untuk username yang valid.
    [Tags]    negative
    Login    ${MAKER_USERNAME}    ${INVALID_PASSWORD}
    Verify Login Failed    ${INVALID LOGIN ERROR MESSAGE}



*** Keywords ***
Reload Login Page
    [Documentation]    Mengembalikan browser ke halaman login yang bersih
    ...                setelah setiap test, supaya test berikutnya tidak
    ...                terpengaruh state (misal alert lama atau frame yang
    ...                masih ke dashboard).
    Go To    ${URL}
