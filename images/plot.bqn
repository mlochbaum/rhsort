#! /usr/bin/env bqn

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

# SVG utilities
Enc ← {
  DeNest ← {(3⌊≡)◶⟨!∘0,⋈,⊢,∾𝕊¨⟩ ⥊𝕩}
  open ← ∾⟨"<",𝕨,">"⟩
  close← ∾⟨"</", (∧`𝕨≠' ')/𝕨, ">"⟩
  l ← 1 < d←≡𝕩
  ∾ open ({"  "⊸∾¨(∾DeNest¨)⍟(3≤d)⥊𝕩}⍟l 𝕩){𝕨‿𝕗‿𝕩}○(⥊∘<⍟l) close
}
At1 ← " " ∾ {∾⟨𝕨,"='",𝕩,"'"⟩}´
Attr ← ∾⟜(∾ <∘At1⎉1)
At ← {
  _s ← {((+`×¬)⊸-𝕗⊸=)⊸⊔}
  𝕨 >⊘(∾⟜(∾At1¨)) '='_s¨ '|'_s 𝕩
}
Elt ← {∾⟨"<",𝕩,"/>"⟩}Attr
FmtNum ← (∧`4⥊⟜1⊸»'.'⊸≠)⊸/∘•Repr⚇0
Pos ← ⟨"x","y"⟩ ≍˘ FmtNum
SVG ← {
  a ← ⟨"viewBox",1↓∾' '∾¨FmtNum 𝕨⟩∾"height"‿"width"≍˘FmtNum 1.5×⌽2↓𝕨
  a ∾↩ "xmlns"‿"http://www.w3.org/2000/svg"
  ("svg" Attr a) Enc 𝕩
}

# Create the plot
max ← ⌈´ avg •BQN¨↩
ticks ← (↕1+⌊)⌾(÷⟜10) maxns ← 1e4×max

Ge ← "g"⊸At⊸Enc

nn‿nd ← ≠¨names‿dists
bt←bs←7 ⋄ gs←12+nn×bs
w ← 14 +      (w0←100) + tw ← 6 + pw←400-6
h ← 68 + h1 ← (h0← 56) + ph ← nd×gs
wh ← w‿h
tpos ← w0+pw×ticks÷maxns

colors ← "#6ad"‿"#c7d"‿"#b9e"‿"#cc6"‿"#da4"‿"#24851d"

Rdim ← Pos∘⊏∾"width"‿"height"≍˘·FmtNum⊢˝
Rect ← "rect" Elt Rdim⊘(At⊸∾⟜Rdim)
Text ← "text"Attr"dy"‿"0.33em"⊸∾
TT ← < (Text("font-size"⋈FmtNum∘⊑∾"px"˙)∾·Pos(w0+pw÷2)⋈1⊑⊢)⊸Enc

gh ← h0+gs×0.5+↕nd
bh ← gh +⌜ bs × (↕-2÷˜-⟜1)nn
bars ← bh Rect∘{⟨w0,𝕨-bt÷2⟩≍𝕩‿bt}¨ nd‿nn⥊pw×avg÷max

ls ← 11+bs
lh ← ls×1+↕nn
lw ← 150
rhs ← (At"font-weight=bold|stroke-width=0.6|stroke=#211")∾"fill"⋈¯1⊑colors
ltr ← "transform=translate("∾")"∾˜∾⟜","⊸∾´FmtNum ⟨w0+tw-10+lw,h0+300⟩
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
  "stroke-width=0.3|stroke=#555" Ge ("path"Elt"d"⋈·∾"M v"∾¨·FmtNum∾⟜h0‿ph)¨ 1↓tpos
  "font-size=11px" Ge tpos ("text"Attr·Pos⋈⟜(h1+13))⊸Enc¨ FmtNum ticks
  "text-anchor=end" Ge ((w0-5)Pos∘⋈¨gh) Text⊸Enc¨ dists
  "stroke=#111" Ge colors ("g"Attr"fill"⊸⋈)⊸Enc¨ <˘⍉bars
  <"stroke=#111|fill=none" Rect w0‿h0≍tw‿ph
  legend
⟩
