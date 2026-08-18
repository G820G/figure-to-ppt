# Presentation runtime and exported-file verification

Use this reference whenever creating or validating the PPTX. Its purpose is to prevent a false pass based only on an in-memory preview.

## Required verification sequence

1. Load the workspace dependency information and take the supplied Node.js executable and `node_modules` path as the authoritative runtime locations.
2. Initialize the artifact-tool workspace before generating the slide. Validate that the resolved `@oai/artifact-tool/package.json` exists before running the authoring module.
3. Export the PPTX.
4. Invoke the presentation renderer against that exported PPTX, writing the render to a fresh verification directory. Inspect the resulting image, not merely the authoring preview.
5. Run the overflow/geometry check against the exported PPTX. Compare the exported-file render with the source using an overlay or difference image.

## Recovery for workspace dependency-path failures

Some presentation helpers resolve a runtime path beneath the current workspace rather than the actual bundled runtime. If initialization or rendering reports a missing `@oai/artifact-tool/package.json` in a workspace-local `.cache` path:

1. Do not hard-code an individual machine's package path in the generated presentation module.
2. Use the dependency information already supplied by the host, then run [`scripts/prepare_artifact_tool_workspace.ps1`](../scripts/prepare_artifact_tool_workspace.ps1) with the build workspace and the authoritative Node `node_modules` folder. Set `-CompatibilityRoot` to the directory used as `HOME` by the presentation helper—normally the conversation workspace root, which can differ from the temporary build workspace. When the local PowerShell execution policy blocks scripts, invoke it for this one process with `powershell -ExecutionPolicy Bypass -File <script> ...`; do not alter the machine-wide execution policy. The helper creates the compatibility junction only when no conflicting runtime folder exists.
3. Rerun initialization, export, independent rendering, and overflow checking with the resolved Node/Python executables.
4. If rendering still fails, inspect the exported PPTX object manifest and retain the build preview for diagnosis, but report exported-file visual verification as incomplete. Do not state that the deck passed visual QA.

## Completion condition

Visual QA passes only when the exported PPTX renders successfully through an independent renderer and the resulting render has been compared to the source. If the renderer is unavailable after the defined recovery procedure, deliver only if the user accepts that limitation; otherwise keep the conversion open for environment repair.
