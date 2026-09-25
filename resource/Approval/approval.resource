*** Settings ***
Documentation       Page Resource untuk halaman Login.

Library    SeleniumLibrary
Library    ScreenCapLibrary
Library    DateTime
Library    OperatingSystem
Resource            ../authentication/Login.resource
Resource            ../config.resource


*** Variables ***

${MENU_APPROVAL_LI}                    //li[@id='Main_mnuApproval']
${MENU_APPROVAL}                       //li[@id='Main_mnuApproval']/a

### Approval Menu Page ###
${ICON_PROCESS}                        //tr[td[contains(., 'Pending')]]//a[contains(@class, 'sprites-16-edit')]
${ICON_VIEW}                           //tr[td[contains(., 'Pending')]]//a[contains(@class, 'sprites-16-view')]

### Approval Process & View Page ###
${FRAME_APPROVAL}                      //iframe[@name='PopUpWindow']
${BTN_APPROVE}                         //span[@id='ctl00_Main_rbtApprove']
${BTN_REJECT}                          //span[@id='ctl00_Main_rbtReject']
${INPUT_REMARK}                        //textarea[@id='Main_tbRemark']
${BTN_CLOSE}                           //span[@id='ctl00_Main_rbtClose']