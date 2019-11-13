.486
.model flat, stdcall
option casemap :none
include /masm32/include/windows.inc
include /masm32/include/user32.inc
include /masm32/include/kernel32.inc
include /masm32/include/gdi32.inc
include /masm32/include/shell32.inc
include mfmplayer.inc                    ;m�zik i�in
include music.asm                        ;XM par�am�z� tablo halinde ekliyoruz  

includelib /masm32/lib/gdi32.lib
includelib /masm32/lib/shell32.lib
includelib /masm32/lib/user32.lib
includelib /masm32/lib/kernel32.lib
includelib mfmplayer.lib                 ;m�zik i�in
                                         ;Kulland���mz� yerel fonksiyonlar   
   Generate  PROTO :DWORD                
   WndProc   PROTO :DWORD,:DWORD,:DWORD,:DWORD 
   
.data?
hInstance   dd ?  ;program�n handle'�
hCode       dd ?  ;serialbox'�n handle'�
szName      db 26h dup(?)
szSerial    db 10 dup(?) 


.data
invalidname     db "Ba�ka bir isim deneyin :(",0
nameerr	        db "Isminizi girin!",0
wtext		db "0x94 keygen",0
defname	        db "0x94" ,0
aboutcap	db "About",0
dikkattxt       db "Serial: [Seriali kopyalay�p yap��t�r�n]",0           
abouttxt	db "Keygen by 0x94",13,10,13,10
		db "Program:",9,"[0x94]",13,10
		db "OS:",9,"Win10",13,10
		db "Date:",9,"13-11-2019",13,10,0
Serial          db "Serial:",0
fmat            db "%d",0

BT_CLIP                 =     200  ;clipboard butonu
BT_EXIT                 =     201  ;exit butonu
BT_ABOUT                =     202  ;about butonu
KEYGEN_ICON             =     101  ;iconun idsi
IDD_MAIN                =     103  ;dialo�un idsi
EDIT_NAME               =     1001 ;name editbox
EDIT_KEY                =     1002 ;serial
IDM_About	        =     1009 ;ekledi�imiz about men�s�n�n handle'�
SerialLabel             =     800
.code

start: 
 
   invoke GetModuleHandle, NULL ;Programa handle al
   mov hInstance,eax 
   invoke DialogBoxParam,hInstance,IDD_MAIN,0,ADDR WndProc,0 ;dialo�u g�ster
   invoke ExitProcess,0  ;program� kapat.
 
WndProc proc uses ebx hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
       .IF uMsg==WM_INITDIALOG
	 invoke mfmPlay, offset Music ;�al bakal�m
         invoke	 LoadIcon, hInstance, KEYGEN_ICON ;Keygene ikon y�kl�yoruz
         invoke	 SendMessage, hWin, WM_SETICON, ICON_BIG, eax ;Dialo�a iconu ekle
         invoke	 SetWindowTextA,hWin, offset wtext	;Dialo�un ba�l���n� de�i�tir.
	 invoke  SetDlgItemTextA, hWin, EDIT_NAME, offset defname ;ismi yaz
         invoke  SendDlgItemMessage, hWin, EDIT_NAME, EM_SETLIMITTEXT, 25h,0  ;editboxa 37 harfden fazlas�n� yazd�rma
     
	 invoke	 GetSystemMenu, hWin, FALSE ;system men�y� al
	      mov esi, eax ;ve eside sakla eax ��nk� de�i�ecek
         invoke GetDlgItem, hWin, EDIT_KEY ;serialin handle'�n� al ve sakla
              mov hCode,eax 
                      
         invoke	DeleteMenu , esi, SC_RESTORE, MF_BYCOMMAND ;restore,maximize ve size men�lerini ��kart
         invoke	DeleteMenu , esi, SC_MAXIMIZE, MF_BYCOMMAND
         invoke	DeleteMenu, esi, SC_SIZE, MF_BYCOMMAND
         invoke  AppendMenuA,esi,MF_STRING,IDM_About,offset aboutcap ;bizim aboutmen�s�n� ekle
         invoke	DrawMenuBar, hWin ;men�y� tekrar �iz
          xor eax,eax
            ret

.ELSEIF uMsg==WM_COMMAND  ;kullan�c� bir�eyler yapt�
	mov	eax, wParam
   .IF ax==EDIT_NAME   ;Name e mi dokundu ?
     shr eax,16
     .IF ax==EN_CHANGE   ;kullan�c� texti de�i�tirdi
	invoke Generate,hWin ;o zaman seriali olu�tur.
      	xor	eax, eax   
	RET

.ENDIF
.ENDIF
.IF ax==BT_CLIP
     
      invoke SendMessage,hCode,EM_SETSEL,0,-1; texti se�
      invoke SendMessage,hCode,WM_COPY,0,0 ;Clipboarda kopyal�yoruz
      invoke SendMessage,hCode,EM_SETSEL,-1,0; texti se�me
      xor eax,eax
      ret
     .ENDIF
.IF ax==BT_EXIT ;kullan�c� exit butonuna t�klad�
	jmp @close ;kapat o zaman
.ENDIF
 
.IF ax==BT_ABOUT ;kullan�c� about butonuna t�klad�
         invoke	MessageBoxA, hWin, offset abouttxt, offset aboutcap, 0 ;messagebox g�ster
.ENDIF
  
.ELSEIF uMsg==WM_SYSCOMMAND ;kullan�c� men�ye t�klad�
        mov	eax, wParam
     	   .IF ax == IDM_About  ;bu bizim about men�s�m� ?
         invoke	MessageBoxA, hWin, offset abouttxt, offset aboutcap, 0 ;messagebox g�ster
         xor eax,eax 
         .ENDIF                   
            
      .ELSEIF uMsg==WM_CLOSE ;kullan�c� dialo�u x ile kapatt�
@close:
	    invoke EndDialog,hWin,0     ;dialo�u kapat
                    ret
      .ENDIF
    xor eax,eax
       ret 
WndProc endp


Generate PROC	USES ebx ecx edx esi edi, _hWin:DWORD
	invoke	GetDlgItemText, _hWin, EDIT_NAME, ADDR szName, 26h ;ismi al
	cmp     eax,0  ;isimde bir�ey var m� ?
     	je      @@err  ;yoksa hata mesaj�n� g�ster   

  MOV EDX,01h
  XOR ECX,ECX
  XOR EBX,EBX
  MOV EAX,offset szName
L004:
  MOV BL,BYTE PTR [EAX]
  INC EAX
  CMP BL,0
  JE L015
  XOR EDX,EBX
  SHR EDX,04h
  ROL EBX,012h
  XOR EDX,EBX
  SBB EDX,-039h
  ADD ECX,EDX
  JMP L004
L015:
  BSWAP ECX
  ROL ECX,02h    ;ROR un tersi
  XOR ECX,02E837h
        
invoke wsprintfA,addr szSerial,addr fmat,ecx ;desimale �evir

;tam say� kontrol�
     MOV BL,BYTE PTR [szSerial] ;Serialden bir karakter al
     CMP BL,2Dh    ;"-" mi         
     JNZ @here     ;de�ilse her�ey normal, devam edelim 
     CMP EAX,0Ah   ;10 karakter mi?
     JA  @@err2    ;fazla ise hatal�
     invoke	SetDlgItemTextA, _hWin, EDIT_KEY, offset szSerial ;edit box'a serial'i yaz�yoruz 
     invoke	SetDlgItemTextA, _hWin, SerialLabel, offset dikkattxt ;label e uyar�m�z� yaz�yoruz
JMP fzk

@here: ; demekki pozitif bir say�

invoke	SetDlgItemTextA, _hWin, EDIT_KEY, offset szSerial ;edit box'a serial'i yaz�yoruz 
invoke	SetDlgItemTextA, _hWin, SerialLabel, offset Serial ;Labele "Serial:" yazd�r�yoruz

     
fzk:	xor	eax, eax
	RET
@@err:	invoke	SetDlgItemTextA, _hWin, EDIT_KEY, offset nameerr ;isim girilmedi
	jmp	fzk

@@err2:	
        invoke	SetDlgItemTextA, _hWin, SerialLabel, offset Serial ;Labele "Serial:" yazd�r�yoruz
        invoke	SetDlgItemTextA, _hWin, EDIT_KEY, offset invalidname ;ge�ersiz isim
	jmp	fzk

Generate	ENDP



end start