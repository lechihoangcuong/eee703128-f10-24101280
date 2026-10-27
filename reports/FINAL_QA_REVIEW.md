# Kiểm tra PDF và bằng chứng hiện hành ngày 27/10/2026

- Báo cáo 38 trang, SHA-256 `5578b44661430174d01ca8ee522bc2f413a7fc6432b7dc53911aa82d906eb640`.
- Sửa trực tiếp từ PDF sinh viên gửi, giữ nguyên phần đã chỉnh. Chỉ thay các vùng truy vết ở trang 1, 2, 37; 35 trang còn lại trùng từng pixel khi render bằng cùng công cụ.
- Mục lục B/C/Cam kết đã sửa thành 22/37/38. Giữ đủ 13 liên kết mục lục; thêm liên kết CI có thể bấm.
- Đã xem trang sửa ở kích thước đầy đủ và bảng ảnh toàn bộ 38 trang: không thấy chồng chữ hoặc tràn vùng sửa.
- CI hiện hành: [40179312464](https://github.com/lechihoangcuong/eee703128-f10-24101280/actions/runs/40179312464), thực thi `b59c838b69c1b35e73c9c9ca8cdcd36c34d7d25f`. Snapshot RTL/TB nộp ổn định: `7ae2df482cbf7f316b2eac5e066c0b33ebad88eb`; đủ 22 tệp đầu vào trùng blob SHA.
- Hai ZIP nguyên byte khớp digest GitHub. Đã đối chiếu toàn bộ 307 metrics, CSV và VCD; không đổi số liệu. GDS cùng hình học, khác raw SHA-256 do thời gian ghi tệp.
- LibreLane vẫn 3.0.16 nhưng revision của run hiện hành là `a09d248c49bd1f7170d41885936f63e4255b1fe5`; metadata đã cập nhật đúng revision này.
- Giữ nguyên 11 vi phạm slew, power vectorless và giới hạn fallback SDC/nguồn IR. Không có lần chạy CI mới, kiểm phần cứng hoặc nộp Canvas trong đợt sửa này.
- Word và Markdown cũ được giữ làm tài liệu phiên bản trước; không gọi là đồng bộ với PDF sinh viên đã chỉnh.
