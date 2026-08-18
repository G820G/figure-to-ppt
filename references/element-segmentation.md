# Semantic element segmentation

Use this reference for every non-text raster element before creating the PPTX. The goal is an editable slide whose image objects match the smallest meaningful visual objects, not a slide filled with rectangular snippets.

## Minimum-element rule

1. Identify visual objects by their role and boundary: cells, particles, icons, arrows, nodes, badges, illustrations, and decorative shapes are distinct objects when a person would reasonably move, delete, or replace them independently in PowerPoint.
2. Do not let bounding-box overlap, physical contact, similar colors, or a connected-component detector merge these objects.
3. Create one raster asset and one PPT image object for each identified object. Example: a purple cell with two yellow cells immediately above it is three assets—`purple-cell.png`, `yellow-cell-01.png`, and `yellow-cell-02.png`—not one 3-object crop.

## Mask construction

For each target object:

1. Obtain an instance-level foreground mask using segmentation, color/edge cues, and manual correction when required. A generic foreground/background mask is insufficient when multiple objects are present.
2. Remove every non-target object from that asset by setting its alpha to zero. Keep the target's anti-aliased edge, soft shadow, and glow with a feathered alpha transition rather than cutting along an opaque pixel edge.
3. Crop the transparent canvas tightly around the target's visible bounds, with only the small padding needed for retained soft effects.
4. Place the crop at the original source coordinates using its canvas origin. Store `visible_bounds_px`, `canvas_bounds_px`, `mask_path`, `object_id`, `z_index`, and `segmentation_confidence` in the manifest.
5. Preview each asset on checkerboard, white, and dark temporary backgrounds. This exposes rectangular remnants, halos, and accidental inclusion of neighboring elements.

## Touching and occlusion

- **Touching but distinguishable:** draw or refine a separation boundary and export two masks. This is the expected path for adjacent biological cells, icons touching labels, and particles over illustrations.
- **One object partially in front of another:** use z-order and visible-region masks. The rear object asset contains only pixels visibly belonging to it; never fabricate its concealed section.
- **Shared glow or shadow:** assign the effect to the visually frontmost owner when possible. If that would create a visible seam, retain the shared effect in a narrowly scoped effect asset separate from both objects, and document it.
- **Unrecoverable boundary:** use a composite only after recording why instance masks cannot be recovered without visible artifacts. The composite must be named for its members, e.g. `cell-pair-composite-fallback`, and listed for manual review.

## Prohibited shortcuts

- Do not export a rectangular region that includes multiple semantic objects just because it is convenient.
- Do not use connected-component output without checking whether touching objects were merged.
- Do not solve a merged crop by hiding parts of it underneath other slide objects; each asset itself must have transparent non-target pixels.
- Do not fabricate occluded visual content to force a complete isolated object.

## Acceptance test

Before delivery, temporarily place each extracted asset on a contrasting background and move it a small distance in the PPTX or render a contact sheet. It passes only when no other semantic object moves with it and no rectangular or halo artifact is revealed.
