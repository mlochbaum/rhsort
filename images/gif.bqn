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
w‿n‿h‿p ← 260‿90‿60‿10 ⋄ e←3 ⋄ outl←5
hh ← p+2×h
bar ← 3 + n (•MakeRand 0).Range h-2
ind0 ← (⊢↑˝·-⌾⊏(2‿1×outl)+⌜≢) (⋈˜<e) / ⟨hh,w⟩↑((⌽↕h)<⌜bar)
bp ← ⌊ (w-8) × ÷⟜(⌈´) -⟜(⌊´) bar
# Insert to buffer
buf ← w⥊∞
Mv ← {𝕊f‿t‿b: s←e×b‿1
  i←{t+↩b≥k←𝕩⊑buf⋄𝕊⍟(∞≠k)1+𝕩}t
  v←@ ⋄ buf ({v↩𝕩}b⊸»)⌾((t↓↕i)⊸⊏)↩
  m←⊢´v
  ⟨2, f⋈˜h-b, s⥊2⟩‿⟨8, t⋈˜hh-m, (⋈˜<e) / 3×(⌽↕m)<⌜v⟩
}
updates ← ∾ <∘Mv˘ ⍉>(↕≠bar)‿bp‿bar
# Filter buffer
Fl ← {d𝕊f‿t‿b: s←e×b‿1
  ⟨2, f⋈˜hh-b, s⥊4⟩‿⟨d, t⋈˜0, (-e×h)↑s⥊3⟩
}
bi ← /∞≠buf
updates ∾↩ ⥊ (2×(20+≠buf)(«-⊢)bi) Fl˘ ⍉>⟨bi,↕≠bar,∧bar⟩
updates (outl+e⊸×)⌾(1⊸⊑)¨↩

col ← >⟨0‿0‿0,16‿3‿230,8‿7‿58,45‿166‿36,12‿48‿10⟩
"robinhood.gif" •file.Bytes col EncodeGIF ⟨30,0‿0,ind0⟩ <⊸∾ updates
