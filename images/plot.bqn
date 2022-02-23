#! /usr/bin/env bqn

util ← •Import "util.bqn"
Num‿Pos‿SVG‿Ge‿Rect‿Text‿TSize‿Background‿Outline‿Legend‿Tick ← util

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

nn‿nd ← ≠¨names‿dists
bt←bs←7 ⋄ gs←12+nn×bs
w ← 14 +      (w0←100) + tw ← 6 + pw←400-6
h ← 68 + h1 ← (h0← 56) + ph ← nd×gs
wh ← w‿h

colors ← "#6ad"‿"#c7d"‿"#b9e"‿"#cc6"‿"#da4"‿"#24851d"
_cBar ← { "stroke=#111" Ge colors "fill="⊸∾⊸𝔽¨ 𝕩 }

TT ← < TSize⊸∾⟜(Pos(w0+pw÷2)⊸⋈)´⊸Text

gh ← h0+gs×0.5+↕nd
bh ← gh +⌜ bs × (↕-2÷˜-⟜1)nn
bars ← nd‿nn⥊pw×avg÷max

•Out¨ (0‿0∾wh) SVG "text-anchor=middle|font-size=14px|fill=#111" Ge ⟨
  Background 0‿0≍wh
  ⟨20,h0-37⟩ TT "The Big Bad Wolfsort benchmark"
  ⟨15,h0-14⟩ TT "Sort 100,000 4-byte integers, average of 100"
  ⟨15,h1+31⟩ TT "Nanoseconds per element"
  ⟨11,h1+51⟩ TT "i5-6200U CPU @ 2.30GHz; compiled with g++ -O3"
  Tick {
    off⇐w0‿h0 ⋄ dim⇐pw‿ph
    orient⇐"v"
    ticks ← (↕1+⌊)⌾(÷⟜10) maxns ← 1e4×max
    tpos ⇐ ⟨w0+pw×ticks÷maxns⟩
    ttext ⇐ ⟨Num ticks⟩
  }
  "text-anchor=end" Ge ((w0-5)Pos∘⋈¨gh) Text¨ dists
  Ge _cBar <˘⍉ bh Rect∘{⟨w0,𝕨-bt÷2⟩≍𝕩‿bt}¨ bars
  Outline w0‿h0≍tw‿ph
  Legend {
    isRH ⇐ 1«nn⥊0
    label ⇐ ∾⟜"_copy"⍟("ska_sort"⊸≡)¨ "Robin Hood"¨⌾(isRH⊸/) names
    width ⇐ 150
    place ⇐ ⟨w0+tw-10+width,h0+300⟩
    pad ⇐ 2 ÷˜ spacing ⇐ 11+bs
    Samples ⇐ Rect⟜{10‿(𝕩-bt÷2)≍18‿bt} _cBar
  }
⟩
