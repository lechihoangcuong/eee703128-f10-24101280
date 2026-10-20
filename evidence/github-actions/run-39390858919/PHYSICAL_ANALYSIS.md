# F10 — phân tích artifact vật lý đã chạy thật

Nguồn duy nhất cho số liệu bên dưới là artifact `rtl2gds-F10` của [run 39390858919](https://github.com/lechihoangcuong/eee703128-f10-24101280/actions/runs/39390858919), source commit `298e12b0f79a326343315beee1697f55e2946403`, tag `RUN_2026-10-20_08-07-12`, ngày 20/10/2026 UTC. Không lấy số cũ trong tài liệu mẫu. JSON đối chiếu chi tiết: `physical_analysis.json`.

## Kết luận được phép ghi

Flow hoàn tất và xuất GDS thật. Không ghi nhận lỗi setup/hold tại 9 corner đã phân tích; Magic DRC, KLayout DRC, routing DRC và Netgen LVS đều báo 0 lỗi trong cấu hình/deck đã chạy. **Vẫn còn 11 pin vi phạm max slew tại mỗi corner SS**, vì vậy chưa được gọi thiết kế đã hoàn tất mọi ràng buộc hoặc đạt signoff. CI xanh phản ánh flow/checker hiện hành hoàn tất; riêng checker max slew đang được cấu hình không làm fail run.

## Công cụ và khả năng tái lập

- LibreLane **3.0.16**, Classic flow, revision `01ddb25e4424f6f5aaf6b951b14a2b6fdcf737c0`.
- PDK **sky130A**, Ciel revision `8afc8346a57fe1ab7934ba5a6056ea8b43078e71`, standard cell `sky130_fd_sc_hd`.
- Bộ công cụ bên trong Nix của job vật lý: Yosys **0.62** (`7326bb7d6641500ecb285c291a54a662cb1e76cf`), Verilator **5.044**, OpenROAD package **2026-02-17**, Magic **8.3.623**, Netgen **1.5.316**, KLayout **0.30.7**. Nix liệt kê OpenSTA `dev`, không in numeric revision; không tự gán version khác.
- Các version này khác job mô phỏng apt và máy WSL; báo cáo cần tách ba môi trường.
- Mã workflow tải LibreLane main và có ghi revision thực tế; muốn tái lập đúng lần này phải checkout revision đã ghi, không chỉ lấy main mới nhất.

## Synthesis và diện tích — phải ghi rõ giai đoạn

| Giai đoạn/đại lượng | Số lượng | Diện tích µm² |
|---|---:|---:|
| Generic wrapper synthesis trong job mô phỏng | 210 cell, gồm 22 FF | Không có library area |
| **Sky130 mapped synthesis — step 06** | **133 cell** | **1383.827200** |
| Trong 133 cell: `sky130_fd_sc_hd__dfxtp_2` | 22 FF | 467.948800 |
| Trong 133 cell: tie / buffer / inverter | 19 / 3 / 3 | 71.318 / 15.014 / 11.261 |
| Các loại còn lại trong mapped synthesis | 86 cell | Phần còn lại |
| **Final nonfill stdcell** (có tap và repair) | **454** | **2162.07** |
| Final filler | 5008 | 18044.8 |
| Final tổng mọi instance | 5462 | 20206.9 |
| Core area | — | 20206.9 |
| Die 160 × 160 µm | — | 25600 |

Nguồn mapped: `06-yosys-synthesis/yosys-synthesis.log` (embedded JSON + stat cuối). Nguồn final: `final/metrics.json`. Không được gọi 5462 là 5462 cổng chức năng hoặc dùng 20206.9 làm logic cell area. 454 đã gồm **286 tap**, **28 timing-repair buffer**, **7 clock-buffer cell**, bên cạnh logic/FF; 5008 filler là lớp vật lý bổ sung. Không đồng nhất die thử nghiệm này với việc đã được TinyTapeout chấp nhận.

22 FF giữ nguyên ý nghĩa lưu trữ 8 bit counter + 8 bit timeout đã chốt + 4 bit state + 1 done + 1 timeout. Không phải `2^4` FF cho bốn state; số FF được xác nhận từ netlist và library mapping.

## Ràng buộc STA đã dùng

`PNR_SDC_FILE` và `SIGNOFF_SDC_FILE` chưa được chỉ định, nên flow dùng **generic fallback `base.sdc`**. `final/sdc/tt_um_24101280_f10.sdc` lưu các ràng buộc đã giải quyết:

- Clock `clk`, **10 ns** = tần số mục tiêu **100 MHz**.
- Clock transition **0.15 ns**, uncertainty **0.25 ns**.
- Input/output delay **2 ns** mỗi phía; đây là giả định giao tiếp trong flow, chưa phải đặc tả board thực.
- Output load resolved **0.033442 pF**; SDC in làm tròn `0.0334` pF.
- Early/late derate **0.95 / 1.05**.
- Max transition **0.75 ns**, max capacitance **0.2 pF**, max fanout **10**.
- Library xác nhận đơn vị thời gian **ns**, capacitance **pF**. Power report ghi rõ **Watts**.

9 corner = ba RC `nom/min/max` × ba PVT `tt_025C_1v80`, `ss_100C_1v60`, `ff_n40C_1v95` (FF nhiệt độ **−40°C**). Prefix min/max ở đây là corner RC, không phải tên phép kiểm tra setup/hold.

## Timing thật, đường tới hạn và CTS

| Chỉ số | Giá trị | Corner |
|---|---:|---|
| Worst **setup slack** | **+1.314871804 ns** | `max_ss_100C_1v60` |
| Worst **hold slack** | **+0.109147250 ns** | `min_ff_n40C_1v95` |
| Setup WNS / TNS | 0 / 0 ns | Tất cả 9 corner |
| Hold WNS / TNS | 0 / 0 ns | Tất cả 9 corner |
| Setup/hold violation count | 0 / 0 | Tất cả 9 corner |
| Nominal TT setup / hold slack | +5.599208811 / +0.313876711 ns | `nom_tt_025C_1v80` |

**Không ghi WNS = +1.314872**: số dương là worst slack (WS); metric WNS chỉ phần âm nên bằng 0 khi không có vi phạm.

Đường setup xấu nhất có trong full log `55-openroad-stapostpnr/max_ss_100C_1v60/sta.log`: `_187_` (Q = `impl.dut.timeout_q[3]`) → OR/AND/OR và logic quyết định counter → delay cell `hold44` → `_197_/D` (Q = `impl.dut.count_q[2]`). Arrival **8.831797 ns**, required **10.146668 ns**, slack **1.314872 ns**. Đây là đường cập nhật counter liên quan giá trị timeout; không suy diễn chỉ là một bộ cộng 8 bit đơn lẻ.

Đường hold xấu nhất: `55-openroad-stapostpnr/min_ff_n40C_1v95/sta.log`: `_198_` (`count_q[1]`) → `_175_` (`o21a_2`) → chính `_198_/D`. Arrival **0.579949 ns**, required **0.470801 ns**, slack **0.109147 ns**. Có các log này trong artifact; không cần nói báo cáo đường timing bị thiếu.

CTS trong `35-openroad-cts/openroad-cts.log`: **22 functional sinks**, tạo **5 tree buffers** (`clkbuf_16`) + **2 dummy loads** (`clkbuf_4`), nên final clock-buffer count **7**; độ sâu cây **2**, **5 clock subnets**. Final hold repair có **8 hold buffers** (nằm trong 28 repair buffers).

Skew phải có tên loại/corner:

- `nom_tt_025C_1v80`: report-clock rise network latency **0.348568–0.392183 ns**, rise skew **0.043615 ns** (43.615 ps); fall skew **0.040043 ns**.
- `max_ss_100C_1v60`: rise network latency **0.617408–0.693113 ns**, rise skew **0.075705 ns** (75.705 ps); fall skew **0.071485 ns**.
- Metric **setup effective skew** ở max-SS = **+0.284643733 ns**, metric **hold effective skew** ở max-SS = **−0.383699278 ns**. Chúng kèm uncertainty/CRPR/derate trong công thức, **khác raw network skew**. TT tương ứng +0.270372732 / −0.325661785 ns.
- Các aggregate `clock__skew__worst_*` trong final JSON không nên gọi “max skew trên mọi corner”; dùng số có corner từ full log như trên.
- Log còn cho `period_min=8.69 ns, fmax=115.14 MHz` tại max-SS. Đây chỉ là ước tính STA theo constraint hiện hành; **nên báo mục tiêu 100 MHz đã kiểm tra**, tránh quảng cáo Fmax đã được phần cứng chứng minh, nhất là khi slew chưa sạch.

## 11 max-slew violations — vấn đề thật phải phân tích

Tại mỗi corner `nom_ss_100C_1v60`, `min_ss_100C_1v60`, `max_ss_100C_1v60`, có **11 pin vi phạm**, không phải 11 net độc lập và không cộng thành 33 net. Pin xấu nhất max-SS `_159_/A`: limit **0.750000 ns**, measured slew **0.933907 ns**, slack **−0.183907 ns**. Các pin còn lại `_158_/A`, `_098_/B`, `_091_/A`, `_151_/C1`, `_147_/C1`, `_149_/C1`, `_141_/C1`, `_137_/C1`, `_139_/C1`, `fanout20/X`.

Đối chiếu final netlist xác nhận **cùng nhánh `net20`**: `rst_n` → `input2` (`sky130_fd_sc_hd__clkdlybuf4s25_1`) → `net2` → `fanout20` (cùng loại delay buffer) → `net20` → 10 receiver pins trên. Pin output driver cộng 10 receivers thành 11. Mạch đang dùng synchronous reset; đường reset vẫn là đường data-control cần giữ setup/hold và transition.

Hướng khắc phục có cơ sở, **chưa chạy thử**: xem lại việc chọn delay-buffer để repair hold trên nhánh reset, chia tải hoặc dùng buffer có drive mạnh hơn ở nhánh này, xem tải/wire ở corner SS; sau đó chạy lại PnR và STA đủ 9 corner, kiểm tra tradeoff hold/setup/area/power và DRC/LVS. Không tự ý nới max-transition hoặc giảm tần số rồi tuyên bố đã chữa: period chậm hơn không tự làm cạnh của net nhanh hơn.

`resolved.json` đang có `MAX_SLEW_VIOLATION_CORNERS: [""]`; step checker ghi cảnh báo, run vẫn pass. Kết luận phải ghi rõ tồn đọng thay vì che bằng màu xanh của CI.

## Power và IR-drop

Report `report_power` ghi đơn vị **Watts**. Đây là **ước tính vectorless**: workflow/config và logs được lưu không nạp workload VCD/SAIF và không in numeric toggle rate/probability. Không được bịa hoạt động 10%/50% hoặc nói công suất đo từ waveform kiểm chứng. Numeric activity assumption chưa được chứng minh riêng từ artifact.

| Report/corner | Internal | Switching | Leakage | Total |
|---|---:|---:|---:|---:|
| Postroute `nom_tt_025C_1v80` | 0.212633 mW | 0.072754 mW | 15.8526 nW | **0.285402 mW** |
| Postroute `max_ff_n40C_1v95` | 0.244362 mW | 0.088937 mW | 19.9538 nW | **0.333319 mW** |

Giá trị `power__total = 0.000333318865 W` trong final JSON **khớp report max-FF**, không phải typical TT; ghi rõ corner nếu dùng. JSON có toàn bộ power từng corner. Tại nominal TT, clock group khoảng **49.2%** power (report **0.140511 mW**), cho thấy clock tree tiêu thụ đáng kể dù FSM nhỏ. Các tỷ lệ này vẫn là ước tính theo activity mặc định của công cụ.

IR-drop nominal TT: worst VPWR **4.15685×10⁻⁵ V** (41.5685 µV), worst VGND **5.39897×10⁻⁵ V** (53.9897 µV). Cảnh báo `VSRC_LOC_FILES` không được cung cấp nghĩa là vị trí nguồn giả định; chỉ dùng để mô tả flow thử nghiệm, không kết luận tính đúng nguồn/package thực. Raw log VPWR average drop **2.74×10⁻⁶ V**; không lấy metric `design_powergrid__drop__average__net:VPWR = 1.8` làm drop (nó mâu thuẫn raw report và rõ ràng là điện áp nguồn).

## Kiểm tra vật lý, GDS và layout

- Final routing DRC **0**; quá trình router sửa 17 → 2 → 0.
- Magic DRC **0**, KLayout DRC **0**, illegal-overlap **0**, streamout XOR **0**.
- Netgen LVS **0 lỗi**; log chốt **“Circuits match uniquely.”** Hai phía sau hợp nhất hierarchy có **172 devices / 202 nets** tương ứng; không gọi đây là cell count tổng hợp.
- Antenna violations **0** theo kiểm tra đã chạy; vẫn có warning 6 unused input pins và 17 constant/output pins thiếu thuộc tính antenna. Critical disconnected pins **0**; disconnected tổng **6** khớp các input không dùng `uio_in[7:2]`. Timing unannotated drivers **27**, sau bộ lọc có **0**; không nói 27 đường chức năng bị mất parasitic mà bỏ qua danh sách/filtered metric.
- GDS chính `final/gds/tt_um_24101280_f10.gds`: **1,187,254 bytes**, SHA256 **`a119d53d1b03022d5e020c8124c052bf89232f74ca09cfd7d6e92021bc30777d`**. Magic GDS trùng hash; KLayout GDS khác bytes nhưng checker XOR **0**.
- **Ảnh layout 2D thật đã có**: `final/render/tt_um_24101280_f10.png`, do step **59 KLayout.Render** tạo. Dùng trực tiếp ảnh này cho báo cáo, caption “ảnh KLayout từ GDS của run …”. Không cần tạo ảnh giả hoặc gọi sơ đồ khối là layout.
- Chưa chạy render vật lý **3D**, chưa fab, chưa board test, chưa đủ cơ sở tuyên bố signoff toàn bộ hoặc được TinyTapeout chấp nhận. DRC/LVS sạch chỉ áp dụng bộ deck, revision và cấu hình trên.

## Bằng chứng nên đưa vào repo/bộ nộp

Giữ ZIP artifact gốc + checksum; ghi run/source SHA; chọn `final/{gds,def,lef,nl,pnl,sdc,spef,sdf,lib,render,metrics.*}`, `resolved.json`, toàn bộ `55-openroad-stapostpnr/*/sta.log`, synthesis log, CTS log, DRC/LVS logs và warning log. Các `.rpt` riêng không nằm trong pattern upload nhưng nội dung report có đủ marker trong `.log`, nên giữ các `.log` ấy và không nói mất kết quả.
