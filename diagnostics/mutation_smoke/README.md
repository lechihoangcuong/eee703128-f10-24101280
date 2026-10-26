# Ba bản sao cố ý lỗi — không dùng làm RTL triển khai

Ba `mutant_core.sv` được sao nguyên từ các fixture mutation đã tạo trong bản làm việc. Chúng không nằm trong `rtl/`, không được LibreLane tổng hợp và không phải thiết kế nộp thay lõi gốc.

| Fixture | Lỗi cố ý |
|---|---|
| off_by_one | Làm lệch deadline một chu kỳ |
| deadline_priority | Làm sai ưu tiên ACK tại đúng deadline |
| live_timeout_reload | Cho cấu hình timeout đang đổi tác động lên giao dịch bận |

Chạy `bash scripts/run_mutations.sh` từ gốc repo. Cùng core TB độc lập được chạy với mỗi fixture, tách riêng bằng top `f10_tb_selfcheck`. Một mutant chỉ được coi là **bắt được** nếu compile thoát 0, simulator thoát khác 0 (không phải shell timeout) và log có cả FAIL lẫn FATAL. Do đó script tổng có thể thoát 0 khi cả ba lần mô phỏng con đều thoát 1 đúng kỳ vọng.

Kết quả ở `evidence/local/mutation_smoke`, hoặc `${F10_EVIDENCE_DIR}/mutation_smoke`. Bản portable đã chạy thật nằm tại `evidence/portable-validation/mutation_smoke`. Log có FAIL/FATAL ở đây là **thất bại có chủ ý của mutant**; không trộn với PASS của RTL gốc. Script lưu full log/CSV nhỏ/hash/mã thoát, bỏ nhị phân và VCD mutant. Ba mẫu bắt được chỉ kiểm sức phát hiện ba lỗi cụ thể, không phải mutation coverage toàn bộ.
