# F10 — kế hoạch kiểm chứng thực thi của bản làm việc

Phiên bản 1.0 — 2026-10-19. Nguồn được giữ nguyên trong `reference/f10_supplied/`; kế hoạch này kiểm lõi trong bản làm việc, không dùng kết quả mô phỏng đính kèm gói làm bằng chứng mới.

## Contract được kiểm

- Bốn trạng thái quan sát được: `IDLE=0`, `REQ_HIGH=1`, `ACK_HIGH=2`, `WAIT_ACK_LOW=3`.
- Reset đồng bộ, tích cực thấp. Reset chỉ tác động tại cạnh lên; khác reset bất đồng bộ đã học ở Lab 0.
- Chấp nhận giao dịch khi lấy mẫu `start=1 && ack=0` tại IDLE. Không xếp hàng start bị từ chối hoặc start trong lúc bận.
- Chốt cấu hình 8 bit tại lúc nhận giao dịch. Mỗi pha chờ được cấp một ngân sách mới bằng N; N=0 quyết định timeout tại cạnh chờ đầu tiên.
- ACK lên / ACK xuống hợp lệ được ưu tiên hơn timeout nếu cùng xảy ra ở cạnh deadline.
- `done` và `timeout` là các xung một chu kỳ; không cùng bật.
- ACK và các input được coi là đồng bộ với clock, không có X/Z. Không kiểm CDC/metastability bằng RTL zero-delay.

## Checker và quy tắc thời gian

Testbench: `testbench/f10_tb_selfcheck.sv`. Clock 10 ns, `timescale 1ns/1ps`. Input được lái tại cạnh xuống, reference cập nhật từ input lấy mẫu tại cạnh lên, output được kiểm sau cạnh lên 1 ns để đợi nonblocking assignment; stimulus tiếp theo được phép bắt đầu sau 2 ns. Reference dùng bộ đếm số chu kỳ **còn lại**, không dùng bộ đếm tăng giống RTL, không đọc output/trạng thái nội bộ DUT để tính expected.

Mỗi chu kỳ đối chiếu `state`, `req`, `done`, `timeout`; phát hiện X/Z, mã trạng thái ngoài 0..3, kết quả đồng thời, xung kéo dài, req cao ở IDLE, done không đi từ WAIT_ACK_LOW với ACK đã lấy mẫu thấp, giao dịch quá 512 chu kỳ. Giới hạn 512 là chặn bảo thủ cho hai ngân sách 255 chu kỳ và pha trung gian; bound 257 trong tài liệu cũ không đủ.

## Ma trận thực thi

| ID / nhóm | Stimulus | Kỳ vọng và bằng chứng | Nguồn |
|---|---|---|---|
| TC00_RESET | Reset có cạnh clock và nghỉ | Mọi output/state về 0 | Contract reset |
| TC01_NORMAL | N=8; ACK theo đúng bốn pha | Req lên, ACK lên, req xuống, ACK xuống rồi done | Charter ca bình thường; câu phân tích riêng |
| TC02_DELAYED_SUCCESS | Chờ 3 chu kỳ trước ACK lên, 2 chu kỳ trước ACK xuống; N=8 | Hoàn tất trước hạn; không timeout | Charter trả lời chậm |
| TC03_NO_ACK | Không có ACK lên; N=4 | Không timeout sớm ở ba cạnh đầu; timeout cạnh thứ tư | Charter không trả lời |
| TC04_ACK_STUCK | ACK lên nhưng không xuống; N=4 | Timeout đúng cạnh thứ tư ở pha trả về | Bổ sung: đối tác mắc kẹt |
| TC05_BACK_TO_BACK | Hai giao dịch N=2 rồi N=9; giao dịch thứ hai mở ngay cạnh sau done | Cả hai hoàn tất; ngân sách được nạp mới | Charter hai giao dịch liên tiếp |
| TC06_STALE_ACK | Start khi ACK cao rồi ACK về thấp mà không có start mới | Không khởi động hoặc xếp hàng start cũ; start mới hoạt động | Bổ sung: ACK cũ |
| TC07_BUSY_START | Start cao trong cả ba trạng thái bận; cấu hình thay đổi | Giao dịch đang chạy giữ đúng tiến trình; không xếp hàng | Bổ sung: start khi bận |
| TC08_LATCH_TIMEOUT | N=4 đã nhận; thay input thành 0/1/255 khi bận | Cả hai pha chờ vẫn hết hạn theo N=4 | Bổ sung: cấu hình được chốt |
| TC09_SYNC_RESET | Kéo reset thấp giữa hai cạnh lên tại cả bốn trạng thái | Chưa đổi trước cạnh lên; về IDLE tại cạnh lên kế tiếp | Bổ sung: reset khi bận và reset đồng bộ |
| SW_REQ_TIMEOUT_N000..255 | Không ACK lên với mọi N | Deadline chính xác tại pha request | Sweep ca biên và toàn miền cấu hình |
| SW_LOW_TIMEOUT_N000..255 | ACK giữ cao với mọi N | Deadline chính xác tại pha ACK-low | Sweep ca biên và toàn miền cấu hình |
| SW_REQ_PRIORITY_N000..255 | ACK lên đúng cạnh deadline với mọi N | ACK thắng timeout, rồi hoàn tất giao dịch | Sweep ưu tiên ở biên |
| SW_LOW_PRIORITY_N000..255 | ACK xuống đúng cạnh deadline với mọi N | Done thắng timeout | Sweep ưu tiên ở biên |
| TC10_DETERMINISTIC_STRESS | 4096 chu kỳ input đồng bộ, LFSR seed `F1002026`; có reset và thay cấu hình | Mỗi chu kỳ khớp model; drain có giới hạn; không transaction còn chờ | Bổ sung: phối hợp tín hiệu |

Tổng số case phải thực thi: **1035** = 10 case TC00..TC09 + 4×256 sweep + 1 stress. Đây là exhaustive **theo miền N và bốn kịch bản deadline đã định nghĩa**, không phải exhaustive toàn bộ chuỗi giao thức hoặc formal proof.

## Kết quả và cách tái hiện

Thư mục chạy: `05_VERIFICATION/runs/current_core/`. Chạy đúng top `f10_tb_selfcheck` và lõi, không đưa wrapper chưa được kiểm vào kết luận:

```bash
ROOT="$(pwd)"
mkdir -p 05_VERIFICATION/runs/current_core
cd 05_VERIFICATION/runs/current_core
iverilog -g2012 -Wall -s f10_tb_selfcheck -o sim.vvp \
  "$ROOT/04_IMPLEMENTATION/rtl/f10_handshake_controller.sv" \
  "$ROOT/05_VERIFICATION/testbench/f10_tb_selfcheck.sv"
vvp sim.vvp
```

Giữ `compile.log`, `simulation.log`, `case_results.csv`, `f10_core_selfcheck.vcd`, phiên bản công cụ và mã thoát. CSV có một dòng mỗi case với cửa sổ thời gian, số chu kỳ, số phép check, lỗi và PASS/FAIL; cuối có SUMMARY. Chỉ công bố PASS khi simulator thoát 0, 1035 case đã chạy, số check >0, số lỗi và số case lỗi đều bằng 0. Mọi mismatch hoặc watchdog có `$fatal(1,...)`.

VCD là dữ liệu mô phỏng mới dùng để chú thích bốn pha. Các cửa sổ TC01/TC02/TC03/TC04/TC05 và TC09 được ghi trực tiếp trong CSV và log, không lấy từ giản đồ minh họa có sẵn.

## Giới hạn

Kế hoạch này kiểm lõi RTL và timing chu kỳ theo contract. Chưa chứng minh wrapper Tiny Tapeout, gate-level, STA, P&R, công suất, DRC/LVS, hoạt động phần cứng hoặc CDC. Không sử dụng số 106 cell/22 FF hay STA từ gói cũ như kết quả chạy mới.

## Kết quả thực chạy ngày 2026-10-19

Icarus Verilog 12.0 (stable) trong Ubuntu WSL, top `f10_tb_selfcheck`: biên dịch thoát **0**, mô phỏng thoát **0**. Có một cảnh báo timeunit ở **lõi nguồn** vì lõi không khai báo timeunit; testbench có `1ns/1ps`, clock và thời gian stimulus được chốt trong testbench. Không thay RTL để xóa cảnh báo.

| Chỉ số thực đo | Kết quả |
|---|---:|
| Case đã chạy | 1035 |
| Case lỗi | 0 |
| Chu kỳ lấy mẫu | 138571 |
| Phép check đã thực hiện | 1665218 |
| Lỗi checker | 0 |
| Chu kỳ stress | 4096 |
| Reset trong stress | 16 |
| Seed stress | `F1002026` |
| Thời điểm kết thúc | 1385707 ns |
| Dung lượng VCD | 5528040 byte |

`case_results.csv` đã được kiểm tra lại: 1035 ID riêng biệt, mỗi nhóm sweep có đủ 256 cấu hình, tất cả dòng case PASS và không lỗi. `directed_transitions.json` được trích trực tiếp từ VCD cho phần vẽ hình. TC01 có các cạnh thực: req lên 45 ns, ACK lên 50 ns (FSM nhận tại 55 ns), req xuống 65 ns, ACK xuống 70 ns, done lên 75 ns và xuống 85 ns.

Kiểm sức bắt lỗi của checker bằng ba bản sao RTL cố ý lỗi, nằm riêng trong `runs/current_core/mutation_smoke/` (không đưa vào RTL triển khai):

| Bản sao cố ý lỗi | Compile | Mô phỏng | Checker phát hiện |
|---|---:|---:|---|
| Deadline lệch một chu kỳ | 0 | 1 | Có |
| ACK không được ưu tiên tại deadline | 0 | 1 | Có |
| Tự nạp lại timeout từ input khi bận | 0 | 1 | Có |

Đây là ba phép mutation smoke cụ thể để kiểm khả năng phát hiện lỗi của testbench, không phải mutation coverage toàn bộ thiết kế. Log thật và `mutation_smoke/results.csv` giữ đầy đủ lần chạy FAIL có chủ ý; không được trộn các log này với kết quả PASS của lõi gốc.
