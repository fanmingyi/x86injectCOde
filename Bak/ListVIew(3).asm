.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include windows.inc
include msvcrt.inc
includelib msvcrt.lib


include user32.inc
.code 


InsertColum  proc  hWnd:HWND,dwCol:DWORD,szTitle:LPSTR,dwWith:DWORD
	LOCAL @lvc:LVCOLUMN
	
	;内存置为0
	invoke crt_memset,addr @lvc,0,type  @lvc
	
	
	
	mov @lvc.imask,LVCF_FMT or LVCF_TEXT or LVCF_WIDTH
	;左对齐
	mov @lvc.fmt,LVCFMT_LEFT
	;指定宽度
	push dwWith
	pop @lvc.lx
	
	;标题
	push szTitle
	pop @lvc.pszText
	
	
	;发送信息插入列
	invoke SendMessage,hWnd,LVM_INSERTCOLUMN,dwCol, addr @lvc
	
	
	
	
	
	
	ret

InsertColum endp



InsertItem proc hWnd:HWND,szTitle:LPSTR,dwUserData:DWORD
	LOCAL @li:LVITEM
	
	invoke crt_memset,addr @li,0,type  @li
	
	mov @li.imask, LVIF_TEXT OR LVIF_PARAM
	
	push szTitle
	
	pop @li.pszText
	
	push dwUserData
	
	pop @li.lParam
	
	;插入一个条目
	invoke SendMessage,hWnd,LVM_INSERTITEM,0,addr @li
	
	
	ret

InsertItem endp

SetIemText proc  hWnd:HWND,dwRow:DWORD,dwCol:DWORD,szTitle:LPSTR
	LOCAL @li:LVITEM
	
	invoke crt_memset,addr @li,0,type  @li
	
	mov @li.imask, LVIF_TEXT 
	
	
	;指定行
	push dwRow
	pop @li.iItem
	
	
	;指定列
	push dwCol
	pop @li.iSubItem

	push szTitle
	pop @li.pszText
	
	
	invoke SendMessage,hWnd,LVM_SETITEMTEXT,0,addr @li
	
	
	ret

SetIemText endp

end 


