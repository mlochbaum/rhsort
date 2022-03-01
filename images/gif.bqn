#! /usr/bin/env bqn

EncodeLZW ← {
  dmax ← 2⋆12
  k←𝕨 ⋄ d←↕0 ⋄ r←↕0
  Add ← {c𝕊w:
    i ← d ⊑∘⊐ wc ← (dmax×w)+c
    { i<≠d ? k+i ;
      { dmax>k+≠d ? d ∾↩ wc ; @ }
      r ∾↩ w
      c
    }
  }
  r ∾ Add´⌽𝕩
}

EncPixels ← {
  c ← 2⋆𝕨
  d ← (c+2) EncodeLZW 𝕩
  Pack ← {⥊⍉ >2|⌊∘÷⟜2⍟(↕𝕨) 𝕩}
  s ← c∾d∾c+1
  m ← 12⌊⌈2⋆⁼(c+1)+↕≠s
  2⊸×⊸+˜˝ ⍉↑‿8⥊∾ (𝕨+↕∘≠)⊸(Pack¨) (m-𝕨) ⊔ s
}
SplitBlocks ← {
  0 ∾˜ ∾ ≠⊸∾¨ (255⌊∘÷˜↕∘≠)⊸⊔ 𝕩
}

# GIF with colors 𝕨 and list of delay‿pos‿inds 𝕩
EncodeGIF ← { colors 𝕊 frames:
  size ← ⌽≢2⊑⊑frames
  cc ← 2⋆1+↕8
  cf ← 1⌈cc ⊑∘⍋ 1-˜≠colors
  "Too many colors" ! cf<≠cc
  colors ↑˜↩ cf⊑cc

  Enc2 ← ∾256(|⋈⌊∘÷˜)¨⊢
  Block ← {delay‿pos‿inds: ∾⟨
    # Graphic control extension
    33‿249, 4, 4, Enc2 delay, 255, 0
    # Image descriptor
    44
    Enc2 pos∾○⌽≢inds
    0      # No local colors
    1+cf
    SplitBlocks (1+cf) EncPixels ⥊inds
  ⟩}

  ∾⟨
    # Bit depth, background, color list
    "GIF89a"-@, Enc2 size, 128+17×cf, 0, 0, ⥊colors

    # For animation
    33‿255, 11, "NETSCAPE2.0"-@, 3, 1, 255‿255, 0

    ∾ Block¨ frames

    59 # End
  ⟩
}

# Draw the algorithm
w‿n‿h‿p ← 230‿70‿60‿10 ⋄ e←3
hh ← p+2×h
bar ← 1 + n (•MakeRand 0).Range h
ind0 ← (⋈˜<e) / ⟨-hh,w⟩↑((⌽↕h)<⌜bar)
# Insert to buffer
Mv ← {s←e×𝕩‿1 ⋄ f‿t←𝕨 ⋄ ⟨e×f⋈˜hh-𝕩, s⥊2⟩‿⟨e×t⋈˜h-𝕩, s⥊3⟩}
updates ← > ((↕∘≠⋈¨⌊∘×⟜(w÷h)) Mv¨ ⊢) bar
# Filter buffer
Fl ← {s←e×𝕩‿1 ⋄ f‿t←𝕨 ⋄ ⟨e×f⋈˜h-𝕩, s⥊4⟩‿⟨e×t⋈˜h+p, (-e×h)↑s⥊3⟩}
updates ∾↩ > ((∧⌊∘×⟜(w÷h)⋈¨⍋∘⍋) Fl¨ ∧) bar
updates ↩ ⥊ 2‿8 ∾¨⎉1 updates

col ← >⟨0‿0‿0,0‿0‿255,10‿10‿50,0‿255‿0,10‿50‿10⟩
"robinhood.gif" •file.Bytes col EncodeGIF ⟨30,0‿0,ind0⟩ <⊸∾ updates
