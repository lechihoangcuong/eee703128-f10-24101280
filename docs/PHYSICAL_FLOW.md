# Physical flow: lần chạy thật và giới hạn

[CI run 40179312464](https://github.com/lechihoangcuong/eee703128-f10-24101280/actions/runs/40179312464) ngày 25/10/2026 đã hoàn tất cả hai job. Physical job chạy LibreLane Classic, không phải kết quả preflight của máy local. Source revision đã thực thi là `b59c838b69c1b35e73c9c9ca8cdcd36c34d7d25f`; tài liệu/evidence bổ sung sau run có commit khác. Mẫu Canvas gốc giữ ở `docs/course-reference/rtl2gds.canvas-original.yml`.

## Môi trường và đầu vào thực tế

- Top: `tt_um_24101280_f10`; ba tệp `rtl/`; clock `clk`, mục tiêu 10 ns.
- LibreLane **3.0.16**, revision `a09d248c49bd1f7170d41885936f63e4255b1fe5`.
- PDK **sky130A**, Ciel/open_pdks revision `8afc8346a57fe1ab7934ba5a6056ea8b43078e71`, thư viện `sky130_fd_sc_hd`.
- Physical synthesis dùng Yosys **0.62** (`7326bb7d6641500ecb285c291a54a662cb1e76cf`), khác Yosys 0.33 của job generic; Magic 8.3.623, Netgen 1.5.316, KLayout 0.30.7. Phiên bản đầy đủ giữ trong log gốc.
- Run tag: `RUN_2026-10-25_09-08-50` (UTC).

`PNR_SDC_FILE` và `SIGNOFF_SDC_FILE` chưa đặt nên flow dùng fallback SDC: clock 10 ns, uncertainty 0,25 ns, transition 0,15 ns; input/output delay 2 ns; output load được viết 0,0334 pF; early/late derate 0,95/1,05. Đây là giả định bài thực hành, chưa phải ràng buộc của một board/chip tích hợp thật.

## Kết quả từ đúng giai đoạn

| Giai đoạn / chỉ số | Kết quả | Cách đọc |
|---|---:|---|
| Yosys mapping Sky130 | 133 cell; 22 cell tuần tự; 1383,8272 µm² | Khác 210 cell generic; đã ánh xạ thư viện, chưa có toàn bộ hạ tầng layout |
| Final standard cell | 454 cell; 2162,07 µm² | Bao gồm 22 cell tuần tự và hạ tầng; không gọi tất cả là logic của FSM |
| Fill cell | 5008 cell; 18044,8 µm² | Không cộng vào “454 cell chức năng” rồi so trực tiếp với Yosys |
| Tổng instance / diện tích | 5462 / 20206,9 µm² | Có fill; phân biệt với standard-cell area ở dòng trên |
| Die / core | 25600 / 20206,9 µm² | Die 160×160 µm; chưa phải tile Tiny Tapeout đã được duyệt |
| Worst setup slack | **+1,314871804 ns** ở `max_ss_100C_1v60` | `timing__setup__ws`; WNS/TNS đều 0 ở 9 corner, không thay positive slack bằng WNS 0 |
| Worst hold slack | **+0,109147250 ns** ở `min_ff_n40C_1v95` | `timing__hold__ws`; dưới fallback SDC và ký sinh của lần chạy này |
| Max slew | **11 pin vi phạm** tại từng corner SS | Cùng nhóm pin qua 3 corner; không phải 33 net độc lập |
| Route / Magic / KLayout DRC | 0 / 0 / 0 | Theo deck/tool và cấu hình đã chạy |
| LVS / XOR / antenna | 0 lỗi LVS / 0 khác biệt XOR / 0 antenna | Không suy ra sign-off hoặc chế tạo thành công |

CTS có 22 sink chức năng, chèn 5 buffer cây clock và 2 dummy clock load; final metric đếm 7 clock buffer. Độ sâu cây 2. Ví dụ clock-rise network skew ở `nom_tt_025C_1v80` là 0,043615 ns (latency min 0,348568; max 0,392183 ns). Đây là một định nghĩa skew và một corner; không trộn với metric worst-setup/hold skew dùng OCV ở các corner khác.

Power post-route ở `nom_tt_025C_1v80`: internal 212,632716 µW + switching 72,753843 µW + leakage 0,015853 µW = **285,402435 µW**. `power__total` tổng hợp cuối bằng 333,318865 µW khớp `max_ff_n40C_1v95`, nên không gắn số đó nhãn TT. Đây là ước tính vectorless; artifact không ghi VCD/SAIF workload hoặc toggle/probability số cụ thể. Chưa đo công suất silicon.

IR ở corner TT báo sụt VPWR≈41,5685 µV, VGND≈53,9897 µV, nhưng `VSRC_LOC_FILES` không được cấu hình. Các số này dùng nguồn phân bố giả định, chưa kết luận được độ sụt áp khi đóng gói/cấp nguồn thực.

## Vi phạm còn lại và chẩn đoán

Flow kết thúc thành công **vẫn còn 11 pin vượt slew** tại `nom_ss_100C_1v60`, `min_ss_100C_1v60`, `max_ss_100C_1v60`. Pin tệ nhất `_159_/A` có transition 0,933907 ns so với giới hạn 0,75 ns (slack −0,183907 ns). Truy netlist cho thấy nhánh bắt nguồn từ `rst_n` qua `input2`, `net2`, `fanout20` (`sky130_fd_sc_hd__clkdlybuf4s25_1`) tới `net20`: 10 pin nhận và 1 pin driver. Checker slew được cấu hình chỉ cảnh báo cho các corner này, nên trạng thái job không phản ánh việc vi phạm đã được sửa. Không gọi DRC/LVS 0 là đã sạch STA.

Hướng sửa cần thử và kiểm lại: rà tải/fanout nhánh reset, chọn buffer phù hợp hoặc tách nhánh; theo dõi đánh đổi setup/hold do delay buffer. Sau thay đổi phải chạy lại PnR và STA mọi corner. Chỉ kéo dài chu kỳ clock không trực tiếp chữa quy tắc transition. Bản hiện tại giữ nguyên mã lõi và giữ trung thực cảnh báo; không tự tuyên bố timing sign-off.

Log còn giữ cảnh báo lint, thư viện đọc lặp, rule LEF58 không được hỗ trợ, 6 pin không nối (0 critical), và nguồn IR giả định. Không đồng nhất mã thoát 0 với không có cảnh báo. Hình `final/render/*.png` là render 2D thật của KLayout. Hình 3D bổ sung trong `docs/figures/` được dựng sau CI từ 1304 polygon metal1–5 cấp top của GDS thật: tọa độ x/y thực, cao độ z chỉ để tách lớp quan sát. Hình đó không mô phỏng bề dày công nghệ, không chứa đầy đủ child-cell/via, không phải ảnh cắt lớp chế tạo.

## Artifact và tái lập

Xem [CI_EVIDENCE.md](../evidence/github-actions/run-40179312464/CI_EVIDENCE.md). Hai ZIP nguyên byte được lưu trong repo cùng digest GitHub, run/jobs metadata và selected raw metrics/log. Trong ZIP physical, GDS chính nằm ở `runs/RUN_2026-10-25_09-08-50/final/gds/tt_um_24101280_f10.gds` (1187254 byte, SHA256 `6bb02c420db3967a6b95394187e302c512e116d9a5b9c268b86434cf40f1800a`). Artifact hiện hành giữ GDS, metrics, JSON header và các log/state được chọn; không khẳng định mọi output DEF/SPEF/SDF/ODB đều có trong ZIP đã tải lên.

Để tái lập, checkout đúng source commit trên; dùng đúng revision LibreLane/PDK thay vì tự gọi bản mới là cùng môi trường. Workflow hiện clone nhánh LibreLane theo mẫu lớp rồi ghi revision thật; một lần chạy sau có thể dùng revision khác. Giữ source SHA, run URL, resolved config và phiên bản khi so sánh kết quả. Không hứa tệp GDS giống từng byte qua phiên bản công cụ khác.

Nguồn chính thức đã dùng để đối chiếu cấu hình: [Design configuration](https://librelane.readthedocs.io/en/latest/reference/configuration.html), [Universal variables](https://librelane.readthedocs.io/en/latest/reference/common_flow_vars.html), [Step variables](https://librelane.readthedocs.io/en/latest/reference/step_config_vars.html), [PDK handling](https://librelane.readthedocs.io/en/latest/usage/about_pdks.html), [LibreLane source](https://github.com/librelane/librelane). Kết quả số ở đây trích từ artifact của run đã nêu, không lấy từ các trang tài liệu đó.

## Đối chiếu hình và số liệu đã có

Đã so sánh 307 khóa metrics với bản lưu run 39390858919: không có khác biệt. Công suất TT được kiểm lại trực tiếp từ `%OL_METRIC_F` trong log STA corner TT. GDS khác raw SHA-256 do trường thời gian BGNLIB/BGNSTR; toàn bộ record còn lại trùng byte. Vì vậy các hình layout đã dựng từ GDS trước được giữ với nguồn gốc ban đầu, và có bằng chứng tương đương hình học trong `verification.json`.
