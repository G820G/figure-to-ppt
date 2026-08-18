# figure-to-ppt

`figure-to-ppt` is a Codex skill for converting one raster scientific figure, project workflow, or research-framework diagram into a high-fidelity, editable PowerPoint slide.

It is designed for diagrams where visual fidelity matters but text, simple shapes, and optionally arrows should remain editable.

## What it does

- Preserves the source image aspect ratio in a custom one-slide `.pptx`.
- Rebuilds readable labels as editable PowerPoint text.
- Selects fonts by content: Microsoft YaHei for CJK/mixed labels, Arial for Latin-only scientific labels, and Cambria Math for reliable mathematical expressions.
- Separates visual objects at the semantic-object level. Touching objects such as cells, particles, icons, and arrows become separate alpha-masked PNG objects, rather than a shared rectangular crop.
- Uses native PowerPoint shapes only when their geometry is sufficiently clear; detailed scientific illustrations remain high-fidelity transparent images.
- Removes source text from reused artwork through masks and local repair, rather than covering it with white rectangles.
- Verifies the exported PPTX by independently rendering it and checking for overflow before delivery.

## Arrow native mode

Before every conversion, the skill asks whether to enable `arrow_native_mode`:

> 是否启用箭头原生化？启用后，能可靠识别的曲线、折线和箭头会改为可编辑 PPT 连接线，但可能有轻微视觉偏差；不启用则保留高保真透明抠图箭头。

When enabled, eligible straight, elbow, and simple curved arrows become editable PowerPoint connectors. Ambiguous or complex arrows remain independent transparent image objects and are reported as such.

## Install

Clone this repository into your Codex skills directory:

```powershell
git clone https://github.com/<your-account>/figure-to-ppt.git "$env:USERPROFILE\.codex\skills\figure-to-ppt"
```

Restart Codex or start a new task so the skill is discovered. You can then ask Codex to use `figure-to-ppt` or request a conversion such as:

```text
Use figure-to-ppt to convert this scientific workflow image to an editable PPTX.
```

If your Codex installation supports installing skills directly from GitHub, use its skill-install workflow with your repository URL instead.

## Expected workflow

1. Supply one raster diagram.
2. Choose whether arrow native mode is enabled.
3. Codex analyzes the layout, OCR text, semantic objects, and visual layers.
4. It creates one editable slide, builds a layout manifest, and exports a `.pptx`.
5. It independently renders the exported PPTX, compares it against the source, and reports anything needing manual review.

## Requirements

- A Codex environment with the `presentations` capability, including `@oai/artifact-tool`.
- Python/Pillow or equivalent image-processing support for alpha masks and local repair.
- PowerPoint or a compatible viewer to edit the result.

The included compatibility helper addresses some Codex workspace runtime-path issues. It never overwrites an existing incompatible runtime path. See [runtime-and-rendering.md](references/runtime-and-rendering.md).

## Limitations

- Low-resolution, blurred, occluded, or handwritten text can require manual correction.
- Complex scientific artwork remains editable as independent image objects, rather than editable vector paths.
- Native-arrow mode deliberately permits small visual differences in exchange for editable connectors.
- The skill does not recreate obscured parts of overlapping source objects that are not visible in the raster image.

## Repository layout

```text
figure-to-ppt/
├── SKILL.md
├── agents/openai.yaml
├── references/          # Reconstruction, segmentation, arrow, QA, and runtime rules
└── scripts/             # Runtime compatibility helper
```

## Contributing

Contributions are welcome, especially example diagrams with permission to redistribute, improved instance-segmentation strategies, and validation fixes. Please do not include confidential source figures, API keys, user data, generated PPTX files, or local runtime caches in pull requests.

## License

MIT. See [LICENSE](LICENSE).
