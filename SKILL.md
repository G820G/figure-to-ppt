---
name: figure-to-ppt
description: Convert a single scientific, project, or research-framework figure into a high-fidelity editable PowerPoint slide. Use for raster diagram-to-PPT conversion where source layout, Chinese/English text editability, and visual reconstruction matter.
---

# Figure To Ppt

Create a one-slide `.pptx` that reproduces a supplied figure as faithfully as practical while retaining editable text and safely reconstructible PowerPoint shapes. This skill is optimized for scientific workflows, project workflows, and research-framework diagrams; it is not a general presentation-design workflow.

## Scope and defaults

- Work from one source image to one slide. Preserve the source aspect ratio by setting the custom slide size from the source image; do not force a widescreen layout.
- Use high-fidelity mode: visual similarity is the primary goal. Recreate only high-confidence basic geometry as native PowerPoint objects. Preserve complex, ambiguous, decorative, or compound graphics as transparent cropped image elements.
- Before extracting or building any arrows, resolve the `arrow_native_mode` option. If the user has not already chosen it, ask: “是否启用箭头原生化？启用后，能可靠识别的曲线、折线和箭头会改为可编辑 PPT 连接线，但可能有轻微视觉偏差；不启用则保留高保真透明抠图箭头。” Do not silently choose on the user's behalf. Record the answer in the layout manifest and reconstruction report.
- Do not embed a hidden source-image reference layer unless the user explicitly requests it.
- Rebuild recognized text as editable text boxes. Select the font from the text language and source appearance, following [references/reconstruction-rules.md](references/reconstruction-rules.md); report every substitution. Preserve content, placement, color, alignment, approximate size, weight, rotation, and wrapping as closely as the source permits.
- Use a normal editable PPTX deliverable. Do not flatten the entire figure into one background image merely to obtain a perfect visual match.

## Workflow

1. Inspect the input for resolution, aspect ratio, background, language, rotated text, equations, and visually independent regions. For a complex figure, partition it into logical regions (for example title, input, central process, outputs, notes) before element extraction. Regions are an analysis aid only: compose all results on the original single slide.
2. Create a layout manifest that records the source pixel dimensions plus each element's bounding box, layer order, type, confidence, and reconstruction choice. Keep coordinates in source pixels until final slide construction.
3. Separate text from surrounding artwork. OCR text, retain confidence and its geometry, then make a text mask and remove or exclude the original glyphs from every reused image crop. Repair the masked substrate from adjacent pixels or its local background; do not cover old text with opaque white rectangles. Treat equations, unreadable text, and low-confidence OCR as explicit exceptions rather than silently fabricating wording.
4. Split non-text artwork into the smallest semantically independent elements practical, not merely the smallest connected pixel region or rectangular crop. Generate one tightly alpha-masked PNG per independent object, including when objects touch or overlap; for example, a purple cell beside two yellow cells produces three image objects. Use [references/element-segmentation.md](references/element-segmentation.md) for mask construction, overlap handling, and permitted fallback behavior. Maintain enough transparent padding to retain shadows, arrowheads, and anti-aliased edges.
5. Apply the reconstruction rules in [references/reconstruction-rules.md](references/reconstruction-rules.md). If `arrow_native_mode` is enabled, follow [references/arrow-native-mode.md](references/arrow-native-mode.md) to rebuild eligible arrows as editable PowerPoint connectors. Otherwise retain arrows as transparent instance-masked crops. Use native non-arrow shapes and connectors only where their geometry and layering can be inferred confidently.
6. Build the PowerPoint at a coordinate scale derived from the source image and slide dimensions. Preserve z-order: backgrounds and regions first, connectors behind nodes and text when appropriate, then foreground annotations. All editable text must remain above its relevant graphical element.
7. Export the PPTX, then independently render that exported file and compare it with the source. Follow [references/runtime-and-rendering.md](references/runtime-and-rendering.md) to initialize the presentation runtime and recover from workspace dependency-path errors. Follow [references/quality-control.md](references/quality-control.md) for visual checks, acceptance criteria, and the handoff report. A build-time preview does not replace exported-PPTX validation.

## Deliverables

Deliver the editable `.pptx` and a concise reconstruction report. The report must state:

- the slide size and source-to-slide scale;
- OCR or typography uncertainties, including font substitutions;
- elements retained as image crops and why;
- the `arrow_native_mode` choice, rebuilt connectors, and any arrows retained as crops;
- regions or elements that need manual review.

Save working masks, crops, manifests, and rendered comparisons only as intermediate artifacts unless the user requests them. Do not include a hidden copy of the original image by default.
