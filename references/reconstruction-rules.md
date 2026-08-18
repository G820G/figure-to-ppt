# Reconstruction rules

Use this reference after the image has been inspected and a layout manifest exists.

## Classify every visual item

| Item | Preferred reconstruction | Fallback |
| --- | --- | --- |
| Plain rectangle, rounded rectangle, ellipse, diamond, triangle | Native PowerPoint shape when outline, fill, radius, and rotation are clear | Transparent crop |
| Straight line, simple elbow line, simple arrow | Native connector only when `arrow_native_mode` is enabled and endpoints, routing, and arrowheads are clear | Transparent instance-masked crop |
| Text label, heading, note | Editable text box | Retain as a crop only when OCR is uncertain and transcription cannot be verified |
| Equation, chemical structure, dense mathematical notation | Editable text only if it can be transcribed and rendered accurately | Transparent crop, flagged for review |
| Icon, logo, illustration, patterned fill, textured area, gradient, complex callout | One transparent alpha-masked image per semantically independent object | Composite crop only under the documented fallback rule |
| Grouped module or panel | Reconstruct its simple container natively only when clear; reconstruct internal items individually | Single transparent group crop |

## Decision thresholds

Choose a native object only if all relevant properties can be inferred with high confidence:

- Its outer geometry and rotation are unambiguous.
- The fill, outline, and corner treatment can be matched without losing visible detail.
- It does not merge inseparably with a neighboring element, shadow, or textured background.
- For connectors, both attachment points and routing are known.

If any condition fails, favor a transparent crop. In high-fidelity mode, a movable crop is preferable to an editable but visibly incorrect approximation. Apply the separate user-selected arrow policy in [arrow-native-mode.md](arrow-native-mode.md).

## Element extraction

- Define the minimum element by semantic object identity, not by its rectangular bounding box, color, or connected-component result. Objects that touch, overlap, or sit within the same rectangular box remain separate when they can be independently selected in a sensible PPT edit—for example, one purple cell plus two yellow cells must become three separate image objects.
- Each raster element must be a tightly cropped PNG with an alpha mask that follows the visible object boundary. Its rectangular file bounds are only a transparent canvas; no neighboring object's pixels may remain inside that canvas. Record the tight visible bounds and the canvas bounds separately in the manifest.
- Do not use a simple rectangular crop as a substitute for segmentation. A crop is acceptable only if every pixel outside the target object's contour is fully transparent.
- Make masks slightly inclusive at anti-aliased boundaries, arrow tips, shadows, and glows. Inspect at 100% scale to avoid halos and clipped effects.
- If an element overlaps another, preserve the stacking order in the manifest, use instance masks for each visible object, and set pixels belonging to the other object fully transparent. Do not merge them merely because their visible regions touch. Where hidden geometry cannot be inferred, preserve only the visible portion of the occluded object; do not hallucinate missing pixels.
- Before using a crop beneath reconstructed text, create a mask from the OCR word/line polygons, dilated just enough to include anti-aliasing and shadows. Remove that mask from every affected crop, then repair the exposed substrate from adjacent pixels, its estimated local background, or an equivalent neighboring pattern. Never use an opaque white cleanup rectangle: it damages non-white backgrounds and is visible when objects move.
- Save the text-mask geometry in the layout manifest. Inspect each repaired crop at 100% size and verify that no source glyph, halo, or rectangular repair boundary remains.
- If a text region sits on artwork that cannot be repaired credibly from the source, retain that specific label as an image crop, mark it as non-editable in the report, and flag it for manual review. Do not invent a repair or leave duplicate text.
- A composite crop is permitted only when the source makes separate visible-object masks genuinely unrecoverable and a single composite is needed to avoid visible damage. It is not permitted merely because segmentation is inconvenient, objects are adjacent, or their bounding boxes overlap. Mark every composite as `composite_fallback` in the manifest and report its member objects and reason.
- Apply the detailed procedure in [element-segmentation.md](element-segmentation.md) before declaring a composite fallback.

## Text handling

- Preserve source line breaks and horizontal/vertical alignment before adjusting point size. Text box padding should be minimal and consistent with the source.
- If a known source font is available, use it when installed. Otherwise classify the OCR text before assigning a typeface:
  - Chinese, Japanese, Korean, or mixed Chinese/English label: `Microsoft YaHei` (`微软雅黑`).
  - Latin-only English, numbers, or common scientific abbreviations: `Arial`, which more closely matches typical raster scientific figures than a CJK UI font.
  - Mathematical expressions: `Cambria Math` only when the OCR transcription and rendered notation are reliable; otherwise retain the expression as a crop and flag it.
  - Other scripts: choose an installed font with coverage and record the choice.
- Check font availability before building. If the preferred face is unavailable, use a metrically close installed fallback, rerender after export, tune the text box, and report the substitution. For mixed-script labels, prioritize glyph coverage and line-wrap fidelity over using several visually inconsistent fonts.
- Estimate font size from the text bounding-box height, then render and tune it against the reference. Preserve the source line break before reducing font size or changing the text-box width.
- Use the original font color and weight where detectable. Copy rotation for vertical or angled labels.
- OCR must not invent unknown characters. Flag low-confidence, partial, occluded, or equation text for manual review.
- Text should be added after the graphical layer is stable, so it remains editable and correctly ordered.

## Coordinate and layer discipline

- Keep `x`, `y`, `width`, `height`, and connector points in source pixels in the manifest. Use one proportional conversion to the custom slide coordinate system.
- Preserve aspect ratio; do not independently stretch horizontal and vertical coordinates.
- Assign and retain z-order explicitly. A typical order is background, broad panels, connectors, nodes, icons/crops, then text and foreground annotations.
