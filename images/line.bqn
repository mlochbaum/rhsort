#! /usr/bin/env bqn

Enc‿Attr‿At‿Elt‿Num‿Pos‿SVG‿Ge‿Rdim‿Rect‿Text‿Path ← •Import "util.bqn"

input ← •wdpath⊸•file.At¨ •args
n ← ≠input

Read ← {
  ToNats ← ((>⟜«0⊸≤) / 0(0⊸≤××⟜10⊸+)`⊢) · 10⊸≤⊸(¬⊸×-⊣) -⟜'0'
  tab ← ∘‿3 ⥊ ToNats '.'⊸≠⊸/ •file.Chars 𝕩
  0‿2⊸⊏˘ ÷⟜1e3⌾(1↓⍉) 4 ↓ tab
}

fname ← ((»∨`)∘=⟜'_'⊸/ ·∧`∘≠⟜'.'⊸/ •file.Name)¨ •args

dat ← ⍉∘Read¨ input
! 1=+´∊⊏¨dat

namelist  ← "quad"‿"pdq" ‿"flux"‿"wolf"‿"ska_"‿"rh"
colorlist ← "#6ad"‿"#c7d"‿"#b9e"‿"#cc6"‿"#da4"‿"#24851d"
rhf ← (1-˜≠namelist) = ni ← namelist ⊐fname
col ← "stroke"⊸⋈¨ colors ← ni⊏colorlist
names ← rhf ⊣◶⟨⊢∾"sort"˙,"Robin Hood"⟩¨ fname

width ← 512
off ← 50‿40 ⋄ end ← 20‿36
padi  ← 0‿20

gr ← "stroke-width=1.2|font-size=14px|text-anchor=middle"
TT ← < (Text("font-size"⋈Num∘⊑∾"px"˙)∾·Pos(width÷2)⋈1⊑⊢)⊸Enc

win ← -˜`¨ bounds ← (⌊´≍⌈´)¨ pts ← <∘∾˘ xy ← ⍉> <˘¨ ⋆⁼dat
dim ← width (⊣⋈×) 0.55
out ← (-off)≍dim+off+end
Scale ← padi+(dim-2×padi)× ({¬𝕏}⌾(1⊸⊑) {𝕩÷˜𝕨-˜⊢}´¨ win) {𝕎𝕩}¨ ⊢
line ← (/≠¨⊏xy) ⊔ Num ⍉> Scale pts

ls ← 18
lh ← ls×1+↕n
lw ← 134
ld ← ⟨lw,ls×1+n⟩
rhs ← (At"font-weight=bold|stroke-width=0.6|stroke=#211")∾"fill"⋈¯1⊑colorlist
ltr ← "transform=translate("∾")"∾˜∾⟜","⊸∾´Num dim-10+ld
legend ← (ltr∾"|text-anchor=start|font-size=13px") Ge ⟨
  "fill=white|stroke=#111" Rect 0‿0≍ld
  "stroke-width=2.6" Ge col ≍⊸Path⟜(∾"M h"∾¨Num)¨ (8∾∾⟜22)¨ lh
  (rhs⊸∾¨⌾(rhf⊸/)36 Pos∘⋈¨lh) ("text"Attr"dy"‿"0.33em"⊸∾)⊸Enc¨ names
⟩

tpos ← Scale ⋆⁼ ticks ← ⟨10⋆2+↕6, 5∾10×1+↕9⟩
DT ← {
  P ← ('h'=𝕨)◶⟨∾⟜(0‿1×dim),¯1⌽∾⟜(1‿0×dim)⟩
  ("path"Elt"d"⋈·∾("M "∾𝕨)∾¨Num∘P)¨ 𝕩
}

•Out¨ (⥊out) SVG gr Ge ∾⥊¨ ⟨
  <"fill=white" Rect out
  ⟨18,¯19⟩ TT "Sorting random 4-byte integers"
  "text"⊸Attr⊸Enc˜´¨ ⟨
    ⟨"Size", "dy"‿"1em"∾Pos 0‿16+dim×0.5‿1⟩
    ⟨"Time (ns / value)", "transform"‿"rotate(-90)"∾"dy"‿"-0.35em"∾Pos 0‿22-˜⌽dim×0‿¯0.5⟩
  ⟩
  "stroke-width=0.3|stroke=#555" Ge "vh" DT¨ (¯1↓1↓⊢)⌾⊑ tpos
  "font-size=11px" Ge ⟨
    tpos ("text"Attr·Pos⋈⟜((1⊑dim)+13))⊸Enc¨⟜(1e3⊸<◶Num‿("1e"∾'0'+·⌊0.5+10⋆⁼⊢)¨)○⊑ ticks
    "text-anchor=end" Ge tpos (Text·Pos ¯6⊸⋈)⊸Enc¨⟜Num○(¯1↓1⊸⊑) ticks
  ⟩
  "stroke-width=2.6|fill=none" Ge col ≍⊸Path⟜('M'⌾⊑∘∾·⥊ "L "∾¨⎉1⊢)¨ line
  <"stroke=#111|fill=none" Rect 0‿0≍dim
  legend
⟩
