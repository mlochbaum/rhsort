#! /usr/bin/env bqn

util ← •Import "util.bqn"
Num‿Pos‿SVG‿Ge‿Text‿TSize‿Path‿Background‿Outline‿Legend‿Tick ← util
Enc‿Elt‿At‿Rect ← util

"Input filename required" ! 1≤≠•args
input ← •wdpath •file.At ⊑•args

ToNats ← ((>⟜«0⊸≤) / 0(0⊸≤××⟜10⊸+)`⊢) · 10⊸≤⊸(¬⊸×-⊣) -⟜'0'
Parse ← {
  l ← •file.Lines 𝕩
  t ← ∾⟜" of "⊸∾´ Num ToNats ⊑l
  t ⋈ ¯1 (↓ ⋈ ⊏÷1e3˙) (¯1∾˜1+↕11) ⊏ ⍉ ∘‿14 ⥊ ToNats '.'⊸≠⊸/ ∾1↓l
}
⟨title,samples‿time⟩ ← Parse input

ylog ← 0
width ← 512
off ← 50‿40 ⋄ end ← 20‿46

gr ← "stroke-width=1.2|font-size=14px|text-anchor=middle"

Marker ← "circle" Elt "r"‿"2"∾"cx"‿"cy"≍˘Num
Clip ← <"defs" Enc ("clipPath"At"id=clip") Enc Rect
Dist ← {
  h ← 0(∾∾∾⟜(-⌽))2(24÷4+↓¬-⊸↓)𝕨
  p ← (∾○(¯1⊸↓)⟜⌽𝕨) ≍˘ 𝕩+h
  "Z" ∾˜ 'M'⌾⊑ ∾⥊ "L " ∾¨⎉1 Num p
}

Log ← ⋆⁼⌾(ylog⊑⊑‿⊢)
win ← -˜`¨ bounds ← Log 30‿800 ⋈ 0⋈⌈´time
dim ← width (⊣⋈×) 0.55
out ← (-off)≍dim+off+end
padb ← 1‿ylog × padi  ← 10‿20
Scale ← padi+(dim-padb+padi)× ({¬𝕏}⌾(1⊸⊑) {𝕩÷˜𝕨-˜⊢}´¨ win) {𝕎𝕩}¨ Log
dat ← Scale ⟨<˘⍉5⌈samples, time⟩

•Out¨ (⥊out) SVG gr Ge ⟨
  Clip 0‿0≍dim
  Background out
  <((TSize 18)∾Pos⟨width÷2,¯19⟩) Text "RH criterion, sampling "∾title
  ⟨
    "Score" Text˜ Pos 0‿26+dim×0.5‿1
    "Time (ns / value)" Text˜ "transform"‿"rotate(-90)"∾Pos 0‿32-˜⌽dim×0‿¯0.5
  ⟩
  Tick {
    off⇐0‿0 ⋄ dim⇐dim
    orient⇐"vh"
    RoundDown ← {(⊑∘⍋⟜𝕩-1˙)⊸⊑1‿2‿5×⌊⌾(10⋆⁼⊢)𝕩}
    tpos ⇐ Scale ticks ← ⟨
      ⥊(10⋆↕4)×⌜∧1.5‿7∾1+↕5
      {ylog ? ⥊1‿10×⌜∧1.5‿7∾1+↕5 ; (RoundDown 6÷˜1⊑1⊑bounds)×1+↕15}
    ⟩
    ttext ⇐ ⟨1e3⊸<◶Num‿("1e"∾'0'+·⌊0.5+10⋆⁼⊢)¨, Num⟩ {𝕎𝕩}¨ ticks
  }
  "clip-path=url(#clip)" Ge ⟨
    "fill=#24851d" Ge (Marker 5⊸⊑⊸⋈)¨´ dat
    "fill=#176e10" Ge (≍"opacity"‿"0.6")⊸Path¨ Dist¨´ dat
  ⟩
  Outline 0‿0≍dim
⟩
