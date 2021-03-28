unit Images.Paw;

// Images converted with the help of
// https://lvgl.io/tools/imageconverter

{$mode ObjFPC}{$H+}
{$WRITEABLECONST OFF}

interface

uses
  CustomDisplay;

const
  paw32x32x1_ImageData : array[1..32*4] of byte = (
    $00, $00, $00, $00,
    $00, $01, $80, $00,
    $00, $01, $80, $00,
    $00, $c0, $c0, $00,
    $01, $c3, $e0, $00,
    $00, $d3, $f0, $00,
    $00, $f3, $f8, $00,
    $00, $f9, $fc, $18,
    $01, $f9, $fc, $18,
    $01, $f9, $fc, $38,
    $01, $fd, $fc, $7c,
    $01, $fe, $f8, $7c,
    $00, $fe, $60, $fe,
    $00, $fc, $00, $fe,
    $e0, $30, $01, $fe,
    $ec, $00, $01, $fe,
    $7e, $00, $00, $fc,
    $3f, $80, $fc, $78,
    $3f, $c3, $fe, $00,
    $3f, $e7, $ff, $00,
    $1f, $e7, $ff, $80,
    $1f, $c7, $ff, $f0,
    $0f, $87, $ff, $f0,
    $02, $07, $ff, $f8,
    $00, $0f, $ff, $f8,
    $00, $1f, $ff, $f0,
    $00, $3f, $ff, $f0,
    $00, $1f, $ff, $c0,
    $00, $1f, $ff, $00,
    $00, $0f, $fc, $00,
    $00, $03, $80, $00,
    $00, $00, $00, $00
  );
  paw64x64x1_ImageData : array [1..64*8] of byte = (
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $01, $80, $00, $00, $00,
    $00, $00, $00, $00, $c0, $00, $00, $00,
    $00, $00, $00, $00, $e0, $00, $00, $00,
    $00, $00, $00, $00, $70, $00, $00, $00,
    $00, $00, $c0, $00, $70, $00, $00, $00,
    $00, $00, $c0, $03, $f8, $00, $00, $00,
    $00, $00, $c0, $07, $fe, $00, $00, $00,
    $00, $00, $c0, $07, $ff, $00, $00, $00,
    $00, $00, $fe, $07, $ff, $80, $00, $00,
    $00, $00, $ff, $03, $ff, $c0, $00, $00,
    $00, $00, $ff, $03, $ff, $c0, $00, $00,
    $00, $00, $ff, $81, $ff, $e0, $01, $00,
    $00, $01, $ff, $81, $ff, $e0, $01, $80,
    $00, $01, $ff, $81, $ff, $e0, $01, $80,
    $00, $01, $ff, $c1, $ff, $e0, $01, $c0,
    $00, $03, $ff, $c1, $ff, $e0, $07, $c0,
    $00, $03, $ff, $e1, $ff, $c0, $0f, $c0,
    $00, $03, $ff, $f1, $ff, $c0, $1f, $e0,
    $00, $01, $ff, $f0, $ff, $80, $1f, $e0,
    $00, $01, $ff, $f0, $7e, $00, $3f, $f0,
    $00, $00, $ff, $f0, $00, $00, $3f, $f0,
    $00, $00, $ff, $e0, $00, $00, $7f, $f8,
    $00, $00, $7f, $c0, $00, $00, $7f, $f8,
    $00, $00, $1f, $80, $00, $00, $ff, $f8,
    $00, $00, $00, $00, $00, $00, $ff, $f8,
    $00, $00, $00, $00, $00, $00, $ff, $f8,
    $18, $00, $00, $00, $00, $01, $ff, $f0,
    $18, $c0, $00, $00, $00, $01, $ff, $f0,
    $1d, $f0, $00, $00, $00, $00, $ff, $e0,
    $0f, $f8, $00, $00, $00, $00, $ff, $c0,
    $0f, $fe, $00, $00, $0f, $80, $3f, $80,
    $0f, $ff, $00, $00, $7f, $e0, $04, $00,
    $07, $ff, $c0, $03, $ff, $f0, $00, $00,
    $07, $ff, $e0, $07, $ff, $f8, $00, $00,
    $07, $ff, $f0, $0f, $ff, $fc, $00, $00,
    $07, $ff, $f8, $1f, $ff, $fc, $00, $00,
    $03, $ff, $f8, $1f, $ff, $fe, $00, $00,
    $03, $ff, $f0, $3f, $ff, $ff, $80, $00,
    $01, $ff, $f0, $3f, $ff, $ff, $fc, $00,
    $00, $ff, $e0, $3f, $ff, $ff, $fe, $00,
    $00, $7f, $c0, $3f, $ff, $ff, $ff, $00,
    $00, $1f, $80, $3f, $ff, $ff, $ff, $00,
    $00, $00, $00, $3f, $ff, $ff, $ff, $00,
    $00, $00, $00, $7f, $ff, $ff, $ff, $00,
    $00, $00, $00, $7f, $ff, $ff, $ff, $00,
    $00, $00, $00, $ff, $ff, $ff, $ff, $00,
    $00, $00, $01, $ff, $ff, $ff, $ff, $00,
    $00, $00, $03, $ff, $ff, $ff, $fe, $00,
    $00, $00, $07, $ff, $ff, $ff, $fe, $00,
    $00, $00, $03, $ff, $ff, $ff, $fc, $00,
    $00, $00, $03, $ff, $ff, $ff, $f0, $00,
    $00, $00, $03, $ff, $ff, $ff, $c0, $00,
    $00, $00, $01, $ff, $ff, $ff, $00, $00,
    $00, $00, $00, $ff, $ff, $f8, $00, $00,
    $00, $00, $00, $7f, $ff, $c0, $00, $00,
    $00, $00, $00, $3f, $f8, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00
  );

  paw64x64x4_IndexData : array [1..4*16] of byte = (
    $96, $63, $4c, $ff, 	//Color of index 0*/
    $ff, $ff, $ff, $ff, 	//Color of index 1*/
    $e5, $d2, $cd, $ff, 	//Color of index 2*/
    $cb, $ad, $a2, $ff, 	//Color of index 3*/
    $ae, $84, $73, $ff, 	//Color of index 4*/
    $ba, $95, $86, $ff, 	//Color of index 5*/
    $8a, $52, $38, $ff, 	//Color of index 6*/
    $96, $64, $4d, $ff, 	//Color of index 7*/
    $97, $64, $4e, $ff, 	//Color of index 8*/
    $98, $66, $4f, $ff, 	//Color of index 9*/
    $9d, $6c, $57, $ff, 	//Color of index 10*/
    $a4, $76, $62, $ff, 	//Color of index 11*/
    $7b, $3e, $21, $ff, 	//Color of index 12*/
    $83, $49, $2d, $ff, 	//Color of index 13*/
    $90, $5b, $42, $ff, 	//Color of index 14*/
    $ff, $ff, $ff, $ff 	//Color of index 15*/
  );

  paw64x64x4_ImageData : array [1..64*32] of byte = (
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $1f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $11, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $12, $31, $1f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $a3, $11, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $ff, $ff, $ff, $ff, $ff, $ff, $f1, $2c, $21, $1f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f1, $11, $1f, $ff, $ff, $ff, $ff, $ff, $f1, $1b, $c1, $1f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f1, $22, $1f, $ff, $ff, $ff, $ff, $f1, $11, $14, $c4, $11, $1f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f1, $54, $11, $ff, $ff, $ff, $ff, $11, $24, $0e, $8d, $41, $11, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f1, $54, $11, $11, $1f, $ff, $ff, $12, $6c, $e0, $90, $d0, $21, $1f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f1, $56, $11, $11, $11, $ff, $ff, $13, $c9, $00, $00, $9d, $d2, $11, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f1, $3c, $52, $5b, $31, $1f, $ff, $12, $ee, $00, $00, $09, $6d, $21, $1f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f1, $3d, $6d, $dd, $c3, $11, $ff, $11, $5d, $80, $00, $00, $96, $62, $1f, $ff, $ff, $ff, $ff, $ff, $f1, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $3d, $00, $07, $6b, $11, $ff, $f1, $26, $00, $00, $00, $09, $c4, $11, $ff, $ff, $ff, $ff, $ff, $11, $1f, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $b6, $00, $00, $e0, $21, $ff, $f1, $15, $d0, $00, $00, $00, $e6, $21, $ff, $ff, $ff, $ff, $f1, $12, $11, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $12, $d0, $00, $00, $06, $21, $ff, $f1, $15, $d0, $00, $00, $00, $7d, $31, $ff, $ff, $ff, $ff, $f1, $14, $21, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $f1, $15, $d7, $00, $00, $0d, $31, $1f, $f1, $15, $d0, $00, $00, $00, $0d, $51, $1f, $ff, $ff, $ff, $f1, $14, $a1, $1f, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $f1, $1b, $60, $00, $00, $0e, $e2, $11, $f1, $14, $d0, $00, $00, $00, $7d, $51, $1f, $ff, $ff, $ff, $11, $13, $c2, $1f, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $f1, $20, $e0, $00, $00, $09, $db, $11, $f1, $14, $d0, $00, $00, $00, $8c, $31, $ff, $ff, $ff, $f1, $12, $24, $c3, $11, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $f1, $20, $e0, $00, $00, $00, $8c, $51, $11, $15, $d7, $00, $00, $09, $da, $11, $ff, $ff, $ff, $11, $4d, $d6, $64, $11, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $f1, $28, $e0, $00, $00, $00, $7e, $d2, $11, $13, $c0, $70, $07, $9d, $e2, $11, $ff, $ff, $f1, $13, $ce, $00, $06, $21, $1f, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $f1, $1b, $60, $00, $00, $00, $08, $d4, $11, $11, $4c, $d6, $6d, $ca, $21, $1f, $ff, $ff, $f1, $19, $67, $00, $8d, $b1, $1f, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $f1, $13, $c9, $00, $00, $00, $00, $6b, $11, $f1, $13, $4b, $b4, $31, $11, $ff, $ff, $ff, $f1, $2d, $00, $00, $07, $c3, $1f, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $e6, $90, $00, $00, $09, $c5, $11, $f1, $11, $11, $11, $11, $1f, $ff, $ff, $ff, $11, $4d, $70, $00, $07, $d4, $11, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $2d, $d7, $70, $08, $0c, $81, $1f, $ff, $f1, $11, $11, $1f, $ff, $ff, $ff, $ff, $12, $60, $00, $00, $00, $e0, $21, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f1, $12, $ad, $dd, $dd, $64, $11, $1f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f1, $15, $d8, $00, $00, $00, $06, $21, $1f,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $12, $54, $53, $21, $11, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f1, $2e, $e0, $00, $00, $00, $06, $21, $1f,
    $ff, $f1, $1f, $ff, $ff, $ff, $ff, $ff, $f1, $11, $11, $11, $11, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $5d, $80, $00, $00, $00, $06, $21, $1f,
    $f1, $11, $11, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $1f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $a6, $00, $00, $00, $00, $06, $21, $1f,
    $f1, $12, $21, $11, $11, $1f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $12, $60, $00, $00, $00, $00, $6a, $11, $ff,
    $f1, $13, $b1, $11, $22, $11, $1f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $12, $d0, $00, $00, $00, $08, $c5, $11, $ff,
    $ff, $12, $e2, $1a, $d6, $b2, $11, $1f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $bc, $07, $00, $08, $0c, $a1, $1f, $ff,
    $ff, $11, $ae, $9d, $00, $dd, $31, $11, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $11, $11, $11, $1f, $ff, $11, $1b, $cd, $6e, $6d, $c4, $11, $1f, $ff,
    $ff, $11, $5c, $e9, $00, $9e, $ca, $21, $11, $ff, $ff, $ff, $ff, $ff, $ff, $f1, $11, $11, $12, $22, $21, $11, $ff, $f1, $11, $24, $a8, $a4, $21, $11, $ff, $ff,
    $ff, $f1, $26, $00, $00, $07, $8d, $d3, $11, $1f, $ff, $ff, $ff, $ff, $f1, $11, $12, $54, $96, $66, $eb, $31, $1f, $ff, $f1, $11, $11, $11, $11, $ff, $ff, $ff,
    $ff, $f1, $1b, $60, $00, $00, $09, $ec, $92, $11, $ff, $ff, $ff, $f1, $11, $24, $9d, $d6, $e0, $00, $0d, $c5, $11, $ff, $ff, $f1, $11, $11, $ff, $ff, $ff, $ff,
    $ff, $f1, $15, $d0, $00, $00, $00, $79, $6d, $51, $1f, $ff, $ff, $f1, $15, $dd, $e0, $70, $00, $00, $08, $0c, $51, $1f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $13, $d7, $00, $00, $00, $00, $8e, $c5, $11, $ff, $ff, $11, $bc, $08, $00, $00, $00, $00, $00, $70, $c3, $11, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $12, $6e, $00, $00, $00, $00, $07, $e6, $21, $ff, $f1, $13, $c0, $70, $00, $00, $00, $00, $00, $08, $68, $11, $1f, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $11, $4d, $90, $00, $00, $00, $00, $06, $21, $ff, $f1, $19, $67, $00, $00, $00, $00, $00, $00, $00, $9d, $b1, $11, $11, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $f1, $26, $68, $00, $00, $00, $07, $69, $11, $ff, $f1, $26, $00, $00, $00, $00, $00, $00, $00, $00, $08, $d0, $31, $11, $11, $1f, $ff, $ff, $ff, $ff,
    $ff, $ff, $f1, $13, $ce, $80, $00, $00, $70, $c3, $11, $ff, $f1, $26, $00, $00, $00, $00, $00, $00, $00, $00, $00, $96, $d9, $45, $32, $11, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $11, $3c, $60, $70, $77, $ec, $51, $1f, $ff, $f1, $2e, $e0, $00, $00, $00, $00, $00, $00, $00, $00, $07, $7e, $dd, $d6, $31, $1f, $ff, $ff, $ff,
    $ff, $ff, $ff, $f1, $12, $8d, $dd, $dd, $e3, $11, $ff, $ff, $f1, $27, $e0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $76, $d2, $1f, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $11, $13, $55, $53, $11, $1f, $ff, $ff, $f1, $2e, $e0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $08, $c5, $11, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $f1, $11, $11, $11, $11, $ff, $ff, $ff, $11, $3d, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $64, $11, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $11, $1f, $ff, $ff, $ff, $f1, $11, $0e, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ea, $11, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $1b, $d9, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ea, $11, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f1, $11, $bd, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $6b, $11, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f1, $1a, $d8, $70, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $c3, $11, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $4c, $90, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $9d, $01, $1f, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $12, $ee, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $78, $d6, $21, $1f, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $a6, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $70, $6c, $a2, $11, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $5c, $90, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $dd, $a3, $11, $1f, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f1, $26, $e7, $00, $00, $00, $00, $00, $00, $00, $00, $07, $06, $d6, $42, $11, $11, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f1, $13, $c0, $70, $00, $00, $00, $00, $00, $07, $0e, $dd, $6b, $32, $11, $11, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $5c, $68, $70, $00, $00, $00, $e6, $dd, $d7, $43, $21, $11, $1f, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f1, $13, $ed, $d6, $66, $dd, $dd, $ea, $43, $21, $11, $11, $1f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $13, $54, $44, $45, $32, $21, $11, $11, $11, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f1, $11, $11, $11, $11, $11, $11, $11, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $11, $11, $11, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
  );

const
  paw32x32x1 : TImageInfo =
  (
    Width : 32;
    Height : 32;
    BitsPerPixel : 1;
    BytesPerLine : 4;
    TransparencyIndex : -1;
    pIndexData : nil;
    pImageData : @paw32x32x1_ImageData;
  );
  paw64x64x1 : TImageInfo =
  (
    Width : 64;
    Height : 64;
    BitsPerPixel : 1;
    BytesPerLine : 8;
    TransparencyIndex : -1;
    pIndexData : nil;
    pImageData : @paw64x64x1_ImageData;
  );

  paw64x64x4 : TImageInfo =
  (
    Width : 64;
    Height : 64;
    BitsPerPixel : 4;
    BytesPerLine : 32;
    TransparencyIndex : 15;
    pIndexData : @paw64x64x4_IndexData;
    pImageData : @paw64x64x4_ImageData;
  );

implementation

end.

