nmi:
nmi_logic:
nmi_sprites:
    lda #$00
    sta OAM_ADDR
    lda #$02
    sta OAM_DMA

    rti 

