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
Text ⇐ "text"Attr"dy"‿"0.33em"⊸∾