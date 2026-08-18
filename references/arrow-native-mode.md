# Arrow native mode

Read this reference only after the user has explicitly enabled `arrow_native_mode`.

## Purpose

Replace eligible raster arrows with editable PowerPoint connectors. This is an editability option, not a fidelity guarantee: minor visual differences in curvature, routing, joins, and arrowhead shape are acceptable only because the user chose this mode.

## Eligibility and reconstruction

For each arrow or line, use a native connector only when all of the following are clear from the source:

- The intended start and end objects or coordinates.
- The direction of flow and any arrowhead/tail style.
- The route class: straight, elbow/polyline, or simple curve.
- The line color, approximate weight, dash pattern, and layer position.

Create a separate native connector for each eligible visual line:

- Use a straight connector for direct lines.
- Use an elbow or multi-segment connector for visibly orthogonal routes.
- Use a curved connector for simple arc-like flow lines. Approximate the source curve rather than forcing a straight or elbow route.
- Add the connector before node/image objects so it remains behind them; connect to native shape anchors when available, otherwise use explicit endpoints aligned to the visible object boundary.
- Preserve arrowheads, tail ends, width, color, and dash style as closely as the PowerPoint connector model permits.

## Fallback and manifest

Do not force native connectors for hand-drawn, ornamental, multi-branch, ambiguous, partially hidden, or complex Bezier-like arrows. Keep those as separately selectable transparent instance-masked image crops, even when `arrow_native_mode` is enabled.

For every arrow, record `arrow_native_mode`, `reconstruction` (`native_connector` or `transparent_crop`), source/target or endpoints, route class, style estimate, confidence, and fallback reason where applicable. Never merge multiple arrows into one crop.

## Verification

After exporting and independently rendering the PPTX:

- Move or inspect each native connector independently to confirm that it is editable and does not cross labels or nodes.
- Compare its endpoints, curvature/turns, arrowhead direction, and z-order against the source.
- If a native connector creates material visible error, retain the connector only if the user prefers editability; otherwise revert that arrow to an instance-masked crop and document the change.
