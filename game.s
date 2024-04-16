; Variables

; Init variables here

;;; Important Registers

; PPU

PPU_CTRL    =   $2000
PPU_MASK    =   $2001
PPU_STATUS  =   $2002
OAM_ADDR    =   $2003
OAM_DATA    =   $2004
PPU_SCROLL  =   $2005
PPU_ADDR    =   $2006
PPU_DATA    =   $2007
OAM_DMA     =   $4014

; APU

SQ1_VOL     =   $4000
SQ1_LO      =   $4002
SQ1_HI      =   $4003
APU_STATUS  =   $4015

; CONTROLLER INPUT

JOY1        =   $4016


.segment "HEADER"
	.byte 	"NES", $1A
	.byte 	2
	.byte	1
	.byte 	$01, $00

.segment "STARTUP"


.segment "CODE"

reset:
	sei			; disable IRQs
	cld			; disable decimal mode
;	ldx #$40
;	stx $4017	; disable APU frame IRQ
	ldx #$FF
	txs			; set up stack
	inx			; now X = 0
	lda PPU_STATUS
	ldx #%00000000
	stx	PPU_CTRL	; disable NMI
	ldx #%00000000
	stx PPU_MASK	; disable rendering
;	stx $4010	; disable DMC IRQs

	lda PPU_STATUS	; PPU warm up

vblankwait1:	; First wait for vblank to make sure PPU is ready
	bit PPU_STATUS	; PPU status register
	bpl vblankwait1

vblankwait2:
	bit PPU_STATUS
	bpl vblankwait2

	lda #$00
	ldx #$00
clear_memory:
	sta $0000, X
	sta $0100, X
	sta $0200, X
	sta $0300, X
	sta $0400, X
	sta $0500, X
	sta $0600, X
	sta $0700, X
	inx
	cpx #$00
	bne clear_memory


; Loading nametable
	lda PPU_STATUS 	; reading PPUSTATUS
	lda #$20	; writing 0x2000 in PPUADDR to write on PPU, the address for nametable 0
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	lda #<background_nametable	; saving nametable in RAM
	sta $0000
	lda #>background_nametable
	sta $0001
	ldx #$00
	ldy #$00

nametable_loop:
	lda ($00), Y
	sta PPU_DATA
	iny
	cpy #$00
	bne nametable_loop
	inc $0001
	inx
	cpx #$04	; size of nametable 0: 0x0400
	bne nametable_loop

	; Color setup for background
	lda PPU_STATUS
	lda #$3F	; writing 0x3F00, pallete RAM indexes
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	ldx #$00

background_color_loop:
	lda background_pallete, X
	sta PPU_DATA
	inx
	cpx #$10	; size of pallete RAM: 0x0020, until 0x3F10 is background palletes
	bne background_color_loop	; after 0x3F10, there should be sprite palletes

; Sprites color setup
	lda PPU_STATUS
	lda #$3F
	sta PPU_ADDR
	lda #$10
	sta PPU_ADDR
	ldx #$00
sprite_color_loop:
	lda background_pallete, X
	sta PPU_DATA
	inx
	cpx #$10
	bne sprite_color_loop

; Code for reseting scroll
	lda #$00
	sta PPU_SCROLL
	lda #$00
	sta PPU_SCROLL

; Turning on NMI and rendering
	lda #%10010000
	sta PPU_CTRL	; PPUCTRL
	lda #%00011010	; show background
	sta PPU_MASK	; PPUMASK, controls rendering of sprites and backgrounds



forever:
	
; Reading input data

	lda #$01
	sta JOY1
	lda #$00
	sta JOY1

; A
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne A_not_pressed

A_not_pressed:

; B
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne B_not_pressed

B_not_pressed:

; Select
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne Select_not_pressed

Select_not_pressed:

; Start
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne Start_not_pressed

Start_not_pressed:

; Up
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne Up_not_pressed


Up_not_pressed:

; Down
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne Down_not_pressed


Down_not_pressed:

; Left
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne Left_not_pressed

Left_not_pressed:

; Right
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne Right_not_pressed

Right_not_pressed:
	jmp	forever

nmi:
nmi_logic:
nmi_sprites:
	lda #$00
	sta OAM_ADDR
	lda #$02
	sta OAM_DMA

	rti

irq:
	rti

background_nametable:
	.incbin "backgrounds/bk1.nam"

background_pallete:
	.incbin "backgrounds/bag.pal"


;.segment "RODATA"

.segment "VECTORS"
	.word nmi		; when non-maskable interrupt happens, goes to label nmi
	.word reset		; when the processor first turns on or is reset, goes to reset
	.word irq		; using external interrupt IRQ

.segment "CHARS"
	.incbin "chr/mario.chr"	; includes 8KB graphics
