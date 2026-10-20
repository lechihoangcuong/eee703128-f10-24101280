# F10 — FSM bắt tay bốn pha req/ack

**Sinh viên:** Lê Chí Hoàng Cường · **MSSV:** 24101280  
**Lớp:** Nhập môn thiết kế vi mạch tích hợp-1-1-26(N01)

Đây là gói làm việc có hỗ trợ AI từ tài liệu F10 được cung cấp. Lõi RTL giữ nguyên mã nguồn. Wrapper, testbench tự kiểm tra, script, hình và phần giải thích được bổ sung hoặc kiểm tra với trợ lý. Không mô tả toàn bộ mã này là do sinh viên tự viết. Sinh viên cần tự chạy, đọc bằng chứng và giải thích được hành vi trước khi nộp.

## Bắt đầu trên Ubuntu/WSL

Cần `iverilog`, `vvp`, `python3`, `timeout`, `yosys`; `verilator` và `gtkwave` tùy chọn. Mở terminal Ubuntu, vào thư mục kho đã tải/giải nén rồi chạy:

```bash
bash scripts/run_sim.sh
bash scripts/run_synth.sh
python3 scripts/preflight_physical.py
gtkwave evidence/local/simulation/core/f10_core_selfcheck.vcd
```

Script tự tìm thư mục gốc từ vị trí của nó, không phụ thuộc đường dẫn máy tác giả. Mỗi testbench có top riêng; không biên dịch hai TB cùng lúc như hai top tự chạy. Mô phỏng có watchdog hữu hạn và mã thoát lỗi thật. Checker kiểm CSV/số case/số check thay vì chỉ tìm chữ PASS.

Kết quả mới ghi vào `evidence/local/` và được Git bỏ qua. `evidence/local-run/` là bản lưu **các lần chạy thật ngày 2026-10-19/20 trên Ubuntu WSL**, không phải các log nhỏ có sẵn trong ZIP đầu vào. Tệp nhị phân mô phỏng `.vvp` không cần nộp.

## Đọc theo thứ tự

1. `docs/CONTRACT_AND_INTERFACE.md`: chân, điều kiện nhận giao dịch, reset, deadline.
2. `rtl/f10_handshake_controller.sv`: lõi gốc.
3. `docs/VERIFICATION_PLAN.md` và `tb/f10_tb_selfcheck.sv`: model độc lập và deadline sweep.
4. `tb/f10_wrapper_tb.sv`: kiểm toàn bộ chân wrapper.
5. `docs/EVIDENCE_INDEX.md`: các log thật và giới hạn.
6. `docs/PHYSICAL_FLOW.md`: cấu hình LibreLane, CI và dữ liệu chưa có.
7. Báo cáo và hướng dẫn học được bàn giao cùng gói này.

## Kết quả đã quan sát

| Phần | Công cụ | Kết quả thật |
|---|---|---|
| Lõi RTL | Icarus 12.0 | 1035 case; 1.665.218 phép check; 0 lỗi |
| Wrapper TT | Icarus 12.0 | 11 case; 708 phép check; 0 lỗi |
| Lõi generic | Yosys 0.52 | 209 cell = 22 FF + 187 tổ hợp; 0 latch |
| Wrapper generic | Yosys 0.52 | 210 cell = 22 FF + 188 tổ hợp; 0 latch |

Đây là mô phỏng và tổng hợp generic. Chưa có số diện tích cell Sky130, slack, công suất, GDS, DRC/LVS hay kiểm thử chip. Chu kỳ 10 ns là điều kiện test/mục tiêu, chưa chứng minh đạt 100 MHz trên silicon.

## CI và điều kiện còn mở

Giảng viên yêu cầu repo cá nhân, lịch sử commit thật và link lần chạy CI. Workflow `.github/workflows/rtl2gds.yml` được điều chỉnh từ mẫu Canvas. Khi chủ tài khoản duyệt việc đưa gói lên GitHub, push sẽ chạy mô phỏng và physical flow. Chưa có repo/CI URL trong gói này; không được điền link giả hoặc gọi việc chép YAML là đã qua Cổng A.

Physical job giữ log kể cả khi hỏng. Nếu chưa có sản phẩm cuối, nộp log lỗi thật và phân tích theo yêu cầu giảng viên; không chuyển trạng thái lỗi thành thành công. Cần kiểm hướng dẫn nộp chính thức, quyền giảng viên xem repo riêng tư và quy định sử dụng AI.

**Giả định giao diện cần rà soát với giảng viên:** `uio_in[1]` dùng START, giữ nguyên ACK ở bit 0 và timeout đủ 8 bit. Charter chưa chốt chân START. Khối triển khai là requester; phía đáp ứng ACK được mô hình hóa trong TB. Không tự nhận giảng viên đã duyệt hai cách diễn giải này.


## Báo cáo và bài học

- [Hướng dẫn học từ đầu và22câu vấn đáp](docs/F10_HUONG_DAN_HOC_VA_BAO_VE.md).
- [Đối chiếu24yêu cầu](docs/F10_REQUIREMENTS_AUDIT.md).
- [Báo cáo làm việc14trang](reports/F10_24101280_BAO_CAO_BAN_LAM_VIEC.pdf).
- [Phụ lục mã17trang](reports/F10_24101280_PHU_LUC_MA_NGUON.pdf).
- [Bản văn bản để chỉnh sửa](reports/F10_24101280_BAO_CAO_BAN_LAM_VIEC.md).

Kiểm thêm deadline hai pha và giới hạn đối tác: `bash diagnostics/contract_bounds/run.sh`. Thử sức bắt lỗi của checker: `bash scripts/run_mutations.sh`. Tất cả chạy được từ repo; giữ riêng các log FAIL có chủ ý.

Không đồng nhất “có đủ tệp” với “đã hiểu và đã đạt mọi tiêu chí”. Cổng A và physical cần CI thật; phần waveform và22FF phải tự giải thích được trước khi nộp.
