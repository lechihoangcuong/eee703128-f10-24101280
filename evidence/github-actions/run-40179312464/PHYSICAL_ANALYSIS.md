# Phân tích vật lý của CI run 40179312464

Nguồn: [CI ngày 25/10/2026](https://github.com/lechihoangcuong/eee703128-f10-24101280/actions/runs/40179312464), commit `b59c838b69c1b35e73c9c9ca8cdcd36c34d7d25f`.

Các số liệu gốc nằm trong `selected/physical/final/metrics.json` và các log tại `selected/physical/stages/`. Đã đối chiếu 307 khóa metrics với bản lưu run 39390858919. Những khóa thay đổi được ghi đầy đủ trong `verification.json`.

| Chỉ số | Giá trị |
|---|---:|
| Setup WS | 1.3148718042090555 ns |
| Hold WS | 0.10914724988312127 ns |
| Standard cells sau layout, không filler | 454 |
| Diện tích standard cells | 2162.07 µm² |
| Magic DRC / KLayout DRC / LVS | 0 / 0 / 0 |
| Slew tại mỗi góc SS được báo cáo | 11 vi phạm |
| Power tổng trong final metrics | 0.00033331886515952647 W; thuộc corner max-FF |
| SHA-256 GDS hiện hành | `6bb02c420db3967a6b95394187e302c512e116d9a5b9c268b86434cf40f1800a` |

GDS cũ và mới trùng toàn bộ record sau khi bỏ riêng các trường thời gian BGNLIB/BGNSTR. Vì vậy hình layout đã dùng vẫn mô tả cùng hình học. CSV 1.035 ca kiểm tra lõi trùng byte; các ảnh GTKWave vẫn truy về VCD local đã ghi trong báo cáo.

Không đồng nhất job success với việc sạch mọi ràng buộc: còn 11 vi phạm slew ở SS. Công suất là vectorless; chưa kiểm phần cứng, sign-off hoặc chế tạo.
