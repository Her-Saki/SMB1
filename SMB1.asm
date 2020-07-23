arch nes.cpu

//Added 0x8000 bytes at the end of original PRG (2 banks)
//Original bank 2 ($4000) moved to $C000
//Original bank 2 zeroed
//Added 2 CHR banks more

//Variables
define TextPointer	$8000
define TextData		$8500
define VRAMBuffer	$0301
define Players		$077A

//=======================
//Header
//=======================
//Bank number
org $0004
db $04
//CHR number
db $02
//Mapper
org $0006
db $13

//=======================
//Jump to InitMMC1
//=======================
org $0011
JSR InitMMC1

//=======================
//Switch to bank 2
//=======================
org $082B
JMP BankswitchTextOffset

//=======================
//Initialize MMC1
//=======================
org $0D64	; base $8D54
InitMMC1:
CLD
LDA #$0E
STA $8000
LSR
STA $8000
LSR
STA $8000
LSR
STA $8000
LSR
STA $8000
LDA #$10
RTS
//=======================
//Bankswitch text offset
//=======================
BankswitchTextOffset:
LDA #$01
STA $E000
LSR
STA $E000
LSR
STA $E000
LSR
STA $E000
LSR
STA $E000
table NewTable.tbl
db $25, $AF, $01, $CF	//Diacritic
db $25, $C2, $0F
db "Tu viaje acabo,"
db $00
db $25, $D2, $0B
db "pero puedes"
db $00
db $26, $02, $19
db "jugar de nuevo pulsando B"
db $00
db $26, $42, $1C
db "para seleccionar otro mundo."
db $00
cleartable

//==================================================
//Copyright notice (not enough VROM space to fit it)
//==================================================
org $11FB5
fill $0E, $24
//=============================================
//"1 jugador"
//=============================================
org $11FC6
db $01, $24, $19, $22, $16, $11, $14, $1D, $1F, $24, $24, $24, $24
//=============================================
//"2 jugadores"
//=============================================
org $11FD6
db $02, $24, $19, $22, $16, $11, $14, $1D, $1F, $15, $20, $24, $24
//=============================================
//"Top"
//=============================================
org $11FE6
db $10, $1D, $1E
//=============================================
//"Luigi"
//=============================================
org $07FD
db $0E, $22, $18, $16, $18

//=============================================
//Castle text pointers
//=============================================
//Low bytes
org $0076
db $52, $77, $9C, $82, $99, $A8, $C5
//High byte
org $0089
db $87, $87, $87, $8D, $8D, $8D, $8D

//=============================================
//Castle text
//=============================================
org $0762
table NewTable.tbl
db $25, $44, $18
db "#Gracias por rescatarme,"
db $25, $8C, $06
db "Mario!"
db $00
db $25, $44, $18
db "#Gracias por rescatarme,"
db $25, $8C, $06
db "Luigi!"
db $00
db $25, $C1, $1E
db "Sin embargo, #nuestra princesa"
db $26, $01, $1E
db "se encuentra en otro castillo!"
db $00
cleartable

//================================
//Text data
//================================
//Text indexes (+8000)
org $4010	; base $4000
db $00, $00		//Status bar
db $28, $28		//World + lives
db $4F, $58		//Two player - One player time up
db $74, $7D		//Two player - One player game over
db $99, $99		//Warp zone

table NewTable.tbl
org $4510	; base $4500
//Status bar text
db $20, $43, $05
db "Mario"
db $20, $52, $0C
db "Mundo Tiempo"
db $20, $68, $05, $00, $24, $24, $2e, $17 			 //Score and coin
db $23, $c0, $7f, $aa								 //Attribute data
db $23, $c2, $01, $ea 							 	 //Attribute data
db $ff 												 //EOF

//World + Lives
db $21, $cd, $07, $24, $24, $17, $24, $24, $24, $24	 			//X + Lives
db $21, $4b, $09
db "Mundo  - "
db $21, $EA, $45, $24											//Clearing first line
db $22, $06, $54, $24											//Clearing second line				 	 
db $22, $4D, $46, $24											//Clearing third line
db $23, $dc, $01, $ba 							 	 			//Attribute data
db $ff															//EOF

//Two players time up
db $22, $4D, $06
db "Mario!"
//One player time up
db $21, $EE, $01, $CF								 	  //Diacritic
db $22, $06, $14
db "#Se acabo el tiempo!"
db $FF													  //EOF

//Two players game over
db $22, $4D, $06
db "Mario!"
//One player game over
db $21, $EA, $01, $CF								 	  //Diacritic
db $22, $06, $14
db "#Bntentalo de nuevo!"
db $FF													  //EOF

//Warp zone
db $25, $83, $18
db "#Bienvenido a la zona de"
db $25, $CB, $07
db "atajos!"
db $26, $25, $01, $24         							  //Left pipe
db $26, $2d, $01, $24         							  //Middle pipe
db $26, $35, $01, $24         							  //Right pipe
db $27, $D8, $07, $19, $aa, $aa, $aa, $aa, $aa, $aa       //Attribute data
db $27, $e1, $45, $aa									  //Attribute data
db $ff													  //EOF
cleartable

//================================
//Warp zone placeholder fix
//================================
org $089C
STA $0329,y

//================================
//Bankswitch text offset continuation
//================================
BankswitchTextOffset2:
org $4D92 ; base $8D82

//Text loop
LDX {TextPointer},y
LDY #$00
Loop:
LDA {TextData},x
CMP #$FF
BEQ Exit
STA {VRAMBuffer},y
INX
INY
BNE Loop
Exit:

//Switch to CHR 02 if
//in game over screen
PLA
CMP #$03
BNE SkipCHRSwitch
LDA #$02
STA $A000
LSR
STA $A000
LSR
STA $A000
LSR
STA $A000
LSR
STA $A000
LDA #$03
PHA
JMP CheckComma

SkipCHRSwitch:
PHA
LDA #$01
STA $A000
LSR
STA $A000
LSR
STA $A000
LSR
STA $A000
LSR
STA $A000

//Print comma if 2 players
//AND $0324 is a "!"
CheckComma:
LDA {Players}
BEQ RestoreBank
LDA $0324
CMP #$2B
BNE RestoreBank
LDA #$CF
STA $0324

RestoreBank:
LDA #$00
STA $E000
LSR
STA $E000
LSR
STA $E000
LSR
STA $E000
LSR
JMP RestoreBank1

//================================
//NOP original routine
//================================
org $082E
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP

//================================
//Restore bank from permanent bank
//================================
org $F2DA ; base $F2CA
RestoreBank1:
STA $E000
JMP $882E