# Kiểm tra bản PDF F10 hiện hành

Ngày kiểm tra: 20/10/2026. Phạm vi: đọc PDF, kiểm chữ và metadata, xem tất cả trang render; không sửa RTL, báo cáo hoặc bằng chứng nguồn.

## Kết quả

Không còn phát hiện cần sửa trước khi đóng gói ở hai PDF có hash dưới đây. Đây là kiểm tra chất lượng trình bày và tính nhất quán bằng chứng, không phải xác nhận điểm số hay signoff phần cứng.

| Tệp | Số trang | SHA-256 |
|---|---:|---|
| F10_24101280_BAO_CAO_BAN_LAM_VIEC.pdf | 15 | 0304795c44e3c83ff81f4674e6abc691676c78c31c912ec95786adff685f77ce |
| F10_24101280_PHU_LUC_MA_NGUON.pdf | 17 | 56bf929ad443d5089862ed349380f15daf7862d76f1148b0796b50c23ddca476 |

## Trang đã xem

- Bản chính: đã xem đủ trang 01–15 từ `tmp/pdfs/f10-ci-main/page-*.png` qua contact sheets mới tạo sau lần render cuối; xem lớn riêng trang 07 và 15. Các trang 10, 11, 12 và 15 cũng được xem lớn trong vòng kiểm tra nội dung trước chỉnh định dạng.
- Phụ lục: đã xem đủ trang 01–17 từ `tmp/pdfs/f10-ci-appendix/page-*.png` qua contact sheets mới. Không dùng bộ `tmp/pdfs/appendix/` cũ để kết luận.
- Không thấy trang trắng ngoài ý định, chữ bị cắt ở lề, bảng đè chữ, hình bị cắt, lỗi dấu tiếng Việt hoặc nội dung đè footer. Các bảng dài và code tiếp trang có thứ tự liên tục.
- Trang 07 sau thu hình còn đọc được các mốc 195/205/215/225/235 ns và 365/375/455 ns; caption và phần giải thích không chạm footer.
- Trang 15 sau rút gọn còn đủ repo, link CI, full commit thực thi, revision LibreLane/PDK, bộ công cụ, hash prefix có nhãn rõ và đường dẫn manifest chứa hash đầy đủ.
- Bản hiện hành: đối chiếu byte nội dung trang xác nhận trang 1–14 và toàn bộ 17 trang phụ lục trùng bản đã kiểm trước đó. Trang 15 đã render lại ở 120 dpi và xem riêng; bảng, nguồn tham chiếu và footer rõ, không cắt chữ. Metadata Author của hai PDF để trống.

## Định dạng

- Bản chính có 15 trang A4, nằm trong yêu cầu 8–15 trang không kể phụ lục.
- Kiểm font từ PDF bằng pypdf: toàn bộ body, chú thích văn bản và nội dung bảng bản chính dùng Times New Roman 13; tiêu đề 17/25; footer 9. Font được nhúng trong PDF.
- Builder bản cuối đặt bốn lề bản chính 70,87 pt, xấp xỉ 25 mm. Body/table leading 15,5 pt trên cỡ 13, tương đương khoảng 1,19 dòng.
- Phụ lục mã dùng Consolas 8,3 để bảo toàn khả năng in các dòng mã, văn bản dẫn nhập và ghi chú dùng TNR13; đây là phụ lục riêng, không được mô tả là văn bản chính cỡ 13.
- Vòng kiểm tra đầu phát hiện ghi chú/bảng cỡ 11 và lề trên/dưới nhỏ hơn 25 mm. Bản cuối có hash ở trên đã sửa các điểm đó và được kiểm lại.

## Đối chiếu nội dung trọng yếu

- Repo và CI trong trang 15 là URI annotation thực: `https://github.com/lechihoangcuong/eee703128-f10-24101280` và run `39390858919`.
- Commit đã chạy là `298e12b0f79a326343315beee1697f55e2946403`; báo cáo nói rõ được cập nhật sau lần chạy đó, không gán nhầm PDF cuối cho commit đã thực thi.
- Raw `final/metrics.json`: worst setup slack 1,314871804 ns, hold 0,109147250 ns; DRC Magic/KLayout và LVS đều 0 trong lần chạy đã ghi. Báo cáo làm tròn đúng, không xóa 11 vi phạm slew tại SS.
- Raw log `55-openroad-stapostpnr/nom_tt_025C_1v80/sta.log` có power tổng 2,854024e-4 W, phù hợp 0,285402 mW ở nom-TT. `final/metrics.json` có power tổng 0,000333318865 W, phù hợp 0,333319 mW ở max-FF. Hai điều kiện được phân biệt rõ; số liệu được giới hạn là vectorless, không phải công suất đo.
- GDS cuối 1.187.254 byte, SHA-256 `a119d53d1b03022d5e020c8124c052bf89232f74ca09cfd7d6e92021bc30777d`, trùng số liệu báo cáo.
- RTL lõi trong delivery có SHA-256 `10cca64461908d5cbe1da1d36be07633c613b92f1c2daeff7fd2ba414cccdfe4`, trùng nguồn và phụ lục. Báo cáo phân biệt lõi giữ nguyên với wrapper đã sửa.
- Reset được ghi là tích cực thấp, đồng bộ tại cạnh lên. START qua `uio_in[1]` được ghi là đề xuất tích hợp cần chốt, không giả là giảng viên đã duyệt.
- Ảnh layout nói rõ 2D từ KLayout CI; góc nhìn 3D chỉ top-level metal, x/y từ GDS, z giãn tùy ý, không cell con/via/độ dày công nghệ. Không diễn giải hình như bằng chứng silicon hay độ dày thật.
- Báo cáo giữ giới hạn synchronous peer/CDC, vi phạm slew, fallback SDC, hoạt động công suất và chưa thử phần cứng; không đồng nhất CI success với signoff hoặc chứng minh mọi chuỗi input.

## Giới hạn kiểm tra này

Không chạy lại RTL, tổng hợp hay physical flow trong vòng QA PDF. Các số được kiểm độc lập với raw artifacts đã tải; không xác nhận phần cứng chế tạo, tính đầy đủ tuyệt đối của verification hoặc sự phê duyệt phạm vi bởi giảng viên.
