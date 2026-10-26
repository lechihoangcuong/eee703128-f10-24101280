# F10 — FSM bắt tay bốn pha req/ack

**Sinh viên:** Lê Chí Hoàng Cường · **MSSV:** 24101280  
**Lớp:** Nhập môn thiết kế vi mạch tích hợp-1-1-26(N01)

Đây là bộ hồ sơ kỹ thuật dựa trên tài liệu F10 được cung cấp. Lõi RTL giữ nguyên mã nguồn; bộ hồ sơ bổ sung wrapper, testbench tự kiểm tra, script tái lập, hình minh họa và phân tích kết quả. Các bước chạy và bằng chứng được trình bày dưới đây.

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
6. `docs/PHYSICAL_FLOW.md`: kết quả LibreLane, STA, DRC/LVS và giới hạn.
7. Báo cáo và hướng dẫn học được bàn giao cùng gói này.

## Kết quả đã quan sát

| Phần | Công cụ | Kết quả thật |
|---|---|---|
| Lõi RTL | Icarus 12.0, local và CI | 1035 case; 1.665.218 phép check; 0 lỗi |
| Wrapper TT | Icarus 12.0, local và CI | 11 case; 708 phép check; 0 lỗi |
| Lõi generic | Yosys 0.52 local / 0.33 CI | 209 cell = 22 FF + 187 tổ hợp; 0 latch |
| Wrapper generic | Yosys 0.52 local / 0.33 CI | 210 cell = 22 FF + 188 tổ hợp; 0 latch |
| Deadline bổ sung | Icarus 12.0, CI | 3 ca hợp lệ đo 3/3/511 chu kỳ; 1 quan sát ngoài contract; 1607 check, 0 mismatch |
| Thử phá checker | Icarus 12.0, CI | Bắt 3/3 mutant cố ý sai; log FAIL của mutant được giữ riêng |

Hai job của CI thật ngày 20/10/2026 đã thành công; LibreLane đã sinh GDS và metrics Sky130. Kết quả physical và các giới hạn (còn 11 vi phạm slew, dùng fallback SDC, thiếu vị trí cấp nguồn thực) được đọc riêng trong [PHYSICAL_FLOW.md](docs/PHYSICAL_FLOW.md). Chu kỳ 10 ns là ràng buộc phân tích; chưa phải phép đo tốc độ chip.

## Repo và lần chạy CI đã kiểm

Repo công khai: [lechihoangcuong/eee703128-f10-24101280](https://github.com/lechihoangcuong/eee703128-f10-24101280). Lần chạy đã kiểm: [F10 RTL to GDSII #1](https://github.com/lechihoangcuong/eee703128-f10-24101280/actions/runs/39390858919), ngày 20/10/2026, hai job `success`.

**Mã nguồn thực sự được run này thực thi:** `298e12b0f79a326343315beee1697f55e2946403`. Các cập nhật báo cáo/evidence sau run là commit tài liệu; không gọi chúng là phiên bản đã chạy. [Bản lưu CI](evidence/github-actions/run-39390858919/CI_EVIDENCE.md) giữ nguyên hai ZIP artifact, metadata và SHA256 để tra cứu khi artifact trên GitHub hết hạn. Workflow được điều chỉnh từ mẫu Canvas, giữ mã thoát thật và log kể cả khi flow lỗi.

**Giả định giao diện cần rà soát với giảng viên:** `uio_in[1]` dùng START, giữ nguyên ACK ở bit 0 và timeout đủ 8 bit. Charter chưa chốt chân START. Khối triển khai là requester; phía đáp ứng ACK được mô hình hóa trong TB. Không tự nhận giảng viên đã duyệt hai cách diễn giải này.


## Báo cáo và bài học

- [Hướng dẫn học từ đầu và 22 câu vấn đáp](docs/F10_HUONG_DAN_HOC_VA_BAO_VE.md).
- [Đối chiếu 24 yêu cầu](docs/F10_REQUIREMENTS_AUDIT.md).
- [Báo cáo PDF theo mẫu: 15 trang chính + 1 trang phụ lục tái lập](reports/F10_24101280_BAO_CAO_BAN_LAM_VIEC.pdf).
- [Bản Word có thể chỉnh sửa](reports/F10_24101280_BAO_CAO_BAN_LAM_VIEC.docx).
- [Phụ lục mã](reports/F10_24101280_PHU_LUC_MA_NGUON.pdf).
- [Bản Markdown đồng bộ với báo cáo hiện tại](reports/F10_24101280_BAO_CAO_BAN_LAM_VIEC.md).

Kiểm thêm deadline hai pha và giới hạn đối tác: `bash diagnostics/contract_bounds/run.sh`. Thử sức bắt lỗi của checker: `bash scripts/run_mutations.sh`. Tất cả chạy được từ repo; giữ riêng các log FAIL có chủ ý.

Không đồng nhất “CI xanh” với “đã hiểu và đã đạt mọi tiêu chí”. Repo/CI/GDS đã có bằng chứng thật; còn phải giải thích waveform, 22 FF, phân biệt DRC/LVS với slew, rà soát giả định giao diện và tuân thủ cách nộp của lớp.
