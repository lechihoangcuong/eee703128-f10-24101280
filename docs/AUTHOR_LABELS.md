# Nhãn Author trong lịch sử main

Ngày cập nhật: 21/10/2026. Nhãn Author hiển thị trên main được chuẩn hóa thành `Repository maintenance`; Committer là tài khoản `lechihoangcuong`. Nhãn này mô tả vai trò bảo trì kho, không phải một tuyên bố rằng sinh viên tự viết mọi mã nguồn.

Bảy commit trước cập nhật giữ nguyên cây tệp và thời điểm Author. Ba phần mô tả được rút gọn, giữ lại dữ kiện kỹ thuật; các thông điệp khác không đổi. Thời gian Committer là thời điểm ghi lại metadata. Việc đổi metadata và parent tạo ra các SHA mới; không phải một lần kiểm thử hoặc CI mới.

| SHA trước chuẩn hóa nhãn | SHA sau chuẩn hóa nhãn |
|---|---|
| a32e07497cc56dd588ddd60ec98423ad92f19f37 | fccc51eff19e5a6c949547d8d30f7e644c9ad171 |
| f3f2794ab458c241463e16403706e43e9e925b4b | e19f3596c75b1f62cedeb9e00b77c11d7939573f |
| 7979eecbf0b3957fa2c3ae16c5c1e61aa443ff89 | dcd4cc1b1b0558f3d57639d66c63bbcabb156552 |
| dc08568419d13467706a64fc63d04df5fcf9e1bc | 1555f93258169d12a52ffdd3b0c11e632cc6c394 |
| d1eac97a76a04006bdb7ddfd960ac0cb7c9c606d | 38cefd314c07d1f630bc2968a14ba2be82cc35e3 |
| d43e8a877a89e5e040b189e30d4803c97d092683 | 73c2ea78075b9e350663b82a136d0439beaedf3a |
| a0062d7ca84e25f843e11a1eb8e1ef6948cd648f | 92f19489c6537a9c0d5e390ce2d443dc72576d05 |

Các tree SHA và kiểm tra tương ứng được ghi trong `AUTHOR_LABELS.json`. `COMMIT_METADATA.md/json` lưu bước đổi Committer trước đó; không dùng các SHA trung gian này thay cho source thực sự đã chạy CI.

## Source và bằng chứng CI

Lần CI `39390858919` đã thực thi source `298e12b0f79a326343315beee1697f55e2946403`. Bản ghi CI, artifact ZIP và `CI_SOURCE_HISTORY.bundle` giữ nguyên metadata lịch sử của lần chạy đó. Xem `COMMIT_METADATA.md` để clone đúng source CI từ bundle.

Việc chuẩn hóa nhãn trên main không xóa các bản ghi lịch sử trong artifact, bundle sao lưu hoặc URL commit cũ. RTL, TB, scripts, flow, config và các số liệu kỹ thuật không thay đổi.
