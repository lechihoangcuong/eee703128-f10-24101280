# Bằng chứng CI hiện hành của F10

- Repo: https://github.com/lechihoangcuong/eee703128-f10-24101280
- CI: https://github.com/lechihoangcuong/eee703128-f10-24101280/actions/runs/40179312464
- Thời gian UTC: 25/10/2026, 09:06:56–09:10:10.
- Commit thực thi: `b59c838b69c1b35e73c9c9ca8cdcd36c34d7d25f`.
- Commit mã nguồn nộp ổn định trong lịch sử main: `7ae2df482cbf7f316b2eac5e066c0b33ebad88eb`. Đã so sánh đủ 22 tệp RTL/TB/script/workflow/config: cùng blob SHA; bảng đối chiếu ở `metadata/source_comparison.json`.
- Hai job đều success. Hai ZIP được tải trực tiếp từ artifact GitHub và kiểm SHA-256, không phải ZIP tự tạo lại.

| Artifact | ID | ZIP SHA-256 |
|---|---:|---|
| mo-phong-F10 | 12594145562 | `663e8434200b481b7e6689bf4aefa21e282ad929d45260812e2547d7f5a8de38` |
| rtl2gds-F10 | 12594120356 | `f0137fd134f5dd3ae257ea00f1f1de9282ef980dc7569ceb3be44b0367175fe9` |

Kết quả: lõi 1035 ca / 1665218 phép kiểm / 0 lỗi; wrapper 11 ca / 708 phép kiểm / 0 lỗi. Các metrics, GDS và log được trích nguyên byte trong `selected/`. Kết quả đối chiếu với bằng chứng cũ nằm ở `verification.json`; phân tích vật lý ở `PHYSICAL_ANALYSIS.md`.

Nguồn cũ `run-39390858919` được giữ để tra cứu lịch sử; link run cũ hiện trả 404, nên báo cáo hiện hành dẫn run 40179312464. Việc sửa lịch sử commit không phải bằng chứng về thời gian phát triển gốc hay tác giả độc lập, và không tạo ra lần chạy CI mới.
