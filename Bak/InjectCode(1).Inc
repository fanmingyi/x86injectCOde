
include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include shell32.inc
include 

includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib shell32.lib
include XedParse.inc

DlgProc			PROTO	:HWND,:UINT,:WPARAM,:LPARAM
InsertColum     PROTO  :HWND,:DWORD,:LPSTR,:DWORD

InsertItem 		PROTO   hWnd:HWND,szTitle:LPSTR,dwUserData:DWORD
SetIemText 		PROTO  hWnd:HWND,dwRow:DWORD,dwCol:DWORD,szTitle:LPSTR


.const

IDD_DIALOG1			equ 101
LV_PROCESS          equ 1001
EDT_ASM          equ 1002
BTN_REFRESH          equ 1003
BTN_INJECT          equ 1004
;#########################################################################

.data?

hInstance			dd ?

;#########################################################################
