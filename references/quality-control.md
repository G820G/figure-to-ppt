# Quality control and handoff

Use this reference after the PPTX has been built.

## Render-and-compare loop

1. Render the exported `.pptx` itself to a raster image at a resolution at least as large as the source image. A render produced directly from the in-memory authoring object is diagnostic only, not acceptance evidence.
2. Fit the render and source to the same dimensions without changing aspect ratio. Create an overlay or difference image for inspection.
3. Review the entire slide, then zoom into text, arrow endpoints, touching elements, masked crop edges, and high-density regions.
4. Correct material differences and repeat the render. Do not stop at an XML-valid PPTX if its visible composition is wrong.

## Acceptance checks

- The slide dimensions preserve the original aspect ratio.
- No original text remains visibly duplicated beneath editable text.
- Repaired text regions preserve their local background or artwork: no opaque cleanup rectangle, visible repair seam, erased neighboring detail, or glyph halo remains.
- Text is readable, has the correct content wherever OCR confidence is sufficient, and closely matches its source placement and wrapping.
- Every independent visual object is separately selectable in PowerPoint. Adjacent or overlapping semantic objects have separate alpha-masked image objects rather than a shared rectangular crop.
- Crops have transparent, clean edges: no rectangular background, clipped arrowhead, unwanted neighboring object, or visible halo. Inspect each asset over a checkerboard or contrasting temporary background as well as in the final slide.
- A composite fallback appears in the manifest and report, with a specific reason why independent masks could not be recovered from the source.
- Flow direction remains unambiguous: connectors terminate at the intended nodes and stay behind labels when the reference does.
- When `arrow_native_mode` is enabled, every eligible arrow is independently selectable and editable as a PowerPoint connector; verify endpoint attachment, routing, line weight, arrowhead direction, and layering after exported-file rendering. Arrows rejected by the confidence check remain independent transparent crops and are listed in the report.
- No major source object is missing, materially displaced, or incorrectly layered.
- The delivered slide is editable: text boxes, native shapes, native connectors, and image crops are separate selectable objects where reconstruction allowed it.

## Report manual-review items

Flag rather than silently guess when any of the following occurs:

- illegible, partial, rotated, or low-confidence OCR;
- unavailable font or a font substitution that changes wrapping;
- a label retained as a crop because its underlying artwork could not be repaired safely;
- equations or symbols retained as image crops;
- a complex region retained as a composite crop;
- any group crop created because objects were adjacent, connected, or convenient to crop rather than because independent visible masks were unrecoverable;
- visible difference that could not be corrected without information absent from the source.
- an arrow retained as a crop while `arrow_native_mode` was enabled, including the reason it failed the native-connector confidence check.

The final report should state the slide size, source scale, any font substitution, crop-only elements, the `arrow_native_mode` choice, connector/crop decisions, and unresolved items. Do not include the source image in a hidden layer unless the user asked for that feature.
