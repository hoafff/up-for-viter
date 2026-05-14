# v7 tail-pruned safe Viterbi

This version keeps the Viterbi architecture: branch metric, ACS, survivor decisions, and traceback.
It does **not** use syndrome decoding or a lookup table.

Changes from v6:

- Still 2-cycle architecture for post-layout timing margin.
- Stage 0..5: normal hard-decision Viterbi ACS.
- Stage 6..7: tail-pruned terminated Viterbi ACS. Since the official lab frames use two tail-zero bits and final state 00, only input=0 branches are legal in the last two trellis stages.
- Traceback still starts from final state 00.
- Input lower byte is still registered, so the input frame is sampled on `en`; no external hold-time protocol assumption is added.

Expected effect versus v6:

- Lower combinational count and switching power.
- Better timing margin than the one-cycle v4 implementation.
- Same public interface and same latency as v6: `o_done` after 1 cycle.
