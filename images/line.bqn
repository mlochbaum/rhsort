#! /usr/bin/env bqn

util ← •Import "util.bqn"
Num‿Pos‿SVG‿Ge‿Text‿TSize‿Path‿Background‿Outline‿Legend‿Tick ← util

input ← •wdpath⊸•file.At¨ •args
n ← ≠input

Read ← {
  ToNats ← ((>⟜«0⊸≤) / 0(0⊸≤××⟜10⊸+)`⊢) · 10⊸≤⊸(¬⊸×-⊣) -⟜'0'
  pr ← "profile" ∨´∘⍷⊑ l ← •file.Lines 𝕩
  c ← { ¬pr ? 3 ; m←⌈´n←1+´¨'.'=l ⋄ l∾¨↩⥊∘/⟜(≍" 0")¨m-n ⋄ m }
  tab ← ∘‿c ⥊ ToNats '.'⊸≠⊸/ ∾l
  pr◶⟨0‿2⊸⊏, ⊏∾·+`3⊸↓⟩ ⍉ ÷⟜1e3⌾(1↓⍉) 4 ↓ tab
}

dat ← Read¨ input
x ← ⊏⊑dat
! ∧´(x≡⊏)¨1↓dat

fname ← ((»∨`)∘=⟜'_'⊸/ ·∧`∘≠⟜'.'⊸/ •file.Name)¨ •args
names‿colors‿rhf ← util.ProcName fname
col ← "stroke"⊸⋈¨ colors

width ← 512
off ← 50‿40 ⋄ end ← 20‿46

gr ← "stroke-width=1.2|font-size=14px|text-anchor=middle"
TT ← < TSize⊸∾⟜(Pos(width÷2)⊸⋈)´⊸Text

logy←∧´1=yn←1-˜≠¨dat  # Don't use log-scale y to show parts
Log ← ⋆⁼⌾(logy⊑⊑‿⊢)
win ← -˜`¨ bounds ← 0⌾(⊑1⊑⊢)⍟(¬logy) (⌊´≍⌈´)∘⥊¨ Log xy ← ⟨x, ∾1↓¨dat⟩
dim ← width (⊣⋈×) 0.55
out ← (-off)≍dim+off+end
padb ← logy × padi  ← 0‿20
Scale ← padi+(dim-padb+padi)× ({¬𝕏}⌾(1⊸⊑) {𝕩÷˜𝕨-˜⊢}´¨ win) {𝕎𝕩}¨ Log
line ← (<≍˘)⎉1○Num´ Scale xy
lstyle ← (((↓≍"stroke-width"‿"1.4")⊏˜∊⌾⌽) ∾¨ ⊏⟜col) /yn

•Out¨ (⥊out) SVG gr Ge ⟨
  Background out
  ⟨18,¯19⟩ TT "Sorting random 4-byte integers"
  ⟨
    "Size" Text˜ Pos 0‿26+dim×0.5‿1
    "Time (ns / value)" Text˜ "transform"‿"rotate(-90)"∾Pos 0‿32-˜⌽dim×0‿¯0.5
  ⟩
  Tick {
    off⇐0‿0 ⋄ dim⇐dim
    orient⇐"vh"
    tpos ⇐ Scale ticks ← ⟨10⋆2+↕6, {logy?5∾10×1+↕8;5×1+↕20}⟩
    ttext ⇐ ⟨1e3⊸<◶Num‿("1e"∾'0'+·⌊0.5+10⋆⁼⊢)¨, Num⟩ {𝕎𝕩}¨ ticks
  }
  { logy?⟨⟩;
    Area ← ∾∘⥊ ("M "∾"HV"»"L "⎉1) ∾¨ (Num dim-padb)⊸∾
    st ← "opacity"‿"0.2"⊸≍¨(yn-1)/"fill"⊸⋈¨colors
    "stroke=none" Ge st Path⟜Area¨ (¬∊/yn)/line
  }∾⟨
    "stroke-width=2.6|fill=none" Ge lstyle Path⟜('M'⌾⊑∘∾·⥊ "L "∾¨⎉1⊢)¨ line
  ⟩
  Outline 0‿0≍dim
  Legend {
    label ⇐ names ⋄ isRH ⇐ rhf
    place ⇐ 10‿6
    width ⇐ 134 ⋄ spacing ⇐ 18 ⋄ pad ⇐ 6
    Samples ⇐ "stroke-width=2.6" Ge col ≍⊸Path⟜(∾"M h"∾¨Num)¨ (8∾∾⟜22)¨
  }
⟩
