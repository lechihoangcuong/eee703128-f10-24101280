# F10 — đối chiếu yêu cầu giảng viên với bằng chứng

Sinh viên: **Lê Chí Hoàng Cường — 24101280 — N01**.

Bảng này phân biệt kết quả đã kiểm local, tài liệu đang chuẩn bị và điều kiện nộp còn thiếu. Đây không phải giấy nghiệm thu của giảng viên. Trạng thái “còn mở” phải được cập nhật bằng bằng chứng thật trước khi nói đã đáp ứng toàn bộ yêu cầu.

## 1. Căn cứ và tài liệu chưa thống nhất

Ưu tiên **charter F10 đầy đủ** và **Hướng dẫn chung hiện thấy trên Canvas**. Hai nguồn cùng yêu cầu:

1. Repo GitHub cá nhân, lịch sử commit thật và link CI — Cổng A bắt buộc.
2. RTL, testbench/test script và mô tả giao diện.
3. Artifacts của flow hoặc nhật ký lỗi có chẩn đoán nếu flow thất bại.
4. PDF 8–15 trang, kèm phụ lục thông tin tái lập.

Một số tài liệu START_HERE v2.4 coi CI/GDS là mở rộng. Không được dựa vào đó để tự miễn yêu cầu ghi rõ trên Canvas và charter khi chưa có xác nhận thay thế của giảng viên. Có thể lồng tám thành phần phân tích của v2.4 vào báo cáo, đồng thời giữ các điều kiện repo/CI/bằng chứng.

Nguồn đã đối chiếu:

- Charter: `reference/f10_charter_text.txt`, §§4.2, 5, 6, 8, 9, 10, 12; trích từ `D:/documentary IC/p_charter_F10.html`.
- [Hướng dẫn chung Canvas](https://canvas.phenikaa-uni.edu.vn/courses/30065/files/4677304?module_item_id=440828), §§1, 2, 4, 7, 9, 14; nội dung nhìn thấy lưu tại `reference/canvas/p_huong_dan_chung_visible_text.txt`.
- [Mẫu CI Canvas](https://canvas.phenikaa-uni.edu.vn/courses/30065/files/4677309?module_item_id=440833); bản nguồn lưu riêng tại `reference/canvas/rtl2gds.canvas-original.yml`.
- `output/labAB/goi/Lab_guide/B2_LAB_GUIDE_VA_80_PHIEU_DE.html`, mục F10: **“Tuần tự · làm theo bài mẫu A + B”**.
- `reference/b2_course/START_HERE.html`, rubric và mẫu báo cáo cùng bộ v2.4, để đối chiếu thêm.

## 2. Ma trận yêu cầu và trạng thái

| ID | Yêu cầu | Bằng chứng đã có | Trạng thái / việc còn lại |
|---|---|---|---|
| R01 | Luyện Lab A + B | `work/LAB_AB/`: bản đúng, mutant, log/VCD, generic và hash nguồn | **Đã làm local** phần này; chưa có physical flow A/B |
| R02 | Giao diện, reset, clock, trường hợp biên | Specification, `testplan_actual.md`, `WRAPPER_INTEGRATION.md` | **Đã mô tả**; cần xác nhận START trên uio1 và phạm vi requester |
| R03 | Kiến trúc/FSM | Bốn trạng thái; timer và N chốt; hình block/context | **Đã có local**; sơ đồ không thay thế kiểm chứng |
| R04 | RTL + TB + script | Core, wrapper, alias top; hai TB; repo portable | **Đã có bản chạy**; cần xác nhận bản đóng gói bằng lần tái lập |
| R05 | Bắt tay bình thường | TC01: 37–87 ns; REQ↑45, ACK↑50, REQ↓65, ACK↓70, DONE↑75 | **PASS local**; VCD/CSV/log thật |
| R06 | Bên kia trả lời chậm | TC02: 87–187 ns; ACK cao/thấp trước hạn | **PASS local** |
| R07 | Bên kia không trả lời | TC03: N=4, REQ lên195 ns, timeout235 ns, không DONE | **PASS local** |
| R08 | Hai lần bắt tay liên tiếp | TC05: 327–467 ns; DONE1=365, REQ2=375; N=2 rồi9 | **PASS local** |
| R09 | ≥2 ca tự thêm, có ca biên và giải thích | ACK mắc cao/cũ; START khi bận; thay N; reset giữa cạnh; N=0..255 và deadline | **Đủ số ca bổ sung**; sinh viên phải giải thích lỗi mỗi ca bắt |
| R10 | Câu phân tích riêng: bốn pha từ waveform mới | VCD, `directed_transitions.json`, `normal_4phase.png/.svg` | **Đã có dữ liệu**; phân biệt ACK lên50 và lấy mẫu55 ns |
| R11 | Timer bao nhiêu bit, nạp từ đâu, bỏ thì sao | N từ ui8, timer8; chốt N; ngân sách riêng mỗi pha | **Đã có phân tích**; N=0 không phải256 chu kỳ |
| R12 | Checker thật và tái lập được | 1.035 ca; 138.571 chu kỳ; 1.665.218 check; 0 lỗi; seedF1002026 | **PASS local**; chưa phải formal hoặc mọi chuỗi đầu vào |
| R13 | Kiểm wrapper/chân top | 11 ca/708 check/0 lỗi; N128, N0, ena, reset, chân không dùng | **PASS local**; mapping START vẫn là giả định |
| R14 | Tổng hợp và giải thích cấu trúc | Lõi209=22FF+187logic; top210=22FF+188logic; 0latch | **Có generic Yosys0.52**; chưa area/timing Sky130 |
| R15 | Repo GitHub cá nhân | Repo portable chuẩn bị tại `delivery/F10_24101280` | **Còn mở:** chưa có URL repo; folder local không thay repo GitHub |
| R16 | Lịch sử commit thật M1–M5 | Có Git local: nhập RTL/TB, script+evidence+CI, rồi tài liệu/chẩn đoán; ngày và tác giả thật | **Có lịch sử local** với Codex assistant; không giả là mốc sinh viên đã làm trước đó. Chưa có repo remote. |
| R17 | Link CI run — Cổng A | Workflow dựa trên mẫu Canvas | **Còn mở:** chưa có URL run thật; YAML không phải kết quả CI |
| R18 | LibreLane/Sky130; STA/power/layout/DRC/LVS | Local chưa có physical tools/PDK cần thiết | **Chưa thực hiện physical flow local**; không điền0 hay chép số cũ |
| R19 | Artifacts hoặc lỗi flow + chẩn đoán | Chưa có lần physical flow để chẩn đoán stage | **Còn mở:** cần chạy thật và giữ artifacts hoặc lỗi thật |
| R20 | Đọc CTS vì F10 có clock | Hướng dẫn đọc đã có; chưa báo cáo CTS | **Chưa có bằng chứng:** không suy buffer/skew từ generic |
| R21 | PDF8–15 trang + phụ lục | Báo cáo chính14 trang, phụ lục17 trang; đã render và kiểm từng trang | **Có bản làm việc đã QA**, cần cập nhật kết quả CI trước bản nộp cuối |
| R22 | Repo/commit/CI/LibreLane/PDK/ngày chạy | Local có phiên bản/thời gian/hash | **Chưa đủ thông tin tái lập cuối cùng** cho CI/physical |
| R23 | Kết luận có điều kiện | Tài liệu phân biệt RTL/generic/physical/hardware | **Phải giữ trong bản cuối**; không sign-off/tape-out/chế tạo/Fmax |
| R24 | Vấn đáp5 phút và liêm chính | Có hướng dẫn, câu hỏi, đáp án; nguồn và hỗ trợ AI được ghi rõ | **Sinh viên cần tự chạy và giải thích**; checklist máy không thay được |

Các trạng thái repo/CI/PDF ở đây phản ánh lúc viết hướng dẫn. Khi chúng hoàn tất, người biên soạn phải cập nhật bảng và dẫn đúng artifact mới. Không tự đổi ô thành “đạt” chỉ vì tên file đã xuất hiện.

## 3. Số thực đo, số tham khảo và số chưa có

**Kết quả mới dùng được:** log/VCD/CSV của `current_core`; wrapper runs; netlist/stat/design.json/summary generic; các lần chạy mới Lab A/B. Mỗi số cần giữ tên lần chạy, phiên bản và hash nguồn. Đây là lần chạy local có công cụ hỗ trợ; không gắn nhãn CI.

**Tham khảo nguồn:** khoảng200–290 cell và1×1tile của charter; gợi ý18–19 ô nhớ; README nguồn ghi106cell,22FF,area1019.728µm² hoặc3ns. Không dùng chúng làm số thực đo của bản hiện tại khi thiếu artifact và điều kiện tương ứng.

**Chưa có:** area Sky130, setup/hold slack, Fmax, power, CTS buffer/skew, wirelength, utilization, DRC/LVS, layout/GDS. Thiếu số liệu không có nghĩa0. Chưa chạy physical flow không có nghĩa đã thất bại ở một stage cụ thể.

## 4. Giả định cần hiện rõ khi giảng viên rà soát

1. **Nguồn START:** charter chốt ACK trên uio0 và N trên ui8, chưa chốt START. Chọn uio1 theo phương án của functional spec, giữ các chân charter và đủ8bit N. Đây là đề xuất tích hợp, chưa được gọi là phê duyệt của giảng viên.
2. **Bên yêu cầu:** RTL là requester FSM; TB đóng vai peer phát ACK. Nêu rõ phạm vi này thay vì nhận đã hiện thực cả hai chip.
3. **Đồng bộ và hợp tác:** input cùng miền clock hoặc được xử lý ở ngoài. Peer chỉ nâng ACK sau REQ mới, giữ ACK cao tới khi REQ hạ, rồi hạ ACK. Chỉ “cùng clock” chưa đủ. Core không phát hiện mọi peer sai giao thức; ACK hạ sớm trong ACK_HIGH có thể vẫn dẫn tới DONE. Stress PASS đối chiếu model không chứng minh mọi stimulus peer đều hợp lệ.
4. **Timeout:** chốt N theo giao dịch, cấp ngân sách riêng mỗi pha; N=0 quyết định ở cạnh chờ đầu; ACK hợp lệ đúng deadline được ưu tiên. Bound tổng quát là `2×max(1,N)+1` chu kỳ sau accepted start, tối đa511 với N255; watchdog512 là bảo thủ.
5. **Reset:** đồng bộ tích cực thấp; không tự thay thành bất đồng bộ vì Lab0 từng dùng kiểu đó.

## 5. Điều kiện để đóng hồ sơ

- Có repo cá nhân thật, lịch sử tiến độ thật và quyền xem phù hợp; không tự công bố dữ liệu hoặc mời người khác khi chưa chốt.
- Có URL CI thật gắn đúng commit; mở được log/artifacts. Mọi số trong báo cáo khớp artifact được nộp.
- Có GDS/metrics/report đã kiểm **hoặc** log flow thất bại và chẩn đoán có bằng chứng. Không biến thiếu môi trường thành lỗi RTL tưởng tượng.
- PDF8–15 trang + phụ lục đã render và kiểm từng trang; bảng giao diện, waveform, RTM, nguồn và giới hạn đầy đủ.
- Repo/commit/run/phiên bản LibreLane/PDK/ngày chạy lấy từ dữ liệu thật; mục chưa có giữ “chưa có”.
- Sinh viên giải thích được bốn pha, timer, reset, ưu tiên deadline, mô phỏng so với tổng hợp và số22FF; công khai mức hỗ trợ.

**Kết luận trạng thái:** RTL, verification, waveform và tổng hợp generic đã có bằng chứng local. Chưa được tuyên bố đáp ứng toàn bộ yêu cầu khi Cổng A và bằng chứng physical flow hoặc chẩn đoán flow thật còn mở.


### Bổ sung bằng chứng giới hạn

`contract_bounds`: 3 ca hợp lệ N0/N1/N255 cho latency3/3/511 chu kỳ và1 quan sát ACK hạ sớm ngoài contract;1607check,0mismatch. Không cộng vào1035ca gốc. `mutation_smoke`:3/3 mutant compile0,simulation1,có FAIL/FATAL; bản đúng không chứa mutant. Hai nhóm đều có script portable và log riêng.
