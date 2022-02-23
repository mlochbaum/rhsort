# SVG utilities
Enc ⇐ {
  DeNest ← {(3⌊≡)◶⟨!∘0,⋈,⊢,∾𝕊¨⟩ ⥊𝕩}
  open ← ∾⟨"<",𝕨,">"⟩
  close← ∾⟨"</", (∧`𝕨≠' ')/𝕨, ">"⟩
  l ← 1 < d←≡𝕩
  ∾ open ({"  "⊸∾¨(∾DeNest¨)⍟(3≤d)⥊𝕩}⍟l 𝕩){𝕨‿𝕗‿𝕩}○(⥊∘<⍟l) close
}
At1 ← " " ∾ {∾⟨𝕨,"='",𝕩,"'"⟩}´
Attr ⇐ ∾⟜(∾ <∘At1⎉1)
At ⇐ {
  _s ← {((+`×¬)⊸-𝕗⊸=)⊸⊔}
  𝕨 >⊘(∾⟜(∾At1¨)) '='_s¨ '|'_s 𝕩
}
Elt ⇐ {∾⟨"<",𝕩,"/>"⟩}Attr
Num ⇐ ('¯' (⊢+=×'-'⊸-) (∧`4⥊⟜1⊸»'.'⊸≠)⊸/∘•Repr)⚇0
Pos ⇐ ⟨"x","y"⟩ ≍˘ Num
SVG ⇐ {
  a ← ⟨"viewBox",1↓∾' '∾¨Num 𝕨⟩∾"height"‿"width"≍˘Num 1.5×⌽2↓𝕨
  a ∾↩ "xmlns"‿"http://www.w3.org/2000/svg"
  ("svg" Attr a) Enc 𝕩
}

Ge ⇐ "g"⊸At⊸Enc
Rdim ⇐ Pos∘⊏∾"width"‿"height"≍˘·Num⊢˝
Rect ⇐ "rect" Elt Rdim⊘(At⊸∾⟜Rdim)
Path ⇐ "path" Elt "d"⊸⋈⊘(⊣∾"d"⋈⊢)
Text ⇐ ("text"Attr"dy"‿"0.33em"⊸∾)⊸Enc
TSize ⇐ "font-size"⋈Num∾"px"˙

Background ⇐ <"fill=white" Rect ⊢
Outline ⇐ <"stroke=#111|fill=none" Rect ⊢

Legend ⇐ {
  place‿spacing‿pad‿width‿label‿isRH‿Samples ← 𝕩
  y ← pad+spacing×0.5+↕n←≠label
  dim ← ⟨width,(2×pad)+spacing×n⟩
  rhs ← At"font-weight=bold|stroke-width=0.6|stroke=#211|fill=#24851d"
  ltr ← "transform=translate("∾")"∾˜∾⟜","⊸∾´Num place
  legend ← (ltr∾"|text-anchor=start|font-size=13px") Ge ⟨
    "fill=white|stroke=#111" Rect 0‿0≍dim
    Samples y
    (rhs⊸∾¨⌾(isRH⊸/)36 Pos∘⋈¨y) Text¨ label
  ⟩
}

Tick ⇐ {
  off‿dim‿orient‿tpos‿ttext ← 𝕩
  s ← 'h'=orient
  DT ← {
    h ← 'h'=𝕨
    P ← ⌽⌾(2⊸↑)⍟h ∾⟜((¬h)⊏⍉off≍dim)
    ("path"Elt"d"⋈·∾("M "∾𝕨)∾¨Num∘P)¨ 𝕩
  }
  Filter ← ⊢ /¨˜ 1≤(s⊏dim)(-⌊⊢)-⟜(s⊏off)
  TT ← {
    0𝕊p‿t: p ("text"Attr·Pos⋈⟜((1⊑off+dim)+13))⊸Enc¨ t ;
    1𝕊p‿t: "text-anchor=end" Ge p (Pos ¯6⊸⋈)⊸Text¨ t
  }
  ⟨
    "stroke-width=0.3|stroke=#555" Ge orient DT¨ Filter tpos
    "font-size=11px" Ge s TT¨ tpos ⋈¨ ttext
  ⟩
}
