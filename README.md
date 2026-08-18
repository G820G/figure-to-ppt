# figure-to-ppt

简体中文 | [English](README.en.md)

`figure-to-ppt` 是一个 Codex 技能，用于将单张科研图、项目流程图或研究框架图转换为高保真、可编辑的 PowerPoint 幻灯片。

它适用于既要尽可能保留原图视觉效果，又希望文字、简单图形以及可选箭头能够编辑的图像。

## 功能

- 根据原图宽高比创建单页自定义尺寸的 `.pptx`。
- 将可识别标签重建为可编辑的 PowerPoint 文本。
- 按文本内容自动选择字体：中文/中英混排优先使用微软雅黑；纯英文科研标签优先使用 Arial；可靠识别的数学表达式使用 Cambria Math。
- 按“语义最小元素”分割图像。相接或相邻的细胞、颗粒、图标和箭头会成为独立的透明蒙版 PNG，而不是同一张矩形裁剪图。
- 仅在图形几何可可靠识别时转换为原生 PowerPoint 图形；复杂科研插图保留为高保真透明图片对象。
- 通过文字蒙版和局部修补去除复用图层中的原始文字，不使用白色矩形遮盖。
- 导出后独立渲染 PPTX，并进行越界检查和视觉核验。

## 箭头原生化

每次转换前，技能都会询问是否启用 `arrow_native_mode`：

> 是否启用箭头原生化？启用后，能可靠识别的曲线、折线和箭头会改为可编辑 PPT 连接线，但可能有轻微视觉偏差；不启用则保留高保真透明抠图箭头。

启用后，可可靠识别的直线、折线和简单曲线箭头会转换为可编辑的 PowerPoint 连接线。复杂、模糊或走向不明确的箭头仍会保留为独立透明图片对象，并在转换报告中说明。

## 安装

将仓库克隆至 Codex 技能目录：

```powershell
git clone https://github.com/G820G/figure-to-ppt.git "$env:USERPROFILE\.codex\skills\figure-to-ppt"
```

重启 Codex 或新建任务，使技能被重新发现。之后可以直接要求 Codex 使用 `figure-to-ppt`，例如：

```text
使用 figure-to-ppt 将这张科研流程图转换为可编辑 PPTX。
```

如果你的 Codex 版本支持直接从 GitHub 安装技能，也可以在技能安装流程中填写此仓库地址。

## 工作流程

1. 提供一张流程图、科研图或研究框架图。
2. 选择是否启用箭头原生化。
3. Codex 分析版式、OCR 文字、语义对象及图层顺序。
4. 生成单页可编辑幻灯片、布局清单并导出 `.pptx`。
5. 独立渲染导出的 PPTX、与原图对比，并报告需要人工复核的内容。

## 环境要求

- 具备 `presentations` 能力及 `@oai/artifact-tool` 的 Codex 环境。
- 支持透明蒙版和局部修补的 Python/Pillow 或同类图像处理环境。
- 用于编辑结果的 Microsoft PowerPoint 或兼容查看器。

仓库中的兼容脚本可处理部分 Codex 工作区运行时路径问题，并且不会覆盖已有的不兼容运行时路径。详见 [runtime-and-rendering.md](references/runtime-and-rendering.md)。

## 限制

- 低分辨率、模糊、遮挡或手写文字可能需要人工修正。
- 复杂科研插图会以独立、可移动的图片对象保留，而非可编辑矢量路径。
- 箭头原生化以轻微视觉差异换取可编辑连接线。
- 技能不会臆造原始位图中被遮挡而不可见的对象部分。

## 仓库结构

```text
figure-to-ppt/
├── SKILL.md
├── agents/openai.yaml
├── references/          # 重建、分割、箭头、质量控制和运行时规则
└── scripts/             # 运行时兼容脚本
```

## 参与贡献

欢迎贡献，尤其是允许公开发布的示例图、改进的实例分割策略和验证修复。请勿在 Pull Request 中提交保密源图、API Key、用户数据、生成的 PPTX 或本地运行时缓存。

## 许可证

MIT。详见 [LICENSE](LICENSE)。
