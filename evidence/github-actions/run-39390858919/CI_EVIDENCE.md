# Bằng chứng GitHub Actions — run 39390858919

Repo công khai: [lechihoangcuong/eee703128-f10-24101280](https://github.com/lechihoangcuong/eee703128-f10-24101280).

Run thật: [F10 RTL to GDSII #1](https://github.com/lechihoangcuong/eee703128-f10-24101280/actions/runs/39390858919), sự kiện push, bắt đầu `2026-10-20T08:05:03Z`, hoàn tất `2026-10-20T08:08:36Z`. Hai job đã hoàn tất `success`: RTL/generic `118521750004`, physical `118522000084`. `metadata/jobs.json` lưu trạng thái các job đã đọc từ GitHub.

**Source commit đã thực thi:** `298e12b0f79a326343315beee1697f55e2946403`. Bản lưu evidence và các báo cáo được thêm sau run; commit tài liệu đó không phải mã nguồn mà run này đã thực thi.

## Hai artifact nguyên byte

| ZIP lưu trong thư mục này | Artifact ID | Byte | SHA256 khớp digest GitHub |
|---|---:|---:|---|
| `F10_CI_mo-phong_39390858919.zip` | 12249985484 | 986224 | `9a7cf1888d56b8b688265a80506b673b8707630cd52542a3bd7bf83ac8f7a18a` |
| `F10_CI_rtl2gds_39390858919.zip` | 12249622420 | 2444487 | `dbfc4290375deb73e48f443a1791a21332b57c3708ee7064165190f9652fe769` |

Đã kiểm hash và CRC cả hai ZIP. Metadata artifact ghi hạn lưu trên GitHub đến `2027-01-18T08:05:03Z`; bản sao trong repo giữ dữ liệu sau hạn đó. ZIP functional chứa cả `.vvp` do job upload nguyên đầu ra; đây là bản ghi artifact nguyên byte, không phải tệp cần biên dịch/nộp riêng. Không xóa tệp bên trong rồi tiếp tục gọi ZIP là bản nguyên gốc.

`selected/` chép nguyên byte các summary, log, CSV, versions, source hashes và physical metric/report tiện đọc. ZIP vẫn là nguồn đầy đủ cho VCD, netlist, final GDS, DEF, SDC, SPEF, SDF, Liberty, SPICE, ODB và log các stage. `SHA256SUMS` bao phủ các tệp lưu tại đây; `verification.json` ghi phép đối chiếu nguồn và ZIP. Không tự sửa log/artifact gốc để khớp lời giải thích.

## Mô phỏng và kiểm sức bắt lỗi

- Core: **1035 ca, 138571 chu kỳ, 1665218 check, 0 lỗi**, seed `F1002026`. CSV có 1035 dòng ca và một dòng SUMMARY; 1665215 check trong ca cộng 3 kiểm tra tổng kết bằng 1665218.
- Wrapper: **11 ca, 708 check, 0 lỗi**.
- `contract_bounds`: 3 ca peer hợp lệ N0/N1/N255 đo 3/3/511 chu kỳ; 1 quan sát peer hạ ACK sớm ngoài contract; **1607 check, 0 mismatch**. Không cộng nhóm này vào 1035 ca, không gọi ca ngoài contract là PASS giao thức.
- `mutation_smoke`: bắt **3/3 mutant**; mỗi mutant compile0, simulation1 và có FAIL/FATAL mong đợi. RTL đúng không chứa các mutant này. Đây không phải exhaustive coverage hoặc formal proof.

CI dùng Icarus Verilog 12.0; Yosys generic 0.33 (`2584903a060`); Verilator 5.020. Log compile giữ cảnh báo thiếu timeunit của module; lint giữ `START_INTERNAL` không dùng. Các bản công cụ này khác môi trường WSL local.

Waveform chú thích vẽ từ VCD local có các khai báo và sự kiện trùng VCD CI sau khi chỉ bỏ khác biệt `$date`/`$version`; normalizedSHA256 chung là `a130f74a4a05ee784e8585a097e1c04978c95eb085f7ee01a91549b34dd70655`. RawSHA256 CI là `df1a977ee412332f5c4212c0ed9e516d7906e5b87f48f93e87d17ca7f8aff0ea`, khác raw local vì metadata. Phép so được lưu tại `waveform_comparison.json`; không gọi hai rawfile là byte-identical.

## Tổng hợp generic

Lõi: **209 cell = 22 FF + 187 tổ hợp, 0 latch**. Top wrapper: **210 cell = 22 FF + 188 tổ hợp, 0 latch**. Các số này khớp kết quả local Yosys0.52, nhưng lần CI dùng Yosys0.33 riêng. 22FF được đối chiếu Q/net: count8 + N chốt8 + state quan sát4 + DONE1 + TIMEOUT1. Không suy từ bốn trạng thái ra tổng số FF.

Đã kiểm **16 tệp nguồn khác nhau** trong các `source_sha256.txt` khớp byte với tệp bàn giao. Lõi gốc giữ SHA256 `10cca64461908d5cbe1da1d36be07633c613b92f1c2daeff7fd2ba414cccdfe4`.

## Physical: có GDS, còn điều kiện giới hạn

LibreLane **3.0.16**, revision `01ddb25e4424f6f5aaf6b951b14a2b6fdcf737c0`; Sky130A revision `8afc8346a57fe1ab7934ba5a6056ea8b43078e71`, thư viện `sky130_fd_sc_hd`. Top `tt_um_24101280_f10`, target10ns. Physical synthesis Yosys0.62, khác bước generic.

- Mapped synthesis: 133 cell,22FF, area1383,8272µm². Final standard cell:454, area2162,07µm²; thêm5008fill, tổng5462instance. Die160×160µm không phải cell area hoặc tile shuttle được duyệt.
- Worst setup **+1,314871804ns** ở `max_ss_100C_1v60`; worst hold **+0,109147250ns** ở `min_ff_n40C_1v95`. WNS/TNS0 ở9corner. Dùng `ws` để đọc slack dương, không nhầm WNS0 là slack thực bằng0.
- Route/Magic/KLayout DRC0, LVS0, XOR0, antenna0 theo bộ deck/tool đã chạy. CTS có22sink,5buffer cây và2dummyload, final7clockbuffer; clock-rise skew TT0,043615ns.
- **Còn11pin vi phạm slew trong từng cornerSS**, tệ nhất0,933907ns so với giới hạn0,75ns trên nhánh từ `rst_n` qua `fanout20`/`net20`. Checker chỉ cảnh báo nhóm corner này nên job xanh không có nghĩa đã sửa vi phạm.
- Power TT **285,402435µW**; aggregate333,318865µW khớp maxFF. Ước tính vectorless, chưa ghi VCD/SAIF workload hay toggle/probability số. Không phải công suất silicon đo được.
- FallbackSDC cho I/O giả định2ns; `VSRC_LOC_FILES` thiếu nên IR chưa có độ tin cậy cấp nguồn/đóng gói thực. Chưa sign-off, tape-out, chế tạo hoặc kiểm thử chip.

Xem [phân tích raw chi tiết](PHYSICAL_ANALYSIS.md), [dữ liệu phân tích JSON](physical_analysis.json), [physical flow](../../../docs/PHYSICAL_FLOW.md). Đường dẫn source trong log vẫn giữ như trên runner để truy vết. Full STA log đã giữ các đường timing; việc không có `.rpt` riêng không có nghĩa chưa chạy STA.

GDS chính: `selected/physical/final/gds/tt_um_24101280_f10.gds`,1187254byte, SHA256 `a119d53d1b03022d5e020c8124c052bf89232f74ca09cfd7d6e92021bc30777d`. Render2D KLayout nằm trong artifact; hình3D bổ sung sau CI chỉ tách lớp các polygon metal cấp top theo z minh họa, không phải bề dày công nghệ hay mô hình3D đầy đủ.

Thông tin giao diện còn phải nêu với giảng viên: START ở `uio_in[1]` là đề xuất tích hợp, requester nằm trong RTL còn responder nằm trong TB; chưa coi đó là phê duyệt của giảng viên. Input/peer hợp tác đồng bộ, CDC bên ngoài phạm vi. Các kết quả trên không chứng minh mọi chuỗi input hoặc mọi peer vi phạm đều được bắt.
