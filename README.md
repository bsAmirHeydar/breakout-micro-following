# Breakout Micro Following

**MQL5 breakout-following research system with multi-symbol execution, ATR-based risk logic, and modular order/portfolio/time components.**

This repository contains an experimental MQL5 Expert Advisor research system focused on breakout-following behavior. The system scans a configured symbol universe, detects price expansion through recent highs/lows, opens market orders, and manages risk using ATR-derived stop levels and high reward-to-risk targets.

The project is shared as part of a broader portfolio in systematic trading research, MQL5 development, and risk-aware execution logic.

---

## Research Purpose

The purpose of this project is to explore whether short-term breakout behavior can be structured into a systematic execution model with clear entry, stop-loss, take-profit, and trailing behavior.

The repository is not intended to present a guaranteed profitable strategy. It is a research-stage trading system for studying:

- Breakout continuation
- Micro trend-following behavior
- ATR-based stop placement
- Multi-symbol execution loops
- Trailing stop behavior after entry
- Portfolio-level order handling

---

## Trading Logic Summary

The main `run.mq5` Expert Advisor initializes a `strategy` instance for each symbol in the configured universe and calls each strategy on every tick during valid trading time.

The strategy logic in `strategy setting.mqh` includes:

- A recent high/low breakout reference based on a 10-bar window
- ATR calculation using a 14-period ATR
- Buy logic when price reaches or exceeds the recent highest high
- Sell logic when price reaches or falls below the recent lowest low
- Stop-loss distance based on approximately `2 * ATR`
- Take-profit logic using a large asymmetric payoff target
- Trail logic after price moves in favor of the position
- Reset logic when no open orders remain in the relevant direction

---

## Main Files

| File | Purpose |
|---|---|
| `run.mq5` | Main Expert Advisor entry point; initializes symbols and calls strategy logic. |
| `strategy setting.mqh` | Core breakout strategy class, entry logic, ATR stop placement, and reset logic. |
| `order.mqh` | Order creation, closing, counting, trailing, and execution utilities. |
| `portfolio.mqh` | Portfolio and position-sizing/risk-management utilities. |
| `time.mqh` | Trading-session and close-time control. |
| `volatility.mqh` | Volatility-related helper logic. |
| `draw.mqh` | Chart visualization utilities. |
| `regim.mqh` | Regime-related logic or placeholders for regime-aware filtering. |

---

## Architecture

```text
run.mq5
 ├── time.mqh
 ├── strategy setting.mqh
 │    ├── draw.mqh
 │    ├── order.mqh
 │    └── volatility.mqh
 ├── order.mqh
 └── portfolio.mqh
```

The design separates execution orchestration, strategy logic, order handling, portfolio/risk logic, timing rules, volatility helpers, and chart utilities.

---

## How to Use

1. Open MetaTrader 5.
2. Copy the `.mq5` and `.mqh` files into the relevant `MQL5/Experts` or project folder.
3. Open the project in MetaEditor.
4. Compile `run.mq5`.
5. Attach the Expert Advisor to a chart in Strategy Tester or visual testing mode.
6. Configure symbols, timeframes, and risk parameters inside the strategy/config files.

---

## Research Notes

This project is best evaluated through visual backtesting and robustness testing across:

- Different symbols
- Different timeframes
- Different volatility regimes
- Different ATR multipliers
- Spread and execution assumptions
- Out-of-sample periods

---

## Status

Experimental research-stage project.

---

## Disclaimer

This repository is for research and educational purposes only. It is not financial advice and does not provide trading recommendations.
