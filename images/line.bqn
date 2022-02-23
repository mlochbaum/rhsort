#! /usr/bin/env bqn

util ← •Import "util.bqn"
Enc‿Attr‿At‿Elt‿Num‿Pos‿SVG‿Ge ← util
Rect‿Text‿TSize‿Path‿Background‿Outline‿Legend‿Tick ← util

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
col ← "stroke"⊸⋈¨ colors ← ni⊏colorlist∾<"black"
names ← rhf ⊣◶⟨⊢∾"sort"∾"_copy"/˜"ska_"⊸≡,"Robin Hood"⟩¨ fname

width ← 512
off ← 50‿40 ⋄ end ← 20‿46
padi  ← 0‿20

gr ← "stroke-width=1.2|font-size=14px|text-anchor=middle"
TT ← < TSize⊸∾⟜(Pos(width÷2)⊸⋈)´⊸Text

win ← -˜`¨ bounds ← (⌊´≍⌈´)¨ pts ← <∘∾˘ xy ← ⍉> <˘¨ ⋆⁼dat
dim ← width (⊣⋈×) 0.55
out ← (-off)≍dim+off+end
Scale ← padi+(dim-2×padi)× ({¬𝕏}⌾(1⊸⊑) {𝕩÷˜𝕨-˜⊢}´¨ win) {𝕎𝕩}¨ ⊢
line ← (/≠¨⊏xy) ⊔ Num ⍉> Scale pts

•Out¨ (⥊out) SVG gr Ge ∾⥊¨ ⟨
  Background out
  ⟨18,¯19⟩ TT "Sorting random 4-byte integers"
  "text"⊸Attr⊸Enc˜´¨ ⟨
    ⟨"Size", "dy"‿"1em"∾Pos 0‿16+dim×0.5‿1⟩
    ⟨"Time (ns / value)", "transform"‿"rotate(-90)"∾"dy"‿"-0.35em"∾Pos 0‿22-˜⌽dim×0‿¯0.5⟩
  ⟩
  Tick {
    off⇐0‿0 ⋄ dim⇐dim
    orient⇐"vh"
    tpos ⇐ Scale ⋆⁼ ticks ← ⟨10⋆2+↕6, 5∾10×1+↕7⟩
    ttext ⇐ ⟨1e3⊸<◶Num‿("1e"∾'0'+·⌊0.5+10⋆⁼⊢)¨, Num⟩ {𝕎𝕩}¨ ticks
  }
  "stroke-width=2.6|fill=none" Ge col ≍⊸Path⟜('M'⌾⊑∘∾·⥊ "L "∾¨⎉1⊢)¨ line
  Outline 0‿0≍dim
  Legend {
    label ⇐ names ⋄ isRH ⇐ rhf
    place ⇐ 10‿6
    width ⇐ 134 ⋄ spacing ⇐ 18 ⋄ pad ⇐ 6
    Samples ⇐ "stroke-width=2.6" Ge col ≍⊸Path⟜(∾"M h"∾¨Num)¨ (8∾∾⟜22)¨
  }
⟩
