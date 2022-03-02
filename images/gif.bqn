#! /usr/bin/env bqn

# Gif utils
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
col ← >⟨ # Colors
  0‿0‿0,               # 0    Black
  16‿3‿230, 8‿7‿58,    # 1 2  Blue
  45‿166‿36, 12‿48‿10, # 3 4  Green
  137‿37‿14            # 5    Orange
⟩
w‿n‿h‿p ← 260‿90‿60‿10 ⋄ e←3 ⋄ outl←5  # Parameters
hh ← p+2×h
Dist ← ⌊ (h÷14) × ·((1.5×·•math.Sin (3.5×π)⊸×) + 15××˜) ÷⟜h
bar ← 3 + Dist n (•MakeRand 0).Range h
Seq←⌽∘↕⊸(<⌜) ⋄ EE←(⋈˜<e)/⊢
ind0 ← (⊢↑˝·-⌾⊏(2‿1×outl)+⌜≢) EE ⟨hh,w⟩↑h Seq bar
thr ← 2×blk←8

# Insert to buffer
bp ← ⌊ (w-thr) × ÷⟜(⌈´) -⟜(⌊´) bar
buf ← w⥊∞
steal ← ↕0
Insert ← {𝕊f‿j0‿b: s←e×b‿1
  i←{j+↩b≥k←𝕩⊑buf⋄𝕊⍟(∞≠k)1+𝕩}j←j0
  c←i-j0
  v←@ ⋄ buf ({v↩𝕩}b⊸»)⌾((j↓↕i)⊸⊏)↩
  m←⊢´v
  ⟨2, f⋈h-b, s⥊2⟩‿⟨8, j⋈hh-m, EE 3×m Seq v⟩ ∾ {thr>c?⟨⟩;
    thr↩blk
    c⌊⌾(÷⟜blk)↩
    st←≠steal
    buf (∞¨⊣{steal∾↩𝕩})⌾((j0+↕c)⊸⊏)↩
    ⟨2, j0⋈hh-m, (e×m‿c)⥊0 ⟩‿⟨20, st⋈0, EE 5×h Seq (-c)↑steal⟩
  }
}
updates ← ∾ <∘Insert˘ ⍉>(↕≠bar)‿bp‿bar

# Filter buffer
Filter ← {d𝕊f‿t‿b: s←e×b‿1
  ⟨2, f⋈hh-b, s⥊4⟩‿⟨d, t⋈0, (-e×h)↑s⥊3⟩
}
bi ← /∞≠buf
updates ∾↩ ⥊ (2×(≠buf)(«-⊢)bi) Filter˘ ⍉>⟨bi,bar(-+↕∘⊢)○≠bi,bi⊏buf⟩

# Merge
arr ← steal∾bi⊏buf
Merge ← {𝕊i‿l‿n:
  sl←@ ⋄ arr ∧∘{sl↩𝕩}⌾(n↑i↓⊢)↩
  cp ← ⟨40, 0⋈h+p, EE 5×h Seq l↑sl⟩
  r ← (l⊸<⊸(i⊸×⊸+⋈¨(h+p)×¬∘⊣) ↕n) ⋈¨ {EE(-h)↑𝕩‿1⥊4}¨ sl
  (⋈cp) ∾ ⥊ (sl⍋⊸⊏2∾¨r) ≍˘ (i+↕n) {⟨4, 𝕨‿0, EE(-h)↑𝕩‿1⥊3⟩}¨ ∧sl
}
ms ← ∾ (↕∘⌈⌾(2⋆⁼⊢))⊸({d←2×𝕨⋄∾⟜𝕨‿d¨↕∘⌈⌾(÷⟜d)𝕩}¨) 4
updates ∾↩ ∾ Merge¨ (ms⌾(÷⟜blk) ≠steal) ∾ ⋈0∾≠¨steal‿arr

updates 80⌾⊑⌾(¯1⊸⊑)↩
updates (outl+e×⌽)⌾(1⊸⊑)¨↩

"robinhood.gif" •file.Bytes col EncodeGIF ⟨30,0‿0,ind0⟩ <⊸∾ updates
