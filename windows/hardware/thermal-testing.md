## How to do thermal testing for the CPU/GPU

- **HWiNFO64**: View hardware information and log temperatures over time.
- **Cinebench**: Load the CPU.
- **Unigine Heaven**: Load the GPU.

#### Before either test
  1. Plug in the charger and close other apps.
  2. Open HWiNFO in "Sensors only" mode. Keep this window open for the whole test.
  3. Click the logging button and check that the CSV file is growing.
  4. After new thermal paste or a pad, do one unlogged 10-minute run first.

#### Test the CPU
  1. Start logging in HWiNFO.
  2. In Cinebench, set Minimum Test Duration to 10 minutes.
  3. Click Start next to CPU (Multi Core / Multiple Threads).
  4. When it finishes, stop logging and note the score.
  5. In the log, check: peak CPU temperature, thermal throttling flags,
     and whether clock speed and package power hold steady.

#### Test the GPU
  1. Start logging in HWiNFO.
  2. Open Unigine Heaven with these settings:
      * API: DirectX 11
      * Quality: High
      * Tessellation: Normal
      * Anti-aliasing: x2
      * Full Screen: unticked
      * Resolution: varies per system (my run was 1550×855 windowed)
  3. Click Run and confirm the dedicated GPU is named in the top-right corner.
  4. Let it loop for 10–15 minutes. Press F9 if you also want a score.
  5. Press Esc to exit, then stop logging.
  6. In the log, check: GPU temperature against its thermal limit,
     the thermal and power limit flags, and whether GPU clock and power hold steady.

#### What good looks like
  - A brief spike to the limit in the first minute is normal.
  - After that, temperatures should settle below the limit with no throttling.
  - Scores depend on the CPU/GPU model, so compare against the same model.

#### Sample GPU test output (Dell XPS 15 7590 after new phase-change pad)
| Measure | First 90 seconds | Remaining 11 minutes |
| --- | --- | --- |
| **GPU temperature** | Climbed to 75°C | 73–74°C |
| **GPU hot spot** | 85°C | 83–85°C |
| **GPU power** | Ramping up | 48–50 W |
| **Thermal limiting** | Active for about a minute | None |
| **CPU temperature** | Peaked at 93°C briefly | 71–74°C |
| **CPU throttling** | None | None |
