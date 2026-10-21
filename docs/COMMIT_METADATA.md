# Đối chiếu metadata commit

Bản ghi bước cập nhật Committer ngày 21/10/2026: sáu commit được gắn với tài khoản `lechihoangcuong`, dùng địa chỉ noreply của GitHub. Ở bước đó Author, thời gian Author, thông điệp và cây tệp được giữ nguyên. Nhãn Author trên main đã được chuẩn hóa ở bước sau, xem [AUTHOR_LABELS.md](AUTHOR_LABELS.md).

Đổi Committer hoặc parent làm đổi SHA của commit. Bảng dưới chỉ đối chiếu metadata; không phải một lần chạy RTL/CI mới. Mỗi cặp có cùng tree SHA, được kiểm trong `COMMIT_METADATA.json`.

| SHA trước cập nhật | SHA sau cập nhật |
|---|---|
| 6ca92c0c92ade8532923fbc6891e4f8bf5c09633 | a32e07497cc56dd588ddd60ec98423ad92f19f37 |
| 4750b087466c7a90cb2c61df351a8829f1ab3739 | f3f2794ab458c241463e16403706e43e9e925b4b |
| 92c956b36192042a5fc090690f9df29e2f9b245b | 7979eecbf0b3957fa2c3ae16c5c1e61aa443ff89 |
| 298e12b0f79a326343315beee1697f55e2946403 | dc08568419d13467706a64fc63d04df5fcf9e1bc |
| 2cfc5ca5e929dd81cd09bb7c67c6a73e870819be | d1eac97a76a04006bdb7ddfd960ac0cb7c9c606d |
| 52e987d0a4d979d704e3000318fb91b88fc05750 | d43e8a877a89e5e040b189e30d4803c97d092683 |

## Giữ nguồn của lần CI đã chạy

Run `39390858919` thực sự chạy source `298e12b0f79a326343315beee1697f55e2946403`. Mã SHA này được giữ trong báo cáo và bằng chứng; không gán số liệu của run cũ cho SHA mới.

Để tái lập từ repo hoặc ZIP, dùng bundle nguồn CI gốc:

```bash
git clone --branch ci-source-39390858919 evidence/github-actions/run-39390858919/CI_SOURCE_HISTORY.bundle F10_CI_source
git -C F10_CI_source rev-parse HEAD
```

Chạy từ thư mục gốc repo. HEAD của bản clone phải là `298e12b0f79a326343315beee1697f55e2946403`. Bundle giữ nguyên lịch sử của source CI, độc lập với khả năng GitHub giữ các commit không còn trên nhánh main.

Toàn bộ source RTL/TB/scripts/flow/config không đổi trong lần cập nhật này. Source gốc, Author gốc trong bundle và bản ghi CI được giữ nguyên; không gán số liệu CI cho SHA metadata mới.
