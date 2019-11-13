.486
.model flat, stdcall
option casemap :none
include /masm32/include/windows.inc
include /masm32/include/user32.inc
include /masm32/include/kernel32.inc
include /masm32/include/gdi32.inc
include /masm32/include/shell32.inc
include mfmplayer.inc                    ;müzik için
include music.asm                        ;XM parçamýzý tablo halinde ekliyoruz  

includelib /masm32/lib/gdi32.lib
includelib /masm32/lib/shell32.lib
includelib /masm32/lib/user32.lib
includelib /masm32/lib/kernel32.lib
includelib mfmplayer.lib                 ;müzik için
                                         ;Kullandýðýmzý yerel fonksiyonlar   
   Generate  PROTO :DWORD                
   WndProc   PROTO :DWORD,:DWORD,:DWORD,:DWORD 
   
.data?
hInstance   dd ?  ;programýn handle'ý
hCode       dd ?  ;serialbox'ýn handle'ý
szName      db 26h dup(?)
szSerial    db 10 dup(?) 


.data
invalidname     db "Baþka bir isim deneyin :(",0
nameerr	        db "Isminizi girin!",0
wtext		db "0x94 keygen",0
defname	        db "0x94" ,0
aboutcap	db "About",0
dikkattxt       db "Serial: [Seriali kopyalayýp yapýþtýrýn]",0           
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
IDD_MAIN                =     103  ;dialoðun idsi
EDIT_NAME               =     1001 ;name editbox
EDIT_KEY                =     1002 ;serial
IDM_About	        =     1009 ;eklediðimiz about menüsünün handle'ý
SerialLabel             =     800
.code

start: 
 
   invoke GetModuleHandle, NULL ;Programa handle al
   mov hInstance,eax 
   invoke DialogBoxParam,hInstance,IDD_MAIN,0,ADDR WndProc,0 ;dialoðu göster
   invoke ExitProcess,0  ;programý kapat.
 
WndProc proc uses ebx hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
       .IF uMsg==WM_INITDIALOG
	 invoke mfmPlay, offset Music ;çal bakalým
         invoke	 LoadIcon, hInstance, KEYGEN_ICON ;Keygene ikon yüklüyoruz
         invoke	 SendMessage, hWin, WM_SETICON, ICON_BIG, eax ;Dialoða iconu ekle
         invoke	 SetWindowTextA,hWin, offset wtext	;Dialoðun baþlýðýný deðiþtir.
	 invoke  SetDlgItemTextA, hWin, EDIT_NAME, offset defname ;ismi yaz
         invoke  SendDlgItemMessage, hWin, EDIT_NAME, EM_SETLIMITTEXT, 25h,0  ;editboxa 37 harfden fazlasýný yazdýrma
     
	 invoke	 GetSystemMenu, hWin, FALSE ;system menüyü al
	      mov esi, eax ;ve eside sakla eax çünkü deðiþecek
         invoke GetDlgItem, hWin, EDIT_KEY ;serialin handle'ýný al ve sakla
              mov hCode,eax 
                      
         invoke	DeleteMenu , esi, SC_RESTORE, MF_BYCOMMAND ;restore,maximize ve size menülerini çýkart
         invoke	DeleteMenu , esi, SC_MAXIMIZE, MF_BYCOMMAND
         invoke	DeleteMenu, esi, SC_SIZE, MF_BYCOMMAND
         invoke  AppendMenuA,esi,MF_STRING,IDM_About,offset aboutcap ;bizim aboutmenüsünü ekle
         invoke	DrawMenuBar, hWin ;menüyü tekrar çiz
          xor eax,eax
            ret

.ELSEIF uMsg==WM_COMMAND  ;kullanýcý birþeyler yaptý
	mov	eax, wParam
   .IF ax==EDIT_NAME   ;Name e mi dokundu ?
     shr eax,16
     .IF ax==EN_CHANGE   ;kullanýcý texti deðiþtirdi
	invoke Generate,hWin ;o zaman seriali oluþtur.
      	xor	eax, eax   
	RET

.ENDIF
.ENDIF
.IF ax==BT_CLIP
     
      invoke SendMessage,hCode,EM_SETSEL,0,-1; texti seç
      invoke SendMessage,hCode,WM_COPY,0,0 ;Clipboarda kopyalýyoruz
      invoke SendMessage,hCode,EM_SETSEL,-1,0; texti seçme
      xor eax,eax
      ret
     .ENDIF
.IF ax==BT_EXIT ;kullanýcý exit butonuna týkladý
	jmp @close ;kapat o zaman
.ENDIF
 
.IF ax==BT_ABOUT ;kullanýcý about butonuna týkladý
         invoke	MessageBoxA, hWin, offset abouttxt, offset aboutcap, 0 ;messagebox göster
.ENDIF
  
.ELSEIF uMsg==WM_SYSCOMMAND ;kullanýcý menüye týkladý
        mov	eax, wParam
     	   .IF ax == IDM_About  ;bu bizim about menüsümü ?
         invoke	MessageBoxA, hWin, offset abouttxt, offset aboutcap, 0 ;messagebox göster
         xor eax,eax 
         .ENDIF                   
            
      .ELSEIF uMsg==WM_CLOSE ;kullanýcý dialoðu x ile kapattý
@close:
	    invoke EndDialog,hWin,0     ;dialoðu kapat
                    ret
      .ENDIF
    xor eax,eax
       ret 
WndProc endp


Generate PROC	USES ebx ecx edx esi edi, _hWin:DWORD
	invoke	GetDlgItemText, _hWin, EDIT_NAME, ADDR szName, 26h ;ismi al
	cmp     eax,0  ;isimde birþey var mý ?
     	je      @@err  ;yoksa hata mesajýný göster   

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
        
invoke wsprintfA,addr szSerial,addr fmat,ecx ;desimale çevir

;tam sayý kontrolü
     MOV BL,BYTE PTR [szSerial] ;Serialden bir karakter al
     CMP BL,2Dh    ;"-" mi         
     JNZ @here     ;deðilse herþey normal, devam edelim 
     CMP EAX,0Ah   ;10 karakter mi?
     JA  @@err2    ;fazla ise hatalý
     invoke	SetDlgItemTextA, _hWin, EDIT_KEY, offset szSerial ;edit box'a serial'i yazýyoruz 
     invoke	SetDlgItemTextA, _hWin, SerialLabel, offset dikkattxt ;label e uyarýmýzý yazýyoruz
JMP fzk

@here: ; demekki pozitif bir sayý

invoke	SetDlgItemTextA, _hWin, EDIT_KEY, offset szSerial ;edit box'a serial'i yazýyoruz 
invoke	SetDlgItemTextA, _hWin, SerialLabel, offset Serial ;Labele "Serial:" yazdýrýyoruz

     
fzk:	xor	eax, eax
	RET
@@err:	invoke	SetDlgItemTextA, _hWin, EDIT_KEY, offset nameerr ;isim girilmedi
	jmp	fzk

@@err2:	
        invoke	SetDlgItemTextA, _hWin, SerialLabel, offset Serial ;Labele "Serial:" yazdýrýyoruz
        invoke	SetDlgItemTextA, _hWin, EDIT_KEY, offset invalidname ;geçersiz isim
	jmp	fzk

Generate	ENDP



end start