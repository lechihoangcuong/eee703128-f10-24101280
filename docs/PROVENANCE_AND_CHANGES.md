# Nguồn gốc và thay đổi

Nguồn đầu vào: `F10_FSM_bat_tay_bon_pha_req_ack.zip` do người dùng cung cấp. SHA-256 ZIP:

`c2fb74d93be43da5bb6b0c4aff0458ef27d332fbdd611c7b7d6413288764ade3`

Core `rtl/f10_handshake_controller.sv` giữ nguyên byte, SHA-256:

`10cca64461908d5cbe1da1d36be07633c613b92f1c2daeff7fd2ba414cccdfe4`

Không gán giấy phép mới cho mã lớp khi nguồn chưa nêu rõ. Kiểm quyền chia sẻ trước khi công khai toàn bộ tài liệu lớp.

## Những gì được bổ sung

| Phần | Thay đổi và lý do |
|---|---|
| Wrapper | Thay bản nối clk/reset/start hằng số bằng đủ tám cổng; truyền clk/reset thật; START tại uio bit 1 là đề xuất tích hợp |
| Alias TT | Top `tt_um_24101280_f10` để nối đúng tên cấu hình; không thêm trạng thái |
| TB core | Model countdown độc lập, directed cases, 4×256 sweep và stress seed cố định; không dùng DUT output để suy expected |
| TB wrapper | So đầy đủ output với expected cụ thể; kiểm ena, bit không dùng, timeout 8 bit và reset đồng bộ |
| Script | Lưu version, hash, command, CSV, log, VCD, exit code; chạy hữu hạn và tách hai top |
| CI | Từ mẫu Canvas, đổi F10/top/config; thêm kiểm wrapper/generic; giữ thất bại physical và artifact thật |
| Hình | Vẽ từ VCD mới và mô tả kiến trúc; không giả ảnh GTKWave hay ảnh layout |

Tham số `START_INTERNAL` trong core gốc chưa được dùng; lint giữ cảnh báo này. Core không có timeunit, còn TB khai báo `1ns/1ps`; Icarus warning được lưu. Không sửa nguồn chỉ để che cảnh báo.

## Những nhận định nguồn không được sao chép thành kết quả mới

Gói ZIP thiếu các thư mục và log vật lý mà README nguồn nhắc tới. Số 106 cell, diện tích 1019,728 µm², timing 3 ns hoặc công suất từ mô tả cũ không có log đo mới tương ứng. Báo cáo chỉ dùng số generic/thời gian mô phỏng được chạy lại, và đánh dấu các phần vật lý chưa có.

START pin và phạm vi requester-only vẫn cần rà soát. Có mã chạy PASS không tự giải quyết được yêu cầu đặc tả chưa thống nhất.

## Tài liệu yêu cầu

- Charter F10 gốc `p_charter_F10.html`, do người dùng cung cấp.
- [Hướng dẫn chung Canvas](https://canvas.phenikaa-uni.edu.vn/courses/30065/files/4677304?module_item_id=440828): repo cá nhân, lịch sử thật, link CI, báo cáo.
- [Mẫu CI Cổng A Canvas](https://canvas.phenikaa-uni.edu.vn/courses/30065/files/4677309?module_item_id=440833): workflow gốc lưu trong `docs/course-reference/`.
- Gói hướng dẫn v2.4 có phần coi CI/GDS là mở rộng; đã ưu tiên hướng dẫn Canvas và charter F10 cụ thể, không dùng khác biệt này để tự bỏ Cổng A.

Mọi commit trong gói bàn giao phải phản ánh công việc thực tế tại thời điểm làm; không tạo lịch sử M1…M5 giả hoặc backdate. Trợ lý hỗ trợ tạo/mô phỏng/tổng hợp; sinh viên không nên ký nhận là đã tự làm toàn bộ các thao tác khi chưa thực hiện.
