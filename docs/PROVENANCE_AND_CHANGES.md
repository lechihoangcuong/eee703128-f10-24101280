# Nguồn gốc và thay đổi

Nguồn đầu vào: `F10_FSM_bat_tay_bon_pha_req_ack.zip` do người dùng cung cấp. SHA-256 ZIP:

`c2fb74d93be43da5bb6b0c4aff0458ef27d332fbdd611c7b7d6413288764ade3`

Core `rtl/f10_handshake_controller.sv` giữ nguyên byte, SHA-256:

`10cca64461908d5cbe1da1d36be07633c613b92f1c2daeff7fd2ba414cccdfe4`

Không gán giấy phép mới cho mã lớp khi nguồn chưa nêu rõ. Chủ tài khoản đã chọn công khai kho bài làm; sự đồng ý đó không biến tài liệu lớp thành tài liệu có giấy phép mở hoặc cho phép tự tái cấp phép.

## Những gì được bổ sung

| Phần | Thay đổi và lý do |
|---|---|
| Wrapper | Thay bản nối clk/reset/start hằng số bằng đủ tám cổng; truyền clk/reset thật; START tại uio bit 1 là đề xuất tích hợp |
| Alias TT | Top `tt_um_24101280_f10` để nối đúng tên cấu hình; không thêm trạng thái |
| TB core | Model countdown độc lập, directed cases, 4×256 sweep và stress seed cố định; không dùng DUT output để suy expected |
| TB wrapper | So đầy đủ output với expected cụ thể; kiểm ena, bit không dùng, timeout 8 bit và reset đồng bộ |
| Script | Lưu version, hash, command, CSV, log, VCD, exit code; chạy hữu hạn và tách hai top |
| CI | Từ mẫu Canvas, đổi F10/top/config; thêm kiểm wrapper/generic; hai job thật đã hoàn tất thành công, giữ artifact/log/cảnh báo |
| Hình | Vẽ waveform từ VCD mới và mô tả kiến trúc; render2D KLayout từ GDS CI; hình3D định tính từ polygon metal cấp top, giới hạn hình học được ghi rõ |

Tham số `START_INTERNAL` trong core gốc chưa được dùng; lint giữ cảnh báo này. Core không có timeunit, còn TB khai báo `1ns/1ps`; Icarus warning được lưu. Không sửa nguồn chỉ để che cảnh báo.

## Những nhận định nguồn không được sao chép thành kết quả mới

Gói ZIP thiếu các thư mục và log vật lý mà README nguồn nhắc tới. Số106cell, diện tích1019,728µm², timing3ns hoặc công suất từ mô tả cũ không được dùng làm kết quả mới. Báo cáo dùng log local có nhãn riêng và dữ liệu CI thật ngày20/10/2026. Physical mới có mapping133cell/22FF, final454standardcell, GDS, STA, powerước tính, DRC/LVS theo đúng artifact; vẫn còn11pin slewSS và giới hạn SDC/IR.

START pin và phạm vi requester-only vẫn cần rà soát. Có mã chạy PASS không tự giải quyết được yêu cầu đặc tả chưa thống nhất.

## E6 — repo công khai và CI thật

[Repo](https://github.com/lechihoangcuong/eee703128-f10-24101280) đã nhận nguyên lịch sử nguồn. [Run39390858919](https://github.com/lechihoangcuong/eee703128-f10-24101280/actions/runs/39390858919) thực thi source commit `298e12b0f79a326343315beee1697f55e2946403`; các commit cập nhật kết quả sau đó không tự được coi là source đã chạy. Workflow/RTL không bị thay trong lần bổ sung evidence này.

Hai ZIP artifact nguyên byte, metadata, selected raw logs/metrics và SHA256 giữ ở `evidence/github-actions/run-39390858919/`. Đã kiểm16tệp nguồn khác nhau khớp hash của CI. So VCD local/CI cho thấy toàn bộ khai báo/sự kiện trùng sau khi chỉ chuẩn hóa date/version; không đổi nhãn log local thành CI. Xem `CI_EVIDENCE.md`, `waveform_comparison.json` và `PHYSICAL_ANALYSIS.md` trong bản lưu đó.

## Tài liệu yêu cầu

- Charter F10 gốc `p_charter_F10.html`, do người dùng cung cấp.
- [Hướng dẫn chung Canvas](https://canvas.phenikaa-uni.edu.vn/courses/30065/files/4677304?module_item_id=440828): repo cá nhân, lịch sử thật, link CI, báo cáo.
- [Mẫu CI Cổng A Canvas](https://canvas.phenikaa-uni.edu.vn/courses/30065/files/4677309?module_item_id=440833): workflow gốc lưu trong `docs/course-reference/`.
- Gói hướng dẫn v2.4 có phần coi CI/GDS là mở rộng; đã ưu tiên hướng dẫn Canvas và charter F10 cụ thể, không dùng khác biệt này để tự bỏ Cổng A.

Lịch sử commit lưu các thay đổi theo thời điểm thực hiện. Source commit của CI được ghi riêng để đối chiếu mã đã chạy với các cập nhật tài liệu và bằng chứng sau đó.
