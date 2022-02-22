#! /usr/bin/env bqn

Enc‿Attr‿At‿Elt‿Num‿Pos‿SVG‿Ge‿Rdim‿Rect‿Text ← •Import "util.bqn"

"Input filename required" ! 1≤≠•args
input ← •wdpath •file.At ⊑•args

# Parse the file
Parse ← {
  h‿d ← (⊑⋈2⊸↓) •file.Lines 𝕩
  c ← +`'|'=h
  m ← ¬∧˝"| "∊˜>d
  g ← 1-˜m×c ⊏ +˝(1+↕∘≠)⊸× "Name"‿"Distribution"‿"Average" ∨´∘⍷⌜ c ⊔ h
  <˘ ⍉ (0<·≠¨⊏˘)⊸/ (∨`' '⊸≠)⊸/¨ > g⊸⊔¨d
}
name‿dist‿avg ← Parse input
! (≠∘⊑⥊¨·⊣⌜˜`⌾⌽⍷¨)⊸≡ ⊐¨dist‿name
PD ← {
  t←-≠o←" order" ⋄ 𝕩↓˜↩t×o≡t↑𝕩
  m←⊢´⊸<(0¨e)(≠`»≠⊢)b←𝕩(≠∘⊢↑⍷)˜e←"ending"
  (-´"Aa")⊸+⌾⊑ (b≥m)/𝕩+(b∧m)×'.'-𝕩
}
names ← ⍷name
dists ← PD¨⍷dist

# Create the plot
max ← ⌈´ avg •BQN¨↩
ticks ← (↕1+⌊)⌾(÷⟜10) maxns ← 1e4×max

nn‿nd ← ≠¨names‿dists
bt←bs←7 ⋄ gs←12+nn×bs
w ← 14 +      (w0←100) + tw ← 6 + pw←400-6
h ← 68 + h1 ← (h0← 56) + ph ← nd×gs
wh ← w‿h
tpos ← w0+pw×ticks÷maxns

colors ← "#6ad"‿"#c7d"‿"#b9e"‿"#cc6"‿"#da4"‿"#24851d"

TT ← < (Text("font-size"⋈Num∘⊑∾"px"˙)∾·Pos(w0+pw÷2)⋈1⊑⊢)⊸Enc

gh ← h0+gs×0.5+↕nd
bh ← gh +⌜ bs × (↕-2÷˜-⟜1)nn
bars ← bh Rect∘{⟨w0,𝕨-bt÷2⟩≍𝕩‿bt}¨ nd‿nn⥊pw×avg÷max

ls ← 11+bs
lh ← ls×1+↕nn
lw ← 150
rhs ← (At"font-weight=bold|stroke-width=0.6|stroke=#211")∾"fill"⋈¯1⊑colors
ltr ← "transform=translate("∾")"∾˜∾⟜","⊸∾´Num ⟨w0+tw-10+lw,h0+300⟩
legend ← (ltr∾"|text-anchor=start|font-size=13px") Ge ⟨
  "fill=white|stroke=#111" Rect 0‿0≍⟨lw,ls×1+nn⟩
  "stroke=#111" Ge colors "fill"⊸⋈⊸("rect" Elt ∾⟜Rdim)⟜{10‿𝕩≍18‿bt}¨ lh-bt÷2
  (rhs⊸∾⌾(¯1⊸⊑)36 Pos∘⋈¨lh) Text⊸Enc¨ "Robin Hood"⌾(¯1⊸⊑)names
⟩

•Out¨ (0‿0∾wh) SVG "text-anchor=middle|font-size=14px|fill=#111" Ge ∾⥊¨ ⟨
  <"fill=white" Rect 0‿0≍wh
  ⟨20,h0-37⟩ TT "The Big Bad Wolfsort benchmark"
  ⟨15,h0-14⟩ TT "Sort 100,000 4-byte integers, average of 100"
  ⟨15,h1+31⟩ TT "Nanoseconds per element"
  ⟨11,h1+51⟩ TT "i5-6200U CPU @ 2.30GHz; compiled with g++ -O3"
  "stroke-width=0.3|stroke=#555" Ge ("path"Elt"d"⋈·∾"M v"∾¨·Num∾⟜h0‿ph)¨ 1↓tpos
  "font-size=11px" Ge tpos ("text"Attr·Pos⋈⟜(h1+13))⊸Enc¨ Num ticks
  "text-anchor=end" Ge ((w0-5)Pos∘⋈¨gh) Text⊸Enc¨ dists
  "stroke=#111" Ge colors ("g"Attr"fill"⊸⋈)⊸Enc¨ <˘⍉bars
  <"stroke=#111|fill=none" Rect w0‿h0≍tw‿ph
  legend
⟩
