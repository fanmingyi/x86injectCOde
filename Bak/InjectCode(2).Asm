.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include InjectCode.inc
include windows.inc
include msvcrt.inc
includelib msvcrt.lib


include kernel32.inc
include user32.inc

.data
	g_szCol0Title db "PID",0
	g_szCol1Title db "��������",0
	g_szFmt db "%d",0
	g_aryOpcodeBuf db 1000h dup(0)
	g_dwOpcodeSize dd 0
	g_szErr db "����﷨����",0
.code

start:
	
	
	invoke GetModuleHandle,NULL
	mov		hInstance,eax

    invoke InitCommonControls
	invoke DialogBoxParam,hInstance,IDD_DIALOG1,NULL,addr DlgProc,NULL
	invoke ExitProcess,0

;########################################################################


Assembly proc   USES ebx edi ebx dwCip:DWORD,hDlg:HWND
	
	LOCAL @dwLineCount:DWORD
	LOCAL @hEdt:HWND
	LOCAL @xed:XEDPARSE
	
	
			
	invoke GetDlgItem,hDlg,EDT_ASM
	mov @hEdt,eax 
	
	;��ñ༭�����������
	invoke SendMessage,@hEdt,EM_GETLINECOUNT,0,0
	
	mov @dwLineCount,eax
	
	xor ebx,ebx
	mov g_dwOpcodeSize,0

	;����ÿ��
	.while ebx < @dwLineCount
		

		invoke RtlZeroMemory,addr @xed,type @xed
		;��ȡһ�л���ı�
		lea eax,@xed.instr_
		mov word ptr [eax],XEDPARSE_MAXBUFSIZE	
		invoke SendMessage,@hEdt,EM_GETLINE,ebx,eax
	
		;���
		mov ecx,dwCip
		add ecx,g_dwOpcodeSize
		lea eax,@xed.cip
		mov dword ptr [eax],ecx
		invoke XEDParseAssemble,addr @xed
		
		
		
		.if eax==XEDPARSE_ERROR
		
			invoke MessageBox,NULL,NULL,offset g_szErr,MB_OK
			mov eax,FALSE
			
			ret
		.endif
		
		;����������
		mov edi,offset g_aryOpcodeBuf
		add edi,g_dwOpcodeSize
		invoke crt_memcpy,edi,addr @xed.dest,@xed.dest_size
		
		
		;���»�������볤��
		mov eax,@xed.dest_size
		add g_dwOpcodeSize,eax
		
		
	
		inc ebx
	.endw
	
	mov eax,TRUE
	ret

Assembly endp


Inject proc dwPid:DWORD,hDlg:HWND
	LOCAL @hProc:HWND
	LOCAL @lpAddr:LPVOID
	LOCAL @dwBytesWrited:DWORD
	
	
	;�õ����̾������ȡ����Ȩ��
	invoke OpenProcess,PROCESS_ALL_ACCESS,FALSE,dwPid
	
	;������̾��
	mov @hProc,eax
	
	;�����ڴ�
	invoke VirtualAllocEx,@hProc,NULL,1000h,MEM_COMMIT,PAGE_EXECUTE_READWRITE
	
	;�����ڴ�����
	mov @lpAddr,eax
	
	invoke Assembly,@lpAddr,hDlg
	.if eax==FALSE
		ret
		
	.endif
	
	;�ڴ�д��
	invoke  WriteProcessMemory,@hProc,@lpAddr,offset g_aryOpcodeBuf,g_dwOpcodeSize,addr @dwBytesWrited
	
	;�����߳�
	invoke CreateRemoteThread,@hProc,NULL,0,@lpAddr,NULL,0,NULL
		
	ret

Inject endp

Refresh proc hLstv:HWND
	LOCAL @hSnap:HANDLE
	LOCAL @pe32:PROCESSENTRY32 
	LOCAL @szBuff[32]:BYTE
	
	invoke SendMessage,hLstv,LVM_DELETEALLITEMS ,0, 0
	
 	invoke RtlZeroMemory,addr @pe32,type @pe32
	mov @pe32.dwSize,type @pe32

	
	;������̿���
	invoke CreateToolhelp32Snapshot,TH32CS_SNAPPROCESS,0
	

	mov @hSnap,eax
	
	;�������յĳ���
	invoke Process32First ,  @hSnap,addr @pe32
		

	
	.if eax !=0
	
		.repeat
			invoke wsprintf,addr @szBuff,offset g_szFmt,@pe32.th32ProcessID
			
			;������
			invoke InsertItem,hLstv,addr @szBuff,@pe32.th32ProcessID
			
			;�����ı�
			invoke SetIemText,hLstv,0,1,addr @pe32.szExeFile
			
			invoke Process32Next,@hSnap,addr @pe32
		.until eax==0	
	.endif
	
	
	
	ret

Refresh endp



OnInitDlg proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL @hLstv:HWND
	
	
	;�õ����ھ����Ӧ�Ŀؼ�
	invoke GetDlgItem,hWin,LV_PROCESS
	
	mov @hLstv,eax
	
	;�б��ؼ���������
	invoke InsertColum,@hLstv,0,offset g_szCol0Title,60
	;
	invoke InsertColum,@hLstv,1,offset g_szCol1Title,60
	
	
	
	;�����ߺ�ѡ��
	;������Ϣ������
	invoke SendMessage,@hLstv,LVM_GETEXTENDEDLISTVIEWSTYLE,0, 0
	
	or eax,LVS_EX_FULLROWSELECT or LVS_EX_GRIDLINES
	
	invoke SendMessage,@hLstv,LVM_SETEXTENDEDLISTVIEWSTYLE,0, eax
	
	
	invoke Refresh, @hLstv
	mov eax,TRUE
	ret
OnInitDlg endp



DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL @hLstv:HWND
	LOCAL @li:LVITEM
	LOCAL @dwItem:DWORD
	
	
	
	mov	eax,uMsg
	.if eax==WM_INITDIALOG
		invoke OnInitDlg,hWin,uMsg,wParam,lParam
	.elseif eax==WM_COMMAND
		mov ebx,wParam
		
		invoke GetDlgItem,hWin,LV_PROCESS
		mov @hLstv,eax
		
		.if bx == BTN_REFRESH
			;�õ����ھ����Ӧ�Ŀؼ�
			invoke Refresh,@hLstv
			
		.elseif bx ==BTN_INJECT
			;ִ��ע��
			invoke SendMessage,@hLstv,LVM_GETSELECTIONMARK,0,0
			mov @dwItem,eax
			
			.if eax !=-1
				invoke RtlZeroMemory,addr @li,type @li	
				
				mov @li.imask,LVIF_PARAM
				push @dwItem
				pop @li.iItem
				invoke SendMessage,	@hLstv,LVM_GETITEM,0,addr @li
				mov eax,@li.lParam
				invoke Inject,@li.lParam,hWin			
			.endif
				
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp

end start