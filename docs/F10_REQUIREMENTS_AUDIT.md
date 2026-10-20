# F10 — đối chiếu yêu cầu giảng viên với bằng chứng

Sinh viên: **Lê Chí Hoàng Cường — 24101280 — N01**.

Bảng này phân biệt kết quả đã kiểm local, CI thật và điều kiện nộp cần sinh viên hoàn tất. Đây không phải giấy nghiệm thu của giảng viên. Ngày20/10/2026 đã kiểm repo công khai và hai job CI thành công; physical còn11pin vi phạm slew cùng các giả định SDC/IR đã nêu rõ.

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
| R04 | RTL + TB + script | Core, wrapper, alias top; hai TB; repo portable;16sourcehash khớp CI | **Đã chạy lại từ repo và trên CI**; core gốc giữ nguyên byte |
| R05 | Bắt tay bình thường | TC01:37–87ns; REQ↑45, ACK↑50, REQ↓65, ACK↓70, DONE↑75 | **PASS local và CI**; VCD/CSV/log thật |
| R06 | Bên kia trả lời chậm | TC02:87–187ns; ACK cao/thấp trước hạn | **PASS local và CI** |
| R07 | Bên kia không trả lời | TC03:N4, REQ195ns, timeout235ns, không DONE | **PASS local và CI** |
| R08 | Hai lần bắt tay liên tiếp | TC05:327–467ns; DONE1=365, REQ2=375; N2 rồi9 | **PASS local và CI** |
| R09 | ≥2 ca tự thêm, có ca biên và giải thích | ACK mắc cao/cũ; START khi bận; thay N; reset giữa cạnh; N=0..255 và deadline | **Đủ số ca bổ sung**; sinh viên phải giải thích lỗi mỗi ca bắt |
| R10 | Câu phân tích riêng: bốn pha từ waveform mới | VCD, `directed_transitions.json`, `normal_4phase.png/.svg` | **Đã có dữ liệu**; phân biệt ACK lên50 và lấy mẫu55 ns |
| R11 | Timer bao nhiêu bit, nạp từ đâu, bỏ thì sao | N từ ui8, timer8; chốt N; ngân sách riêng mỗi pha | **Đã có phân tích**; N=0 không phải256 chu kỳ |
| R12 | Checker thật và tái lập được | 1035ca;138571chu kỳ;1665218check;0lỗi;seedF1002026 | **PASS local và CI**; chưa phải formal hoặc mọi chuỗi đầu vào |
| R13 | Kiểm wrapper/chân top | 11ca/708check/0lỗi;N128,N0,ena,reset,chân không dùng | **PASS local và CI**; mapping START vẫn là giả định |
| R14 | Tổng hợp và giải thích cấu trúc | Lõi209=22FF+187logic;top210=22FF+188logic;0latch | **Có generic local0.52/CI0.33 và mappingSky130133cell/22FF**; không trộn stage |
| R15 | Repo GitHub cá nhân | [Repo công khai](https://github.com/lechihoangcuong/eee703128-f10-24101280) | **Đã có repo thật và mã nguồn**; user đã duyệt public |
| R16 | Lịch sử commit thật M1–M5 | Bốn commit nguồn thật, sau đó cập nhật kết quả/tài liệu | **Đã đẩy nguyên lịch sử**; các mốc được giữ theo thời điểm thực hiện |
| R17 | Link CI run — Cổng A | [Run39390858919](https://github.com/lechihoangcuong/eee703128-f10-24101280/actions/runs/39390858919) trên `298e12b0f79a326343315beee1697f55e2946403` | **Hai job success**; metadata và ZIP được lưu, không chỉ có YAML |
| R18 | LibreLane/Sky130; STA/power/layout/DRC/LVS | LibreLane3.0.16;Sky130A;GDS;setup+1,314872ns/hold+0,109147ns;DRC/LVS0 | **Có physical CI thật**; còn11pin slewSS,fallbackSDC,power vectorless và IR nguồn giả định; chưa sign-off |
| R19 | Artifacts hoặc lỗi flow + chẩn đoán | Hai ZIP nguyên byte, hash khớp GitHub;metrics/log/GDS;phân tích nhánh reset gây slew | **Đã lưu artifact và chẩn đoán cảnh báo**; không sửa log để thành sạch |
| R20 | Đọc CTS vì F10 có clock | 22sink;5buffer cây+2dummyload;final7clockbuffer;skew riseTT0,043615ns | **Đã đọc log CTS/STA**; phân biệt định nghĩa skew và corner |
| R21 | PDF8–15 trang + phụ lục | Báo cáo chính cập nhậtCI15trang, phụ lục mã17trang | **Có bản cập nhật từ artifact**; QA/render bản cuối được lưu cùng báo cáo |
| R22 | Repo/commit/CI/LibreLane/PDK/ngày chạy | Run20/10/2026;source298e12b;LibreLane01ddb25;PDK8afc834;resolvedconfig | **Đủ thông tin truy vết lần chạy**; commit tài liệu sau run không phải source commit đã thực thi |
| R23 | Kết luận có điều kiện | Tài liệu phân biệt RTL/generic/physical/hardware | **Phải giữ trong bản cuối**; không sign-off/tape-out/chế tạo/Fmax |
| R24 | Vấn đáp5 phút | Có hướng dẫn học, câu hỏi và đáp án để ôn tập | **Cần luyện trình bày và giải thích thiết kế** bằng tín hiệu, trạng thái và kết quả kiểm chứng |

Các trạng thái dựa trên run đã nêu và bản lưu evidence. CI xanh không tự chứng nhận toàn bộ rubric đã đạt; phần hiểu bài, giả định giao diện và cách nộp của lớp vẫn cần rà soát.

## 3. Số thực đo, số tham khảo và số chưa có

**Kết quả mới dùng được:** log/VCD/CSV local và hai artifactCIrun39390858919;netlist/stat/design.json/summary generic;finalmetrics/GDS/SDC/STA/CTS/DRC/LVS; các lần chạy mới LabA/B. Mỗi số giữ tên lần chạy, phiên bản và hash nguồn. Giữ riêng nhãn local/CI, vì các phiên bản Yosys/Verilator khác nhau.

**Tham khảo nguồn:** khoảng200–290 cell và1×1tile của charter; gợi ý18–19 ô nhớ; README nguồn ghi106cell,22FF,area1019.728µm² hoặc3ns. Không dùng chúng làm số thực đo của bản hiện tại khi thiếu artifact và điều kiện tương ứng.

**Physical đã có số thực:** mapping133cell/1383,8272µm²;final454standardcell/2162,07µm²;die25600µm²;slack vàDRC/LVS như bảng;powerTT285,402435µWước tính vectorless. Xem `docs/PHYSICAL_FLOW.md` và `evidence/github-actions/run-39390858919/PHYSICAL_ANALYSIS.md` để giữ đủ đơn vị/corner/định nghĩa. Render2DKLayout thật; hình3Dbổ sung chỉ tách lớp1304polygonmetal1–5 cấp top theo z minh họa, không đầy đủ hierarchy/via/bề dày công nghệ.

**Chưa được chứng minh:** Fmax đo thực, power silicon, sign-off/chế tạo, CDC bên ngoài hay mọi chuỗi peer vi phạm. Slew11pinSS chưa được sửa. FallbackSDC và vị trí cấp nguồnIR còn là giả định. Thiếu bằng chứng không được thay bằng0.

## 4. Giả định cần hiện rõ khi giảng viên rà soát

1. **Nguồn START:** charter chốt ACK trên uio0 và N trên ui8, chưa chốt START. Chọn uio1 theo phương án của functional spec, giữ các chân charter và đủ8bit N. Đây là đề xuất tích hợp, chưa được gọi là phê duyệt của giảng viên.
2. **Bên yêu cầu:** RTL là requester FSM; TB đóng vai peer phát ACK. Nêu rõ phạm vi này thay vì nhận đã hiện thực cả hai chip.
3. **Đồng bộ và hợp tác:** input cùng miền clock hoặc được xử lý ở ngoài. Peer chỉ nâng ACK sau REQ mới, giữ ACK cao tới khi REQ hạ, rồi hạ ACK. Chỉ “cùng clock” chưa đủ. Core không phát hiện mọi peer sai giao thức; ACK hạ sớm trong ACK_HIGH có thể vẫn dẫn tới DONE. Stress PASS đối chiếu model không chứng minh mọi stimulus peer đều hợp lệ.
4. **Timeout:** chốt N theo giao dịch, cấp ngân sách riêng mỗi pha; N=0 quyết định ở cạnh chờ đầu; ACK hợp lệ đúng deadline được ưu tiên. Bound tổng quát là `2×max(1,N)+1` chu kỳ sau accepted start, tối đa511 với N255; watchdog512 là bảo thủ.
5. **Reset:** đồng bộ tích cực thấp; không tự thay thành bất đồng bộ vì Lab0 từng dùng kiểu đó.

## 5. Điều kiện để đóng hồ sơ

- Repo đã công khai theo lựa chọn của chủ tài khoản; giữ lịch sử và quyền xem đúng yêu cầu lớp.
- Có URL CI thật gắn đúng commit; mở được log/artifacts. Mọi số trong báo cáo khớp artifact được nộp.
- Có GDS/metrics/report đã kiểm **hoặc** log flow thất bại và chẩn đoán có bằng chứng. Không biến thiếu môi trường thành lỗi RTL tưởng tượng.
- PDF8–15 trang + phụ lục đã render và kiểm từng trang; bảng giao diện, waveform, RTM, nguồn và giới hạn đầy đủ.
- Repo/commit/run/phiên bản LibreLane/PDK/ngày chạy lấy từ dữ liệu thật; mục chưa có giữ “chưa có”.
- Sinh viên giải thích được bốn pha, timer, reset, ưu tiên deadline, mô phỏng so với tổng hợp và số22FF.

**Kết luận trạng thái:** đã có repo công khai, lịch sử thật, CI thật, RTL/verification/generic/physical artifacts và phân tích giới hạn. Các điều kiện bằng chứng CổngA không còn thiếu URL/run. Không tự nhận giảng viên đã nghiệm thu hoặc phần cứng đã đạt: còn11pin slew, các giả định SDC/IR/START/requester và phần sinh viên tự hiểu/vấn đáp.


### Bổ sung bằng chứng giới hạn

`contract_bounds`: 3 ca hợp lệ N0/N1/N255 cho latency3/3/511 chu kỳ và1 quan sát ACK hạ sớm ngoài contract;1607check,0mismatch. Không cộng vào1035ca gốc. `mutation_smoke`:3/3 mutant compile0,simulation1,có FAIL/FATAL; bản đúng không chứa mutant. Hai nhóm đều có script portable và log riêng.
