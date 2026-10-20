# Chỉ mục bằng chứng

`evidence/local-run/` chứa lần chạy thực ở thư mục làm việc trước khi đóng gói, giữ tên đường dẫn nguồn trong log để truy vết. `evidence/portable-validation/` chứa lần chạy mới từ chính gói bàn giao. `evidence/local/` dành cho người nhận chạy lại; Git bỏ qua đầu ra tự sinh này.

| Bằng chứng | Vị trí | Ý nghĩa |
|---|---|---|
| Core summary/log/CSV/VCD | `evidence/local-run/core/` | 1035 case, 138571 chu kỳ, 1665218 check, seed F1002026, 0 lỗi |
| Wrapper summary/log/CSV/VCD | `evidence/local-run/wrapper/` | 11 case, 708 check, 0 lỗi |
| Generic core | `evidence/local-run/generic/core/` | 209 cell, 22 FF, 187 tổ hợp, 0 latch |
| Generic wrapper | `evidence/local-run/generic/wrapper/` | 210 cell, 22 FF, 188 tổ hợp, 0 latch |
| Lint | `evidence/local-run/generic/lint/` | Exit 0 nhưng có UNUSEDPARAM; exit 0 không có nghĩa không cảnh báo |
| Portable rerun | `evidence/portable-validation/` | Log mới chạy từ layout repo được bàn giao |
| Physical preflight | `evidence/portable-validation/physical-preflight/` | Chỉ tra tool/PDK có sẵn; không phải một lần physical flow đã chạy |
| Waveform chú thích | `docs/figures/` | Ảnh và SVG từ dữ liệu mô phỏng, xem manifest |
| GitHub Actions thật | `evidence/github-actions/run-39390858919/` | Hai artifact ZIP nguyên byte; metadata run/jobs; summaries, versions, hash nguồn và physical metrics/log được chọn |

Các tệp `summary.json`, mã thoát, hash nguồn, `tool_versions.txt` và log phải đọc cùng nhau. Không dựa riêng vào dòng “PASSED”. Tổng số 22 FF trong lần tổng hợp generic này gồm count 8, timeout chốt 8, state quan sát 4, DONE 1, TIMEOUT 1; wrapper thêm một AND không thêm FF. Không suy số FF chỉ từ số trạng thái.

Các mutation FAIL có chủ ý được giữ riêng trong thư mục làm việc gốc, không trộn vào PASS của thiết kế bàn giao. Đây không phải số liệu code coverage hay formal proof. Sweep đủ 256 N cho bốn kịch bản deadline đã định nghĩa, chưa duyệt mọi chuỗi input có thể có.

Ngày 20/10/2026 đã có [CI run 39390858919](https://github.com/lechihoangcuong/eee703128-f10-24101280/actions/runs/39390858919) trên commit nguồn `298e12b0f79a326343315beee1697f55e2946403`; hai job thành công. Kết quả local trên đây được giữ đúng nhãn local; CI là lần chạy riêng. Xem `evidence/github-actions/run-39390858919/CI_EVIDENCE.md` và `docs/PHYSICAL_FLOW.md` để đọc GDS, area, STA, power, CTS, DRC/LVS và những vi phạm/giới hạn còn lại. Không dùng số trong tài liệu nguồn cũ thay cho metrics mới.


## Bổ sung E3 và E5, chạy lại từ repo

- E3: `evidence/portable-validation/mutation_smoke/`:3/3 mutant cố ý sai bị phát hiện; mỗi mutant compile0,sim1 và có FAIL/FATAL. Fixture nằm ngoài `rtl/`; script `scripts/run_mutations.sh`.
- E5: `evidence/portable-validation/contract_bounds/`:3ca hợp lệ N0/N1/N255 đo3/3/511chu kỳ;1quan sát ACK hạ sớm ngoài contract;1607check,0mismatch. Năm cạnh ở mỗi thí nghiệm được đối chiếu rawVCD. TB cùng byte với bản trong phụ lục; script `diagnostics/contract_bounds/run.sh`.
- Báo cáo và phụ lục nằm trong `reports/`, được cập nhật từ CI thật. Hướng dẫn học và bảng đối chiếu yêu cầu nằm cùng thư mục docs; đây vẫn là hồ sơ học tập cần sinh viên tự giải thích.

## Đối chiếu nguồn của CI

Đã kiểm 16 tệp nguồn khác nhau trong các `source_sha256.txt` của CI khớp byte với bản bàn giao, gồm RTL, testbench, script và mutant tách riêng. Hash lõi giữ nguyên `10cca64461908d5cbe1da1d36be07633c613b92f1c2daeff7fd2ba414cccdfe4`. Hai ZIP có SHA256 khớp digest GitHub và kiểm CRC không lỗi. `verification.json` ghi lại phép đối chiếu; `SHA256SUMS` bao phủ bản lưu evidence.

CI dùng Icarus 12.0, Yosys 0.33 (`2584903a060`), Verilator 5.020. Không gọi chúng là Yosys 0.52/Verilator 5.032 của máy local. Các tổng generic trùng nhau ở hai môi trường nhưng đó vẫn là hai lần chạy khác nhau. Cảnh báo thiếu timeunit và `START_INTERNAL` không dùng vẫn được giữ trong log; exit 0 không đồng nghĩa không có cảnh báo.

Toàn bộ VCD/netlist/GDS/SPEF/SDF/Liberty và log gốc nằm trong hai ZIP nguyên bản. Thư mục `selected/` chỉ là bản chép byte những tệp tiện đọc; không thay thế artifact gốc. Các commit tài liệu sau run không làm thay đổi source commit mà run đã thực thi.

`waveform_comparison.json` đối chiếu VCD core local với CI: chỉ chuẩn hóa `$date`/`$version`, còn khai báo và toàn bộ sự kiện giống nhau; normalizedSHA256 chung `a130f74a4a05ee784e8585a097e1c04978c95eb085f7ee01a91549b34dd70655`. Vì vậy các cạnh trên hình chú thích từ local được CI lặp lại chính xác, nhưng rawhash vẫn khác và được giữ riêng.
