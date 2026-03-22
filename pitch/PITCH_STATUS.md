# Production Market — Pitch 进展记录
> 最后更新: 2026-03-22 09:38

## 状态: ✅ 定稿 — 可以录屏

---

### Slide 结构 (11页)
| # | 标题 | 图片 | 音频 |
|---|------|------|------|
| 01 | Hook — hardware ideas earn before built | ✅ hardware_prototype.png | pm_slide_01.mp3 |
| 02 | n³ Problem — 3D × Electronics × Code | ✅ hardware_gears.png | pm_slide_02.mp3 |
| 03 | Two Paradigms — Zero-Sum vs Positive-Sum | - | pm_slide_03.mp3 |
| 04 | User Journey — Build → IT MOVES! → Earn | ✅ hero_moment.webp + escrow.png | pm_slide_04.mp3 |
| 05 | How It Works — CREATE / FORK / REMIX | - | pm_slide_05.mp3 |
| 06 | Proof of Complexity — n³ scoring | - | pm_slide_06.mp3 |
| 07 | Proof Chain — PoM → PoSim → PoI → PoP | - | pm_slide_07.mp3 |
| 08 | CROPS Compliance | - | pm_slide_08.mp3 |
| 09 | Architecture — 3-layer | ✅ agent_network.png | pm_slide_09.mp3 |
| 10 | Tech Stack & Tracks (6 partner cards) | - | ❌ (5s auto-skip) |
| 11 | Final — Prediction → Production | - | pm_slide_10.mp3 |

### 截图 (封面图/提交用)
存放: `pitch/screenshots/`
- slide_01.png ~ slide_11.png (共11张)
- 推荐用 slide_01.png 或 slide_11.png 作为项目封面

### 金钱流模型
```
CREATE (设计师上传)
  └→ Gas: < $0.01 (Base L2)
  └→ 设计定价: 创作者自定 ($5-$500)

FORK (他人改进)
  └→ Fork 费: 原价 10-30% → 自动给原设计师
  └→ 支持无限层分润

REMIX (组合多个设计)
  └→ 各原始设计按贡献比例分润

MANUFACTURE (制造商量产)
  └→ 生产许可费: 按 n³ 复杂度计算
  └→ 永续分润: 售价 2-5% 给设计链全员
```

### 技术集成 (Slide 10)
| 集成 | 用途 | 状态 |
|------|------|------|
| ERC-8004 | Agent Identity | ✅ Live on BaseScan |
| Arkhai Escrow | 条件支付 + 分润 | ✅ ProductionMarket.sol |
| Filecoin/IPFS | 设计文件存储 | 设计中 |
| EigenLayer AVS | 物理仿真验证 | 设计中 |
| Base L2 | 低 gas 链上交易 | ✅ 已部署 |
| Let Agent Cook | 自主评估+操作 | ✅ Agent 运行中 |

### 已注册 Tracks (9个)
1. Synthesis Open Track
2. Applications (Arkhai)
3. Escrow Ecosystem Extensions
4. Let the Agent Cook
5. Ship Something Real with OpenServ
6. Agent Services on Base
7. Best Use Case with Agentic Storage (Filecoin)
8. Agents With Receipts — ERC-8004
9. Best Use of EigenCompute

### 已修复 Bug
- [x] 双音频 (stopCurrentAudio)
- [x] Slide 6 卡住 (backup timer + onerror)
- [x] "HOLY F*CK!" → "THIS IS AMAZING!"
- [x] UTF-8 编码损坏 (git restore + Python 修复)
- [x] 模拟鼠标点击动画
- [x] 误导性 gas 费标注 → 改为 value flow 描述

### 录屏步骤
1. `python serve_pitches.py` (端口 8899)
2. 打开 `http://localhost:8899/repos/production-market/pitch/pitch.html`
3. 开始录屏
4. 点 ▶ PRODUCTION MARKET
5. 不碰鼠标键盘 — 全自动
6. 录完约 2-3 分钟

### 提交剩余项目
- [ ] 上传 video → videoURL
- [ ] 设置 coverImage (建议用 slide_01.png)
- [ ] tagline: "Positive-sum hardware market. Every step earns."
- [ ] GitHub push 最新代码
