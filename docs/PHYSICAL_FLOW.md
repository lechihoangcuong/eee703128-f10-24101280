# Physical flow: cấu hình và giới hạn

Workflow được điều chỉnh từ mẫu Canvas của giảng viên, không chạy physical flow trên máy hiện tại. Tệp gốc lưu tại `docs/course-reference/rtl2gds.canvas-original.yml`. Việc chép workflow chưa tạo ra link CI hay sản phẩm GDS.

`config.json` chọn top `tt_um_24101280_f10`, ba tệp RTL tổng hợp được, clock `clk`, chu kỳ mục tiêu 10 ns. Đây là **mục tiêu ràng buộc**, không phải tần số tối đa đã đo. Cấu hình floorplan thử nghiệm 160 × 160 µm và lưới nguồn pitch 30 µm chưa được physical flow xác nhận; không coi đó là diện tích cell, tapeout Tiny Tapeout hoặc cấu hình shuttle được duyệt. Không cần khai báo `PDK_ROOT` cứng theo máy tác giả.

Đã đối chiếu schema với tài liệu chính thức LibreLane ngày 2026-10-20:

- [Design configuration](https://librelane.readthedocs.io/en/latest/reference/configuration.html): JSON, `dir::` và tên tệp RTL.
- [Universal variables](https://librelane.readthedocs.io/en/latest/reference/common_flow_vars.html): top, clock, die area; `PDK_ROOT` truyền qua môi trường/CLI khi cần.
- [Step variables](https://librelane.readthedocs.io/en/latest/reference/step_config_vars.html): `FP_SIZING`, `DIE_AREA`, các tham số PDN.
- [PDK handling](https://librelane.readthedocs.io/en/latest/usage/about_pdks.html): PDK được quản lý bởi LibreLane/Ciel hoặc `--pdk-root`; không suy ra PDK đã cài chỉ vì Yosys có mặt.
- [Official source](https://github.com/librelane/librelane): cách dùng `nix-shell` và `librelane`.

Workflow giữ mã thoát thật qua `pipefail`, lưu revision LibreLane thật và log ngay cả khi thất bại. Không sử dụng `continue-on-error` để biến flow lỗi thành PASS. Đầu ra chỉ được nhận khi có **GDS không rỗng trong final và metrics final**. Script giữ nguyên tên metric và không thay dữ liệu thiếu bằng số 0. Người đọc vẫn phải xem DRC/LVS/slack theo đúng corner và giai đoạn.

Nhánh `main` của LibreLane được lấy theo mẫu lớp và revision thực tế được ghi vào artifact. Kết quả tương lai cần trích revision đó; không hứa kết quả bit-identical qua các bản công cụ khác nhau. Khi flow lỗi, tải artifact, tìm lỗi đầu tiên và mô tả nguyên nhân trước khi sửa. Chưa có lần chạy CI thì ghi **chưa chạy**, không viết “flow thất bại”.
