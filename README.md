# DocDiff · 文档比对工具

> 两份文档放进去，改了哪些字、哪张图被换掉，一眼看清。

[![Release](https://img.shields.io/github/v/release/jim-jiang-github/DocDiff?display_name=tag)](https://github.com/jim-jiang-github/DocDiff/releases)
[![Release Workflow](https://github.com/jim-jiang-github/DocDiff/actions/workflows/release.yml/badge.svg)](https://github.com/jim-jiang-github/DocDiff/actions/workflows/release.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![No Server](https://img.shields.io/badge/backend-none-success.svg)](#隐私与安全)

**在线使用：<https://jim-jiang-github.github.io/DocDiff/>**（该站点始终对应最新的 Tag 发布版本）

---

## 这是什么

DocDiff 是一个**纯前端**的文档差异比对工具：把一个旧版本和一个新版本丢进去，它会逐行、逐词标出新增、删除与修改，并把两份文档的原始版式并排展示出来。

它没有任何后端。Word / PDF 的解析全部在浏览器里完成，文件不会离开你的电脑——这也是它适合处理**合同、协议、投标文件、内部制度**这类敏感材料的原因。

常见的用法：

| 场景 | 你关心的问题 | DocDiff 的回答 |
| --- | --- | --- |
| 合同来回修订 | 对方偷偷改了哪几个字？ | 逐词级高亮，连标点变化都不放过 |
| 方案 / 标书改版 | 新增了哪些章节？ | 新增行整行绿色标注 + 统计行数/词数 |
| 论文 / 标准对照 | 段落只是重新排版，还是内容真变了？ | 换行差异单独标注，可一键忽略 |
| 文件里的插图 | 图被悄悄替换了吗？ | 对比图片 SHA-256 指纹，红/绿遮罩标记 |
| 归档留痕 | 怎么把差异发给别人？ | 导出为单文件 HTML，双击即可查看 |

## 功能特性

- **双层比对算法**：行级用 Patience Diff 找锚点对齐，行内再用 LCS 做逐词比对，中文按字切分、英文按单词切分，标点与数字单独成词。
- **智能段落合并**：PDF 复制出来的文本常是「一行一句」的硬换行，工具会按句末标点、条款编号（`第X条`、`1.2`、`（一）`）自动还原成段落，避免整段被误判为改写。
- **换行差异单独处理**：只有换行/分段位置不同、文字完全一致时，用黄色标注为「非内容差异」，可一键忽略。
- **未修改内容自动折叠**：只保留变更处上下各 2 行，长文档也能快速浏览；配合「上一处 / 下一处」跳转和相似度百分比。
- **原文并排预览**：Word 用 docx-preview 按原版式渲染（含页眉页脚、脚注），PDF 用 pdf.js 逐页绘制；两侧滚动自动同步。
- **插图差异检测**：比对 docx 内嵌图片的 SHA-256 指纹，**视觉相同但文件字节被替换过的图也会被标出来**，并在预览中加红/绿遮罩。
- **结果可留档**：导出为内嵌样式的单个 HTML 文件，发给同事直接打开，不需要装任何东西。
- **零外部依赖**：所有解析库都放在 `lib/` 里，页面运行时不发起任何外部请求。

## 支持格式

| 格式 | 文本比对 | 原文并排预览 | 说明 |
| --- | :---: | :---: | --- |
| `.docx` | ✅ | ✅ | 推荐格式，插图比对也只支持这一种 |
| `.pdf` | ✅ | ✅ | 需要 PDF 带文字层；扫描件是图片，提取不到文字 |
| `.txt` `.md` `.log` `.csv` | ✅ | — | 自动识别 UTF-8 / GBK 编码 |
| `.doc` | ❌ | ❌ | 旧二进制格式，请先用 Word 另存为 `.docx` |

## 使用步骤

1. 左侧放**原始文档**（旧版），右侧放**修改文档**（新版）。可以点击选择、直接拖拽文件到卡片，也可以点「✎ 改为粘贴文本」直接贴内容。
2. 两侧内容就位后会**自动开始比对**，无需点按钮（粘贴模式下边输入边比对）。
3. 在「📋 文本比对」页看差异：红色为删除，绿色为新增，黄色为仅换行/分段不同；顶部有相似度、差异处数、增删行数与词数。
4. 切到「📄 原文并排预览」核对版式与插图，红色遮罩表示该图只在旧版存在，绿色遮罩表示只在新版存在。
5. 需要留档时点「💾 导出比对结果」，得到一个可独立打开的 HTML 文件。

选项说明（工具栏右侧）：

| 选项 | 默认 | 作用 |
| --- | :---: | --- |
| 忽略大小写 | 关 | 英文大小写不算差异 |
| 忽略空白差异 | 开 | 空格数量、制表符差异不算差异 |
| 忽略换行/分段差异 | 开 | 仅换行位置不同时不标红绿 |
| 按段落合并断行 | 开 | 把 PDF 的硬换行重组为段落 |
| 隐藏未修改内容 | 开 | 折叠相同内容，只留变更上下文 |

## 项目结构

```
DocDiff/
├── index.html                 # 单页应用：样式 + 比对算法 + 交互
├── lib/                       # 本地化的第三方库，无 CDN 依赖
│   ├── mammoth.browser.min.js # docx → 纯文本
│   ├── docx-preview.min.js    # docx 原版式渲染
│   ├── jszip.min.js           # 解析 docx 内部 zip 结构
│   ├── pdf.min.js             # PDF 文字提取与页面渲染
│   └── pdf.worker.min.js
├── favicon.ico
├── scripts/build.sh           # 构建脚本：产出 dist/ 并注入版本号
├── .github/workflows/
│   ├── release.yml            # 打 Tag → 构建 → Release → 部署 Pages
│   └── ci.yml                 # 分支/PR 的静态资源校验与试构建
└── dist/                      # 构建产物（不入库）
```

## 本地使用与构建

直接双击 `index.html` 就能用，不需要装任何东西。如果浏览器对本地文件限制较严（个别环境 `crypto.subtle` 不可用，图片指纹会自动降级为内置的纯 JS 实现），也可以起个静态服务：

```bash
python -m http.server 8080
# 打开 http://localhost:8080
```

构建发布产物（Windows 下用 Git Bash 执行）：

```bash
bash scripts/build.sh          # 版本标记为 dev
bash scripts/build.sh v0.0.1   # 注入指定版本号
```

产物在 `dist/`，包含 `index.html`、`lib/`、`favicon.ico`、`version.json`。

## 发布流程：打 Tag 即发版

仓库的发布完全由 **Git Tag** 驱动。Tag 的格式就是版本号，必须严格符合语义化版本：

```
v<MAJOR>.<MINOR>.<PATCH>[-预发布标识]
```

| Tag 示例 | 含义 | 什么时候用 |
| --- | --- | --- |
| `v0.0.1` | 首个版本 | 项目第一次发布（当前版本） |
| `v0.0.2` | 补丁版 | 只修 bug、改文案，功能不变 |
| `v0.1.0` | 小版本 | 增加了向后兼容的新功能 |
| `v1.0.0` | 大版本 | 有不兼容的变更，或功能正式定型 |
| `v0.2.0-beta.1` | 预发布 | 先给内部试用，不会被标成 Latest |

几个硬性约束：

- **必须带 `v` 前缀**，`0.0.1`、`release-1.0`、`v1.0`、`v01.0.0` 都会被流水线拒绝并报错；
- 每一段数字不能有前导零，`v0.0.01` 不合法；
- 同一个版本号只能打一次 Tag，重复发布请递增版本。

打一个版本：

```bash
git checkout dev
git pull
git tag -a v0.0.1 -m "DocDiff v0.0.1 首个版本"
git push origin v0.0.1
```

推送 Tag 后 `.github/workflows/release.yml` 会自动执行：

1. **校验 Tag 格式**（不合法直接失败，不会产出半成品发布）；
2. 检查该提交是否在 `dev` 分支历史中，不在则给出 warning；
3. 运行 `scripts/build.sh` 构建 `dist/`，把版本号注入页脚与 `version.json`；
4. 打包 `DocDiff-v0.0.1.zip` 作为 Release 附件，并用 `--generate-notes` 自动生成更新说明；
5. 创建 GitHub Release；
6. 把 `dist/` 部署到 GitHub Pages，站点页脚显示的即该 Tag 版本。

如果发布内容有问题想撤回：

```bash
gh release delete v0.0.1 --yes --cleanup-tag
git push origin :refs/tags/v0.0.1   # 若上面没清理干净，再删远端 Tag
```

> Pages 站点在旧 Tag 被删除后，仍会停留在最后一次成功部署的内容，重新打一个正确版本即可覆盖。

## 首次启用 GitHub Pages（一次性）

首次打 Tag 前需要手动打开 Pages，否则部署步骤会报 `Get Pages site failed`：

1. 进入仓库 **Settings → Pages**；
2. **Build and deployment → Source** 选择 **GitHub Actions**（不要选 Deploy from a branch）；
3. 回到 Actions 页面重跑一次失败的 release 工作流，或重新打 Tag。

站点地址为 `https://jim-jiang-github.github.io/DocDiff/`。

## 版本历史

| 版本 | 内容 |
| --- | --- |
| `v0.0.1` | 首个版本：双层文本比对、段落合并、原文并排预览、插图指纹校验、结果导出 |

## 技术实现

- **行级对齐**：`diffLines()` 先剥离公共前后缀，再用「两边都只出现一次的行」作为锚点，对锚点位置求最长递增子序列（Patience Diff 的经典做法），锚点之间递归处理。相比逐行 LCS，长文档更快，且不容易在大段重复文本里错位。
- **行内比对**：变更块内的所有行先拼成词序列，跨行做一次 LCS，因而「同一段话两边换行位置不同」不会被误判成整段替换；单块规模超过 60 万格时降级为公共前后缀比对，避免卡死。
- **词法切分**：中文按单字、英文/数字按词（保留 `U.S.`、`don't` 这类内部标点）、标点与空白单独成词。
- **图片指纹**：把 docx 里的图片读成 base64 后做 SHA-256（优先 WebCrypto，`file://` 下自动降级为内置纯 JS 实现），再按多重集匹配，得出「一致 / 仅旧版 / 仅新版」。

## 常见问题

**打 Tag 后流水线失败，提示标签格式不正确？**
Tag 必须形如 `v0.0.1`。`v1.0`、`0.0.1`、`v0.0.01` 都不接受，删掉 Tag 重新按规范打。

**部署成功但页面 404？**
Settings → Pages 的 Source 没选 GitHub Actions，或首次部署尚未生效（通常 1 分钟内）。

**扫描版 PDF 比不出内容？**
扫描件没有文字层，提取结果为空。请先用 OCR 工具处理，或提供对应的 Word 文件。

**`.doc` 打不开？**
旧二进制格式不支持，用 Word「另存为」转成 `.docx` 即可。

**两份文档完全一样，却提示有差异？**
多半是换行符或空格差异。确认「忽略空白差异」「忽略换行/分段差异」已勾选；Word 的修订痕迹、隐藏文字也可能被算作文本差异。

**图片明明一样还是被标红？**
工具比对的是文件字节内容，同一张图被重新压缩、换编码后指纹就会变——这通常说明图确实被处理过，属于有效提示。PDF 预览不做图片级比对，只能肉眼核对页面。

## 隐私与安全

- 文档在浏览器内存中解析，**不上传、不落盘、不联网**；
- 页面不加载任何 CDN 资源，`lib/` 内的库随页面一起发布；
- 只有「导出比对结果」会通过浏览器下载写一个本地 HTML 文件，内容由你自行保管。

因此请勿在公开场合上传含真实姓名、身份证号、商业条款的示例文档。

## 致谢

[mammoth.js](https://github.com/mwilliamson/mammoth.js)、[PDF.js](https://mozilla.github.io/pdf.js/)、[docx-preview](https://github.com/VolodymyrBaydalka/docxjs)、[JSZip](https://stuk.github.io/jszip/)，以及 diff-match-patch / ClauseDiff 在差异算法上的思路。

## License

[MIT](LICENSE) © Jim Jiang
