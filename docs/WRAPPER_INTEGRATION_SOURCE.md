# Tích hợp Tiny Tapeout của bản làm việc

`f10_tiny_tapeout_top` đã thay wrapper cũ nối clock/reset hằng số bằng wrapper có đủ tám cổng chuẩn. Lõi `f10_handshake_controller` được giữ nguyên. Alias `tt_um_24101280_f10` chỉ đổi tên top để kết nối template, không thêm trạng thái.

| Cổng | Vai trò |
|---|---|
| `clk`, `rst_n` | Truyền trực tiếp vào lõi; reset đồng bộ mức thấp |
| `ui_in[7:0]` | Giá trị timeout đủ 8 bit |
| `uio_in[0]` | ACK |
| `uio_in[1]` | START — lựa chọn tích hợp đang dùng |
| `uio_in[7:2]` | Không sử dụng |
| `ena` | Chỉ cho phép START mới; không dừng clock hoặc đóng băng FSM đang bận |
| `uo_out[0]` | REQ |
| `uo_out[1]` | DONE |
| `uo_out[2]` | TIMEOUT |
| `uo_out[6:3]` | Mã trạng thái 4 bit |
| `uo_out[7]` | 0 |
| `uio_out`, `uio_oe` | 0; các chân hai chiều dùng làm đầu vào |

**START trên `uio_in[1]` là giả định triển khai**, dựa trên phương án 2 được chính `functional_spec.md` của gói nguồn liệt kê. Charter chỉ nêu ACK và timeout, chưa chốt nguồn START. Không được nói giảng viên đã phê duyệt ánh xạ bổ sung này. Phương án giữ nguyên đủ 8 bit timeout và các chân đã nêu trong charter; cần giảng viên xác nhận trước khi coi giao diện cuối cùng đã chốt.

ACK/START/timeout phải ổn định theo clock hoặc đã được đồng bộ ở bên ngoài. Wrapper không thêm bộ đồng bộ CDC; các kết quả mô phỏng RTL không chứng minh miễn nhiễm metastability.

Từ thư mục gốc `work/F10`, chạy:

```bash
bash 04_IMPLEMENTATION/scripts/run_wrapper_sim.sh
bash 04_IMPLEMENTATION/scripts/run_generic_synth.sh
```

Log, lệnh thực hiện, mã SHA-256 và exit code được lưu tại `05_VERIFICATION/runs/wrapper` và `06_GDSII/generic`. Các phép kiểm wrapper có expected cụ thể theo giao thức; không lấy đầu ra của chính DUT làm expected. Tổng hợp generic của lõi và TT top tách riêng để tránh lẫn số liệu lõi với số liệu tích hợp. Kết quả generic không cung cấp diện tích Sky130, STA, công suất hoặc GDS.

Kịch bản generic loại `$scopeinfo` (siêu dữ liệu phân cấp của Yosys sau flatten) trước khi thống kê. Đây không phải cổng logic. Lint Verilator dùng `-Wno-fatal` để lưu cả cảnh báo: tham số `START_INTERNAL` của lõi nguồn chưa được sử dụng. Cảnh báo này được ghi nhận, không che bằng cách sửa lõi; exit 0 của lint không đồng nghĩa không có cảnh báo.

## Kết quả đã chạy trên bản này

Icarus Verilog 12.0: **11 ca, 708 kiểm tra, 0 lỗi**, kết thúc tại 1766 ns. Các ca và khoảng thời gian nằm trong `wrapper_cases.csv`; toàn bộ chân đầu ra được kiểm tra không có X/Z sau reset và so với giá trị mong đợi cụ thể. Ca WR11 xác nhận reset đồng bộ giữa hai cạnh, không chỉ reset ban đầu.

Yosys 0.52, tổng hợp generic đã flatten:

| Top | Tổng cell logic/nhớ | Flip-flop | Cell tổ hợp | Latch |
|---|---:|---:|---:|---:|
| `f10_handshake_controller` | 209 | 22 | 187 | 0 |
| `tt_um_24101280_f10` | 210 | 22 | 188 | 0 |

Wrapper thêm một cổng AND cho `ena && START`, không thêm phần tử nhớ. Các cổng gán hằng không cần cell nhớ. Cả hai top có 12 `$_SDFFE_PN0P_` và 10 `$_SDFF_PN0_` trong lần tổng hợp này.

Exit code của mô phỏng, hai lần tổng hợp và lint đều 0. Icarus lưu cảnh báo RTL không khai báo time unit; RTL không có toán tử trễ, còn testbench khai báo `1ns/1ps`. Verilator lưu một cảnh báo `UNUSEDPARAM` cho `START_INTERNAL`. Các log cảnh báo nguyên văn được giữ lại. Số liệu trên không thể thay thế kết quả ánh xạ Sky130 và physical flow chính thức.
