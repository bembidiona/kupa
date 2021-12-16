#NoEnv
#Persistent
#SingleInstance force

;-----------------------------------------------------
;	Auto Reaload Script on Save  
;-----------------------------------------------------
; ~^s::                            		;~ Let pass the key's native function 
;     WinGetActiveTitle, windowTitle
;         If InStr(windowTitle, .ahk)
;             Reload
;     		Return
; 	Return

;-----------------------------------------------------
;	Workaround for Razer Blade with Fn mode stuck ON  
;-----------------------------------------------------

<#Left::
	Send, {Home}
	Return
<#Right::
	Send, {End}
	Return			 
<#Up::
	Send, {PgUp}
	Return			
<#Down::
	Send, {PgDn}
	Return
;---- + Shift 
+<#Left::
	Send, +{Home}
	Return
+<#Right::
	Send, +{End}
	Return			 
+<#Up::
	Send, +{PgUp}
	Return			
+<#Down::
	Send, +{PgDn}
	Return

LWin::
	Return

;-----------------------------------------------------
;	Delete line and Silence on Supercollider IDE
;-----------------------------------------------------
#IfWinActive ahk_exe scide.exe
	`::
		Send, {~}
		Return
#IfWinActive
;-----------------------------------------------------
;	Always on Top
;-----------------------------------------------------
^Home::
	Winset, Alwaysontop, Toggle, A
	Return