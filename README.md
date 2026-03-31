# 🏭 Production Market

## 🏆 Built for PL_Genesis Hackathon

This project is officially submitted to the **PL_Genesis: Frontiers of Collaboration** hackathon (Existing Code Track). 

### 🔧 Sponsor Track Integrations:
1. **Ethereum Foundation: Agents With Receipts (ERC-8004)**
   - **How it's used**: The agent operates as a verifiable economic actor on-chain. We use ERC-8004 to build reputation history and enable trust-gated collaboration.
   - **Verification**: BaseScan TX Hash `0x5ac76bdded080bfe865ee5c04aa33b566eb00d5a1f0c04e8945171732a3ce893`
2. **Protocol Labs: AI & Robotics**
   - **How it's used**: Fully autonomous generation of Proof of Complexity (PoC) using AI robotics engine.

> **A positive-sum alternative to prediction markets for hardware innovation.**

Instead of betting on news outcomes, AI agents and humans co-create, simulate, fork, and remix hardware designs — each micro-transaction triggers on-chain royalty distribution to all upstream contributors. Failed crowdfunding? **Automatic refund.** No platform discretion, just code.

**→ Prediction Market: Zero-sum. Wrong = lose all.**  
**→ Production Market: Positive-sum. Wrong = auto-refund. Right = passive royalties forever.**

---

## 🌾 CROPS Compliance

| Constraint | How We Meet It |
|------------|---------------|
| **Censorship Resistance** | Deployed on Ethereum Sepolia Testnet (`0x9B047F592fa49014b32C1778D22eB720637fBAeB`). Anyone can CREATE/FORK/REMIX designs. No whitelists, no gatekeepers. Remove any intermediary and the protocol still works. |
| **Open Source** | Protocol layer is 100% open source. The simulation engine is pluggable — anyone can implement their own arbiter. Smart contracts are auditable on BaseScan. |
| **Privacy** | Design files are stored on IPFS; only the content hash goes on-chain. Users control what to reveal. Complexity scores are computed off-chain and committed as hash proofs — the algorithm stays private. |
| **Security** | Escrow auto-refunds on failed crowdfunding. Contracts are auditable. If the team disappears, the protocol runs forever. Users are never trapped. |

---

## 🎯 Design Thinking: User-Centered Journey

### The Problem (Empathize)
Traditional hardware development has **n⁹ difficulty** (Process n³ × Skillset n³):
- **Process**: Idea → Prototype → Product (each step exponentially harder)
- **Skills**: 3D Design + Electronics + Code (all three required simultaneously)
- 99% of hardware ideas die in this "Valley of Death" because no one is incentivized to do the hard prototyping work.

### The Insight (Define)
> "Markets as knowledge discovery." — Hayek  
> "Hedging real-world risk." — Vitalik

What if we could **incentivize every step** from idea to prototype, not just the final product? What if every design contribution earned immediate, automatic rewards?

### The Solution (Ideate)
**Proof of Complexity (PoC)** — a Bittensor-inspired incentive mechanism for hardware design:

```
Design Complexity = MoC_Score × Integration_Score × Logic_Score = n³

Each dimension is measurable:
  MoC (Chain of Mechanics): transmission chain depth (Motor → Gear → Axle → Output)
  Integration: I/O combinations (actuators × sensors × modules)  
  Logic: control states × behaviors × feedback loops

Higher complexity = more valuable design = higher royalties
```

### The UX (Prototype)

**Three Key UX Moments:**

| Stage | Experience | Emotion |
|-------|-----------|---------|
| **Lead-In** | User faces n⁹ difficulty wall. Opens UI, types: *"A robotic arm"*. Drags MK Smart Cubes onto canvas. | Curiosity + low barrier |
| **Hero Moment** ✨ | Screen lights up — instant live 3D simulation! Lego-style bricks synchronize with motors and sensors. **It moves!** | *"THIS IS AMAZING!"* — the 10x signal |
| **What's Next** | Design goes on-chain. Others fork it. Automatic royalties flow. Crowdfund → Manufacture → Ship → Earn forever. | Empowerment + passive income |

### Validation (Test)
- Physical kit assembly verifies the digital simulation
- On-chain fork/remix count validates market demand
- Royalty accumulation proves economic viability

---

## 🔗 How It Works On-Chain

### Core Operations

```
CREATE  → Register new original design       → $0.10 fee → platform
FORK    → Copy & modify someone's design      → $0.05 fee → 5% royalty to parent
REMIX   → Recombine parts from many designs   → $0.01 fee → split royalty to all sources
```

### Proof of Complexity (n³ On-Chain)

Every design carries intrinsic complexity metrics computed off-chain:

```solidity
struct Design {
    // ... core fields ...
    uint8   structureScore;    // 3D: parts, joints, DOF, transmission depth
    uint8   electronicScore;   // I/O: actuators, sensors, cubes  
    uint8   logicScore;        // Code: states, behaviors, feedback loops
    uint32  complexityScore;   // structure × electronic × logic (the n³)
    bytes32 metricsHash;       // hash(scores + algorithm version) for verification
}
```

**The complexity algorithm is proprietary (off-chain). The scores are transparent (on-chain). Anyone can verify via hash. No one can reverse-engineer the algorithm.**  
*Like Google open-sourcing Chrome but not PageRank.*

### Proof Chain (Ledger-in-Ledger)

Each design maintains its own **proof chain** — a linked list of verification steps:

```
ProofBlock {
    prevHash:   bytes32    // links to previous proof (chain!)
    proofType:  uint8      // 1=PoM, 2=PoSim, 3=PoI, 4=PoP
    dataHash:   bytes32    // this step's data hash
    timestamp:  uint256
}

Design #42 Proof Chain:
  [Genesis] → [PoM: chain_length=7] → [PoSim: constraints_passed=3/3] → [PoI: IO_count=5]
     ↑              ↑                         ↑                              ↑
  prevHash=0x0   prevHash=genesis         prevHash=PoM                  prevHash=PoSim
```

**Every design has its own mini-blockchain of proofs. Immutable, ordered, verifiable.**

### Proof Levels

| Level | Proof | What It Proves | How to Earn |
|-------|-------|---------------|-------------|
| 1 | **Proof of Mechanism (PoM)** | "Transmission chain exists and is connected" | Others fork your structure → **royalties** |
| 2 | **Proof of Simulation (PoSim)** | "Physics validates it works" | Simulation passes → **unlocks crowdfunding** |
| 3 | **Proof of Integration (PoI)** | "Electronics + structure + code work together" | More I/O = higher complexity → **higher fork price** |
| 4 | **Proof of Production (PoP)** | "It was actually manufactured and shipped" | Product sells → **perpetual revenue share** |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│  User / Agent                                   │
│  "I want a robotic arm that can pick up cups"   │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  Design Engine (Off-Chain, Proprietary)         │
│  - Chain of Mechanics (CoM) inference           │
│  - Physics simulation (GenSolver)               │
│  - Complexity scoring                           │
│  Output: designFile + complexityScore + hash    │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  Production Market Protocol (On-Chain, Open)    │
│  - ProductionMarket.sol on Base                 │
│  - CREATE / FORK / REMIX with auto-royalties    │
│  - Proof Chain (PoM → PoSim → PoI → PoP)      │
│  - Escrow for crowdfunding (Arkhai Alkahest)    │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  Storage & Identity                             │
│  - IPFS/Filecoin for design files               │
│  - ERC-8004 for agent identity & reputation     │
│  - ENS for human-readable agent names           │
└─────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

```bash
# Install
npm install

# Compile
npx hardhat compile

# Test
npx hardhat test

# Deploy to Base Sepolia
npx hardhat run scripts/deploy.js --network baseSepolia
```

---

## 📁 Project Structure

```
production-market/
├── contracts/
│   └── ProductionMarket.sol    # Core protocol (CREATE/FORK/REMIX + n³ complexity)
├── scripts/
│   └── deploy.js               # Deployment script
├── test/
│   └── ProductionMarket.test.js # Full test suite
├── examples/
│   ├── simple_gear_train.json  # Example: 3-step gear train (structure only)
│   ├── motorized_arm.json      # Example: 4-DOF arm with I/O
│   └── agent_workflow.js       # Example: Agent creates design end-to-end
├── docs/
│   └── proof_of_complexity.md  # Full PoC whitepaper
└── README.md                   # This file
```

---

## 🆚 Why Not Prediction Market?

| | Prediction Market | Production Market |
|---|---|---|
| **Outcome** | Zero-sum betting | Positive-sum creation |
| **On wrong** | Lose everything | Auto-refund |
| **On right** | One-time payout | Perpetual royalties |
| **Produces** | Nothing physical | Real hardware products |
| **Validation** | Human opinion | Physics simulation (objective) |
| **Agent role** | Place bets | Design, simulate, fund, manufacture |

---

## 🏆 Hackathon Tracks

This project is submitted to the following tracks:

- **Synthesis Open Track** — Core submission
- **Arkhai: Applications** — Alkahest escrow for crowdfunding
- **Arkhai: Escrow Ecosystem Extensions** — AI simulation as arbiter
- **EigenCompute** — Verifiable simulation in TEE
- **ERC-8004: Agents With Receipts** — Agent identity #29549
- **Filecoin** — Decentralized design file storage
- **Let the Agent Cook** — Fully autonomous design agent

---

## 📜 License

MIT — Protocol layer is fully open source.  
Design engine (CoM/GenSolver) is proprietary.

---

*Built at The Synthesis Hackathon 2026 by Wu Xi*  
*Agent: MakerKit (#29549) | Harness: Gemini | Model: gemini-2.5-pro*
