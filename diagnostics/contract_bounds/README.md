# F10 — chẩn đoán bổ sung về giới hạn và giả định đối tác

Thực chạy riêng bằng Icarus Verilog 12.0, Ubuntu WSL, ngày 20/10/2026. Lõi RTL không sửa. Bộ kiểm chứng gốc **1.035 ca giữ nguyên**; không cộng các thí nghiệm này vào kết quả của bộ đó.

## Câu hỏi cần giải quyết

1. Khi ACK đến đúng hạn cuối của **cả hai** pha chờ, độ trễ từ cạnh nhận start đến cạnh phát done có đạt `2×max(1,N)+1` chu kỳ không?
2. RTL có tự phát hiện ACK hạ trước khi requester hạ req không?

Mỗi input được đổi tại cạnh xuống. Output được so với giá trị cụ thể sau cạnh lên 1 ns để đợi cập nhật nonblocking. Chu kỳ clock là 10 ns. Checker theo dõi riêng thời điểm cạnh req/ack; báo cáo đo độ trễ giữa hai **cạnh clock**, không tính thêm độ trễ 1 ns của checker.

## Kết quả đo thật

| Thí nghiệm | Nhận start → done (ns) | Số chu kỳ | Phân loại |
|---|---:|---:|---|
| Hai deadline, N=0 | 35 → 65 | 3 | Đối tác hợp lệ |
| Hai deadline, N=1 | 85 → 115 | 3 | Đối tác hợp lệ |
| Hai deadline, N=255 | 135 → 5245 | 511 | Đối tác hợp lệ |
| ACK hạ sớm, N=8 | 5265 → 5295 | 3 | **OBSERVED_UNSUPPORTED_PEER**, không phải PASS giao thức hợp lệ |

Ca N=255 có các cạnh thực: `req↑135`, `ack↑2680`, `req↓2695`, `ack↓5240`, `done↑5245` ns. ACK lên được lấy mẫu tại 2685 ns: đúng cạnh chờ thứ 255 của pha đầu. Sau khi req hạ, ACK xuống được lấy mẫu tại 5245 ns: đúng cạnh chờ thứ 255 của pha về. Kết quả này đo trực tiếp giới hạn 511 chu kỳ, bổ sung cho sweep gốc chỉ kéo dài từng pha riêng.

Ở ca đối tác không hợp lệ: `req↑5265`, `ack↑5270`, **`ack↓5280` trước `req↓5285`**, rồi `done↑5295` ns. Lõi chuyển vô điều kiện khỏi ACK_HIGH và sau đó chấp nhận ACK thấp ở WAIT_ACK_LOW. Kết quả xác nhận một giới hạn của lõi: nó không có bộ phát hiện mọi vi phạm thứ tự từ đối tác. Vì vậy phải ghi rõ giả định **đối tác giữ ACK cao cho đến khi thấy req thấp**. Đồng bộ clock chưa đủ để suy ra giả định này. Không coi xung done trong ca sai giao thức là bằng chứng đi đủ bốn pha đúng thứ tự.

Tổng chẩn đoán: **3 ca đối tác hợp lệ + 1 quan sát đối tác ngoài contract; 1.607 check, 0 mismatch**. Compile và mô phỏng đều thoát 0. Mã thoát 0 cho biết thí nghiệm quan sát đúng kỳ vọng; không biến hành vi đối tác ngoài contract thành ca hợp lệ. Cảnh báo thiếu timeunit ở lõi nguồn được giữ trong compile.log; TB có `1ns/1ps` và lõi không dùng toán tử trễ.

## Tái lập và bằng chứng

Từ gốc repo, chạy `bash diagnostics/contract_bounds/run.sh` (hoặc chạy `bash run.sh` trong thư mục này). Cần Icarus/vvp, Python 3 và `timeout`. Kết quả mới ghi vào `evidence/local/contract_bounds`, hoặc `${F10_EVIDENCE_DIR}/contract_bounds` nếu chỉ định. Lần chạy từ gói bàn giao được lưu ở `evidence/portable-validation/contract_bounds`. `run.sh` giới hạn thời gian vvp 10 giây; TB có watchdog 100 us. `summarize.py` đối chiếu năm cạnh ghi ở mỗi dòng CSV với VCD thật và kiểm tra độ trễ bằng timestamp, rồi tạo `summary.json`.

Giữ `f10_contract_bounds_tb.sv`, `run.sh`, `summarize.py`, `simulation.log`, `compile.log`, `diagnostic_cases.csv`, `f10_contract_bounds.vcd`, phiên bản công cụ, lệnh, thời gian UTC, hash nguồn/bằng chứng và mã thoát. Lõi vẫn có SHA-256 `10cca64461908d5cbe1da1d36be07633c613b92f1c2daeff7fd2ba414cccdfe4`.

Đây là ba ca biên bổ sung và một thí nghiệm về giới hạn contract; không phải phủ hết mọi chuỗi input, kiểm phần cứng hay formal proof.
