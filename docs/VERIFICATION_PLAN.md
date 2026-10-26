# Ma trận kiểm chứng đang áp dụng

Clock TB 10 ns, `1ns/1ps`. TB lái input ở cạnh xuống, lấy mẫu/check sau cạnh lên 1 ns để chờ nonblocking assignment. Đây là quy tắc của TB, không phải trễ phần cứng đo được. Reference core dùng countdown và trạng thái riêng; không đọc output hay trạng thái DUT để suy expected.

| ID/nhóm | Stimulus | Checker và yêu cầu |
|---|---|---|
| TC00_RESET | Reset và IDLE | Mọi output/state bằng 0 sau cạnh lên reset |
| TC01_NORMAL | ACK đúng bốn pha, N=8 | REQ↑, ACK↑, REQ↓, ACK↓ rồi DONE; không timeout |
| TC02_DELAYED_SUCCESS | Chờ trước ACK lên/xuống | Hoàn tất trước deadline; đúng mã trạng thái từng chu kỳ |
| TC03_NO_ACK | Không ACK lên, N=4 | Timeout tại cạnh kiểm chờ thứ tư, không DONE |
| TC04_ACK_STUCK | ACK lên nhưng giữ cao, N=4 | Timeout pha chờ ACK thấp |
| TC05_BACK_TO_BACK | Hai lần N=2 rồi N=9 | Nhận giao dịch mới cạnh sau DONE; chốt N mới |
| TC06_STALE_ACK | START khi ACK đã cao | Không nhận/xếp hàng START cũ; START mới mới hoạt động |
| TC07_BUSY_START | START và N đổi lúc bận | Không khởi động lại hoặc nạp lại giao dịch đang chạy |
| TC08_LATCH_TIMEOUT | Đổi N thành 0/1/255 khi bận | Deadline vẫn theo N đã chốt |
| TC09_SYNC_RESET | Reset giữa cạnh ở cả bốn trạng thái | Không reset trước cạnh; reset tại cạnh lên kế tiếp |
| 4×256 sweep | Mọi N=0…255: timeout mỗi pha và ACK đúng từng deadline | Deadline chính xác, ACK hợp lệ thắng timeout |
| TC10 stress | 4096 chu kỳ LFSR seed F1002026, 16 reset | Khớp model từng chu kỳ và drain hữu hạn |

Core: 1035 case; so đủ state/REQ/DONE/TIMEOUT, phát hiện X/Z, pulse kéo dài, output đồng thời, mã state sai, busy vượt 512 chu kỳ. Có 1.665.215 check nằm trong các case cộng **3 check tổng kết ngoài case**, tổng 1.665.218. CSV có một dòng SUMMARY riêng, không tính nó như case thứ 1036.

Wrapper: 11 case, 708 check gồm reset, ena=0 chặn START, giao dịch bình thường, timeout không ACK, stale ACK, ena giảm khi bận, bit không dùng, N có bit7, N=0, ACK kẹt cao, reset đồng bộ giữa cạnh. So cụ thể toàn bộ 24 bit output và check X/Z, không lấy output core làm expected.

Mọi check sai gọi `$fatal`/mã thoát lỗi. Script còn kiểm số case, tổng check, log/CSV và PASS marker để loại lần chạy dở dang. Chỉ call PASS sau khi hoàn thành toàn bộ tập đã định nghĩa. Không đo code coverage hoặc chứng minh mọi chuỗi giao thức.

Peer phải giữ ACK cao đến khi thấy REQ hạ. Stress có thể phát input không đúng thứ tự giao thức để kiểm hành vi RTL đã định nghĩa; nó không chứng minh peer tuân thủ giao thức. Lõi không phát hiện mọi vi phạm của peer. CDC, gate-level, STA, P&R, DRC/LVS và phần cứng nằm ngoài các kết quả mô phỏng này.

Tái hiện bằng `bash scripts/run_sim.sh`; dữ liệu mới tại `evidence/local/simulation/`. Xem `EVIDENCE_INDEX.md` để phân biệt bản lưu trước và lần chạy từ repo đóng gói. Các tệp có hậu tố `_SOURCE.md` là bản chụp ghi chú ở layout làm việc cũ, đường dẫn trong chúng cần quy đổi sang layout repo này; dùng tài liệu hiện tại để chạy.
