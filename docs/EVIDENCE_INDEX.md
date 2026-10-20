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

Các tệp `summary.json`, mã thoát, hash nguồn, `tool_versions.txt` và log phải đọc cùng nhau. Không dựa riêng vào dòng “PASSED”. Tổng số 22 FF trong lần tổng hợp generic này gồm count 8, timeout chốt 8, state quan sát 4, DONE 1, TIMEOUT 1; wrapper thêm một AND không thêm FF. Không suy số FF chỉ từ số trạng thái.

Các mutation FAIL có chủ ý được giữ riêng trong thư mục làm việc gốc, không trộn vào PASS của thiết kế bàn giao. Đây không phải số liệu code coverage hay formal proof. Sweep đủ 256 N cho bốn kịch bản deadline đã định nghĩa, chưa duyệt mọi chuỗi input có thể có.

GDS, mapped Sky130 area, slack/corner, power, DRC/LVS và link CI đang **chưa có** tại lúc tạo gói. Không thay chúng bằng số 0 hoặc lấy số trong tài liệu cũ. Khi CI chạy, thêm URL và tải artifact thật rồi cập nhật phân tích.
