# F10 — hướng dẫn học, chạy lại và chuẩn bị vấn đáp

**Sinh viên:** Lê Chí Hoàng Cường — **MSSV:** 24101280  
**Lớp:** Nhập môn thiết kế vi mạch tích hợp-1-1-26(N01)  
**Phạm vi:** FSM bắt tay bốn pha req/ack; học từ Lab A/B, đọc RTL, chạy kiểm chứng, đọc tổng hợp và hiểu giới hạn bằng chứng.

Tài liệu này hướng dẫn học và sử dụng hồ sơ kỹ thuật F10. Mã lõi có sẵn trong gói đã gửi được giữ nguyên; wrapper, kiểm chứng mở rộng và cách trình bày được bổ sung trong bộ hồ sơ. Hãy chạy lại, kiểm tra dữ liệu, đối chiếu các giả định và tập giải thích thiết kế bằng tín hiệu, trạng thái và mốc thời gian cụ thể.

## 1. Bài yêu cầu gì, và hiện đã làm đến đâu?

F10 điều khiển một lần bắt tay giữa bên yêu cầu và bên đáp ứng. Bên yêu cầu phát `req`; bên kia phát `ack`. Sau một lượt, cả hai trở về 0 để sẵn sàng lượt tiếp theo. Nếu bên kia không phản hồi đúng hạn, khối báo `timeout` để tránh chờ vô hạn.

Theo charter F10 và hướng dẫn chung trên Canvas, hồ sơ phải có repo cá nhân, lịch sử commit thật, link CI, RTL/TB/giao diện, artifacts của flow hoặc log lỗi có chẩn đoán, PDF 8–15 trang và thông tin tái lập. Tài liệu v2.4 có đoạn coi CI/GDS là mở rộng, nhưng không được dùng đoạn đó để tự bỏ yêu cầu bắt buộc đang ghi rõ trên Canvas và charter. Bảng kiểm chi tiết nằm trong `F10_REQUIREMENTS_AUDIT.md`.

Các kết quả **đã chạy thật** trong bộ hồ sơ làm việc (Lab A/B local; F10 có local và CI riêng):

| Phần | Bằng chứng thực tế | Điều chưa được suy ra |
|---|---|---|
| Lab A | 7 ca đúng; bản cố ý lỗi bị bắt 2/7 ca; 0 FF | Chưa có physical flow của Lab A |
| Lab B | 10 ca đúng; bản cố ý lỗi bị bắt 1/10 ca; 9 FF | Chưa có physical flow của Lab B |
| Lõi F10 | 1.035 ca, 1.665.218 phép check, 0 lỗi | Chưa chứng minh mọi chuỗi đầu vào có thể có |
| Wrapper F10 | 11 ca, 708 check, 0 lỗi | Chưa chứng minh miễn nhiễm metastability |
| Tổng hợp generic | Lõi 209 cell/22 FF; top 210 cell/22 FF; 0 latch; local Yosys0.52 và CI Yosys0.33 | Generic không tự cung cấp area/thời gian của thư viện Sky130 |
| LibreLane trên CI | Đã sinh GDS, final metrics; xem mục13 và PHYSICAL_FLOW.md | Còn11vi phạm slew; fallbackSDC và IR nguồn giả định; chưa là sign-off hay chip thật |

Repo công khai: [lechihoangcuong/eee703128-f10-24101280](https://github.com/lechihoangcuong/eee703128-f10-24101280). [CI run40179312464](https://github.com/lechihoangcuong/eee703128-f10-24101280/actions/runs/40179312464) đã chạy thành công hai job ngày25/10/2026 trên mã nguồn `b59c838b69c1b35e73c9c9ca8cdcd36c34d7d25f`. Các commit bổ sung tài liệu sau run không phải source revision đã được run này thực thi. Bản lưu `evidence/github-actions/run-40179312464/` giữ ZIP, metadata, SHA256 và kết quả thật; phải đọc các giới hạn trước khi nói “CI xanh”.

## 2. Tại sao phải học cả Lab A và Lab B?

Danh mục F10 ghi rõ: **“Tuần tự · làm theo bài mẫu A + B”**. Trình tự hợp lý là A → B → F10.

### Lab A: đầu vào hiện tại quyết định đầu ra hiện tại

Phép so sánh là `alarm = (sample >= threshold)`, hai toán hạng không dấu 8 bit. Ví dụ `sample=120`, `threshold=120` thì `alarm=1`. Nếu sửa nhầm `>=` thành `>`, ca bằng nhau bị sai. Đó là lý do cần kiểm cả dưới ngưỡng, đúng ngưỡng và trên ngưỡng.

Mạch không cần nhớ sample trước đó. Không có clock để cập nhật trạng thái. Dự đoán 0 flip-flop, và lần Yosys generic thực chạy đúng là 0 FF. Không được nói tín hiệu vật lý đổi tức thời chỉ vì mô phỏng RTL không đặt trễ cổng.

### Lab B: mạch cần nhớ điều gì?

`threshold_r[7:0]` nhớ ngưỡng: 8 bit. `alarm_r` nhớ cảnh báo: 1 bit. Dự đoán 9 flip-flop; kết quả thực chạy là 9. Tên bài dùng từ “latch” theo nghĩa giữ cảnh báo, nhưng RTL mẫu dùng flip-flop cạnh lên, không tạo latch mức.

Điểm cần hiểu: khi sample giảm, cảnh báo đã chốt có thể vẫn giữ; `clear` có ưu tiên; `load_th` cập nhật ngưỡng tại cạnh lên. Trong chu kỳ nạp ngưỡng, các phép gán `<=` đọc giá trị cũ trước khi cập nhật, nên phải chặn chốt cảnh báo theo ngưỡng cũ. Bản cố ý bỏ điều kiện `!load_th` đã bị testbench bắt ở ca nạp ngưỡng 120.

**Đừng mang reset Lab 0 sang F10 theo trí nhớ.** Lab 0 đã học có `posedge clk or negedge rst_n`: bất đồng bộ. Lab B và F10 dùng `posedge clk`: đồng bộ. Cả hai cùng tích cực thấp, nhưng thời điểm hiệu lực khác nhau.

Mã và lệnh Lab A/B có sẵn trong `work/LAB_AB/HUONG_DAN_LAB_AB.md`. Phần tiếp theo chuyển từ “nhớ một ngưỡng” sang “nhớ đang ở pha nào của giao thức”.

## 3. Trước khi đọc code, hãy kể đúng một giao dịch

Giả sử ban đầu `req=0`, `ack=0`:

1. Bên yêu cầu nâng `req` từ 0 lên 1: “tôi có yêu cầu”.
2. Bên đáp ứng nâng `ack` từ 0 lên 1: “tôi đã nhận yêu cầu”.
3. Bên yêu cầu hạ `req` từ 1 xuống 0: “tôi đã thấy xác nhận”.
4. Bên đáp ứng hạ `ack` từ 1 xuống 0: “hai bên trở về trạng thái nghỉ”.

Đây là **bốn chuyển mức của giao thức**. Nó không có nghĩa mọi cách thiết kế bắt buộc phải có đúng bốn trạng thái FSM. Bản RTL đang dùng có bốn trạng thái cụ thể; đó là một lựa chọn hiện thực.

`req` không phải clock. `ack` không phải kết quả đếm. `done` không phải `ack`: `ack` là đầu vào của bên kia, còn `done` là thông báo hoàn tất do lõi tạo cho tầng điều khiển của mình.

Trong bài này chỉ hiện thực lõi **bên yêu cầu**. Testbench đóng vai tầng phát `start` và đối tác phát `ack`. Không có đường dữ liệu nhiều byte, bộ đệm payload hoặc mạch phía đáp ứng độc lập được chế tạo trong bộ RTL này. Cần trình bày rõ cách diễn giải phạm vi này khi giảng viên hỏi về hai phía giao tiếp.

## 4. Ba loại file khác nhau: core, wrapper, testbench

| File trong repo bàn giao | Là gì? | Có đưa vào tổng hợp không? |
|---|---|---|
| `rtl/f10_handshake_controller.sv` | Lõi FSM và timer | Có |
| `rtl/f10_tiny_tapeout_top.sv` | Nối tín hiệu lõi với chân Tiny Tapeout | Có |
| `rtl/tt_um_24101280_f10.sv` | Tên top theo MSSV, gọi wrapper | Có |
| `tb/f10_tb_selfcheck.sv` | Tạo clock/input, reference model và checker lõi | Không |
| `tb/f10_wrapper_tb.sv` | Kiểm cách nối chân và hành vi wrapper | Không |

**Mô phỏng** chạy thiết kế cùng testbench để kiểm đáp ứng theo stimulus. **Tổng hợp** đọc RTL hiện thực phần cứng và tạo mạng cell; không biến testbench thành chip. Testbench có thể tạo clock bằng trễ `#`, kết thúc bằng `$finish`, lưu VCD và cố ý tạo lỗi: đó là hoạt động kiểm tra, không phải chức năng của mạch cuối cùng.

Wrapper ban đầu của gói nguồn nối clock/reset/start hằng số nên chưa phải tích hợp dùng được. Bản làm việc nối đủ cổng, giữ nguyên lõi. Không được nói chỉ “giải nén” khi trong bản làm việc đã có sửa wrapper và bổ sung TB. Bản nguồn được bảo toàn riêng trong `reference/f10_supplied/`.

## 5. Chốt bảng giao diện trước khi đoán hành vi

| Tín hiệu lõi | Chiều/rộng | Ý nghĩa và điều kiện |
|---|---|---|
| `clk` | vào/1 | Cạnh lên cập nhật thanh ghi |
| `rst_n` | vào/1 | Reset đồng bộ, hiệu lực khi thấp tại cạnh lên |
| `start` | vào/1 | Đề nghị bắt đầu; chỉ được nhận ở IDLE và ACK thấp |
| `ack` | vào/1 | Xác nhận từ đối tác; giả định đồng bộ với clock |
| `timeout_value` | vào/8 | N không dấu 0..255; chốt lúc nhận giao dịch |
| `req` | ra/1 | Yêu cầu đang được giữ |
| `done` | ra/1 | Xung một chu kỳ khi hoàn tất |
| `timeout` | ra/1 | Xung một chu kỳ khi quá hạn |
| `state` | ra/4 | Mã trạng thái dùng quan sát/debug |

Ánh xạ đang dùng ở top:

- `ui_in[7:0]`: N đủ 8 bit.
- `uio_in[0]`: ACK, đúng charter.
- `uio_in[1]`: START, **giả định tích hợp bổ sung**, dựa trên phương án được functional spec của gói nguồn liệt kê. Charter chưa chốt chân START; không nói giảng viên đã duyệt.
- `uo_out[0]`: REQ; `[1]`: DONE; `[2]`: TIMEOUT; `[6:3]`: state; `[7]`: 0.
- `uio_out=0`, `uio_oe=0`: toàn bộ nhóm hai chiều đang làm đầu vào.
- `ena` chỉ chặn **giao dịch mới** qua `start=ena && uio_in[1]`; không đóng băng FSM đang bận.

Thêm START sử dụng một chân rỗi: 10 bit vào + 7 bit ra = 17 chân tín hiệu người dùng, trong ngân sách 24; clock/reset/ena là các cổng hạ tầng riêng của wrapper. Điều này khả thi về số chân, nhưng chưa thay thế việc xác nhận ý nghĩa giao diện với giảng viên.

ACK/START/N từ miền clock khác hoặc nút nhấn ngoài đời không tự nhiên thỏa giả định đồng bộ. Bộ RTL không có synchronizer CDC. Không tự thêm hai flip-flop rồi khẳng định đã xử lý mọi trường hợp: bài này đặt CDC ngoài phạm vi, và giao thức/độ rộng dữ liệu có thể đòi hỏi phân tích thêm.

**Cùng clock chưa đủ để đối tác đúng giao thức.** Bên đáp ứng phải chỉ nâng ACK sau REQ của giao dịch mới, giữ ACK cao cho tới khi thấy REQ hạ, rồi hạ ACK. RTL này không có bộ phát hiện mọi vi phạm của peer: trạng thái ACK_HIGH chuyển vô điều kiện ở cạnh tiếp theo; nếu peer hạ ACK sớm trong lúc req còn cao, lõi có thể vẫn đi tới done sau đó. Vì thế không viết “đã phát hiện mọi bắt tay sai”. Đây là giả định hợp tác của đối tác và giới hạn cần nêu rõ.

## 6. Đọc FSM từng trạng thái

| Trạng thái/mã | `req` | Điều kiện tại cạnh lên | Việc tiếp theo |
|---|---:|---|---|
| IDLE/0 | 0 | `start=1`, `ack=0` | Chốt N, xóa count, sang REQ_HIGH |
| IDLE/0 | 0 | `start=1`, `ack=1` | Không nhận giao dịch; vẫn IDLE |
| REQ_HIGH/1 | 1 | ACK=1 | Xóa count, sang ACK_HIGH |
| REQ_HIGH/1 | 1 | ACK=0 và hết hạn | Báo timeout, về IDLE |
| ACK_HIGH/2 | 1 | Một cạnh lên tiếp theo | Sang WAIT_ACK_LOW, hạ req |
| WAIT_ACK_LOW/3 | 0 | ACK=0 | Báo done, về IDLE |
| WAIT_ACK_LOW/3 | 0 | ACK=1 và hết hạn | Báo timeout, về IDLE |

Trong các trạng thái bận, `start` không được xử lý. Không có hàng đợi start. Nếu bạn nhấp start đúng lúc bận rồi bỏ xuống, mạch không nhớ nó để làm sau. Nếu giữ start cao đến lúc trở về IDLE và ACK thấp, mạch có thể nhận một giao dịch mới ở cạnh sau. Vì vậy bên gọi phải hiểu START là tín hiệu mức được lấy mẫu, không phải bộ bắt xung có hàng đợi.

`req` được suy ra chỉ từ `state_q`: đây là ngõ ra kiểu Moore. `done` và `timeout` là các thanh ghi xung được mặc định đưa về 0 mỗi cạnh bình thường rồi chỉ bật ở nhánh cần thiết. Cả hai không được cùng 1.

Đọc cấu trúc `if` theo thứ tự rất quan trọng. Trong REQ_HIGH, kiểm ACK trước timeout. Trong WAIT_ACK_LOW, kiểm ACK thấp trước timeout. Vì vậy phản hồi hợp lệ đúng cạnh deadline **thắng timeout**. Đổi thứ tự hai nhánh sẽ đổi đặc tả ở ca biên, dù nhiều ca bình thường vẫn PASS.

## 7. Vì sao `<=` và reset làm người mới dễ nhầm?

Trong `always_ff @(posedge clk)`, các vế phải được tính theo giá trị hiện tại khi cạnh lên xảy ra; các thanh ghi cập nhật bằng nonblocking assignment sau đó. Không đọc tuần tự như chương trình phần mềm chạy từng dòng rồi lập tức dùng giá trị mới.

Ví dụ tại cạnh 55 ns, FSM đang REQ_HIGH và lấy mẫu ACK=1. Nó đặt trạng thái kế tiếp ACK_HIGH. Sau cập nhật, `state=2`, nhưng `req` vẫn 1 vì cả REQ_HIGH và ACK_HIGH đều yêu cầu req cao. Tới cạnh 65 ns mới vào WAIT_ACK_LOW và req hạ. Đó là lý do “ACK lên thì req hạ ngay” là câu sai với RTL này.

Reset của lõi là `if (!rst_n)` bên trong khối chỉ nhạy cạnh lên. Kéo `rst_n` xuống giữa hai cạnh không làm thanh ghi đổi ngay; cạnh lên kế tiếp mới xóa. Hậu tố `_n` chỉ mô tả cực tính thấp, không tự cho biết đồng bộ hay bất đồng bộ.

## 8. Đọc bốn pha từ waveform thực tế của bài

Hình `work/F10/docs/figures/normal_4phase.png` được vẽ từ các chuyển mức trích từ VCD mới của `TC01_NORMAL`, không phải giản đồ sách gắn thời điểm tùy ý.

| Mốc | Dữ liệu thực đo | Giải thích |
|---|---|---|
| 40 ns | Testbench đặt START cao | Đầu vào được lái ở cạnh xuống để tránh tranh chấp với lấy mẫu |
| **45 ns — pha 1** | REQ 0→1 | Lõi nhận start, vào REQ_HIGH |
| **50 ns — pha 2** | ACK 0→1 | Đối tác do testbench mô hình hóa phản hồi |
| 55 ns | Lõi lấy mẫu ACK=1, vào ACK_HIGH | Đây là lúc nhận ACK theo clock; khác thời điểm cạnh ACK trên waveform |
| **65 ns — pha 3** | REQ 1→0 | Vào WAIT_ACK_LOW sau một chu kỳ ACK_HIGH |
| **70 ns — pha 4** | ACK 1→0 | Đối tác trả về nghỉ |
| 75 ns | DONE 0→1 | Lõi lấy mẫu ACK thấp và báo hoàn tất |
| 85 ns | DONE 1→0 | Xung DONE dài một chu kỳ clock |

Clock TB có chu kỳ 10 ns. Cạnh lên ở 45/55/65/75 ns; các đầu vào đổi tại cạnh xuống 40/50/70 ns theo lịch TB. Không được lấy 10 ns rồi kết luận “chip đã chạy được 100 MHz”: đây là thời gian kích thích của mô phỏng RTL, không phải giới hạn tần số vật lý được đo bằng STA.

Trong GTKWave, thêm `clk`, `rst_n`, `start`, `ack`, `req`, `done`, `timeout`, `state`. Chọn khoảng 37–87 ns, đặt marker lần lượt ở các mốc trên. Nếu chỉ thấy vài ps đầu hoặc đường thẳng, dùng Zoom Full rồi zoom đúng cửa sổ; file có thể đúng trong khi bạn đang nhìn sai khoảng thời gian. Đặt `state`/N/count ở Decimal hoặc Unsigned khi muốn đọc số; Hex `A..F` tương ứng 10..15.

## 9. Timer: 8 bit không đồng nghĩa đợi 256 chu kỳ trong mọi trường hợp

`timeout_q[7:0]` giữ N đã chốt. `count_q[7:0]` đếm số cạnh chờ đã đi qua. Cả hai 8 bit biểu diễn 256 giá trị 0..255. Giá trị lớn nhất là 255, không phải 256.

N chỉ được chốt khi bắt đầu ở IDLE. Đổi `timeout_value` trong lúc bận không được đổi deadline của giao dịch hiện tại. Mỗi pha chờ nhận lại ngân sách N riêng: một lần chờ ACK cao, một lần chờ ACK thấp. Đây không phải một ngân sách N dùng chung từ đầu tới cuối.

Ca `TC03_NO_ACK` dùng N=4 và ACK luôn thấp:

| Cạnh lên | Trạng thái trước cạnh | count trước cạnh | Kết quả |
|---|---|---:|---|
| 195 ns | IDLE | 0 | Nhận start, req lên; chưa phải cạnh chờ thứ nhất |
| 205 ns | REQ_HIGH | 0 | ACK chưa đến, count thành 1 |
| 215 ns | REQ_HIGH | 1 | count thành 2 |
| 225 ns | REQ_HIGH | 2 | count thành 3 |
| **235 ns** | REQ_HIGH | **3 = N−1** | Timeout, req hạ, về IDLE |
| 245 ns | IDLE | — | Xung timeout về 0 |

Nếu ACK cao đúng cạnh 235 ns, nhánh ACK được chọn trước và không timeout ở cạnh đó. Điều kiện biên này được kiểm riêng với mọi N.

**N=0 có nhánh riêng:** hết hạn tại cạnh chờ đầu tiên nếu chưa có ACK hợp lệ. Nó không đợi tràn 8 bit, không đợi 256 chu kỳ, cũng không timeout ngay tại cạnh nhận start. Nếu ACK hợp lệ ở cạnh chờ đó, ACK vẫn được ưu tiên.

Với N≥1, giao dịch lâu nhất có thể dùng N cạnh cho chờ ACK cao, thêm một cạnh chuyển qua ACK_HIGH, rồi N cạnh cho chờ ACK thấp: tối đa `2N+1` chu kỳ sau cạnh nhận start. Để gồm cả N=0, dùng `2×max(1,N)+1`. N=255 cho 511 chu kỳ; checker dùng giới hạn bảo thủ 512. Không dùng giới hạn 257 của tài liệu cũ để kết luận giao dịch hợp lệ bị treo.

Nếu bỏ timeout, đối tác có thể không nâng ACK hoặc giữ ACK cao mãi. FSM sẽ chờ vô hạn và tầng trên không biết khi nào thu hồi/khởi động lại công việc. Timeout giải quyết tiến triển có giới hạn trong phạm vi contract, không tự sửa được đối tác hỏng hay mất dữ liệu.

## 10. Testbench đã kiểm gì, và vì sao con số lớn chưa đủ để tự tin tuyệt đối?

Lõi được kiểm bởi reference model có trạng thái riêng, dùng ngân sách **còn lại** thay vì đọc `count_q`/`state_q` của DUT làm đáp án. Đầu vào đặt tại cạnh xuống, expected cập nhật theo cạnh lên, output kiểm sau 1 ns để đợi nonblocking assignment. Khoảng 1 ns là quy ước của TB `1ns/1ps` này, không phải quy tắc chung cho mọi môi trường DV.

Một phép kiểm dạng `actual !== expected` còn phát hiện X/Z khi expected đã biết. Comment `// expected...` chỉ là chữ, không khiến máy báo sai. `$fatal` mới làm lỗi kiểm tra kết thúc mô phỏng với mã thất bại; ngoài ra script còn đọc summary, số check và CSV.

1.035 ca gồm:

- 10 ca directed: reset, bình thường, trả lời chậm, không ACK, ACK mắc cao, hai giao dịch liên tiếp, ACK cũ, START khi bận, đổi N khi bận, reset đồng bộ giữa các cạnh.
- 4 nhóm × 256 giá trị N: timeout pha REQ, timeout pha ACK thấp, ACK cao đúng deadline, ACK thấp đúng deadline.
- 1 ca stress tái lập: seed `F1002026`, 4.096 chu kỳ stress, 16 reset.

Tổng lần chạy: 138.571 chu kỳ lấy mẫu; 1.665.218 check; 0 lỗi; compile và simulation exit 0. Các con số có trong `work/F10/05_VERIFICATION/runs/current_core/simulation.log` và `case_results.csv`. Phần stress đối chiếu phản ứng RTL với model theo contract đã chốt; PASS của stress không tự chứng minh mọi stimulus ACK là peer bốn pha hợp lệ, hoặc lõi sẽ phát hiện mọi peer sai giao thức.

Đây là phủ toàn miền N cho **bốn kịch bản đã định nghĩa**, không phải duyệt mọi chuỗi tín hiệu dài tùy ý. Không có báo cáo code coverage hay formal proof, nên không tự ghi “100% coverage”.

Ba bản sao cố ý sai được kiểm riêng: deadline lệch một chu kỳ; ACK mất ưu tiên tại deadline; nạp lại N trong lúc bận. Cả ba đều bị checker bắt. Điều này chứng minh checker bắt được ba lỗi cụ thể, không chứng minh checker không có lỗi hoặc bắt mọi lỗi. Log FAIL có chủ ý nằm riêng `mutation_smoke`; đừng lấy RTL mutant để nộp.

Wrapper có 11 ca/708 check độc lập, gồm N=128 để bảo đảm đủ 8 bit, N=0, ena khi bận, chân không dùng, reset đồng bộ và cách nối output. Lõi PASS không tự chứng minh wrapper nối đúng: nối nhầm chân vẫn có thể làm top sai.

## 11. Tổng hợp: phải giải thích đúng 22 flip-flop

Lần Yosys 0.52 generic, flatten và loại siêu dữ liệu `$scopeinfo` trước thống kê:

| Top | Tổng cell | FF | Cell tổ hợp | Latch |
|---|---:|---:|---:|---:|
| `f10_handshake_controller` | 209 | 22 | 187 | 0 |
| `tt_um_24101280_f10` | 210 | 22 | 188 | 0 |

Wrapper thêm một AND cho `ena && START`, không thêm trạng thái. Kết quả của lần này có 12 `$_SDFFE_PN0P_` và 10 `$_SDFF_PN0_`. Các tên đó là loại cell generic, không phải mã cell Sky130 cuối cùng.

Tại sao không nói ngay “bốn trạng thái nên bốn FF”? Vì số trạng thái và cách mã hóa là hai việc khác nhau. Bốn trạng thái về mặt thông tin có thể mã hóa bằng hai bit, nhưng RTL khai báo enum 4 bit và đưa state ra ngoài. Mạch còn timer, cấu hình chốt và xung kết quả. Công cụ có thể tối ưu hoặc giữ cấu trúc theo điều kiện tổng hợp. Dự đoán kiến trúc là điểm xuất phát; **22 là số quan sát từ netlist của lần chạy**, không được tự chia thành từng khối chỉ từ tên biến nếu chưa truy vết Q trong netlist.

Charter ghi tham khảo khoảng 18–19 ô nhớ. Đó không phải kết quả đo bắt buộc của bản RTL này. Không sửa số 22 thành 19 để “khớp đề”; hãy so RTL/encoding/port quan sát/netlist và giải thích khác biệt có căn cứ. Cũng không chép số 106 cell hoặc area/STA từ README nguồn: chúng không gắn với log mới của bộ mã đang báo cáo.

0 latch có nghĩa Yosys không suy ra latch mức trong lần tổng hợp này. Nó không chứng minh logic đúng chức năng. Lint exit 0 cũng không đồng nghĩa không có warning: có cảnh báo `UNUSEDPARAM` cho `START_INTERNAL`, và Icarus lưu cảnh báo timeunit của lõi nguồn. Giữ log và giải thích, đừng xóa warning khỏi bản báo cáo cho đẹp.

## 12. Chạy lại từ bộ repo bàn giao

Repo portable được chuẩn bị tại `delivery/F10_24101280`. Giữ `reference/` nguyên trạng; thao tác trong bản làm việc hoặc bản sao delivery. Mở Ubuntu WSL, không nhập các lệnh Bash trực tiếp vào dấu nhắc PowerShell.

Trong Ubuntu WSL, vào thư mục chứa repo đã tải hoặc giải nén, rồi chạy:

```bash
iverilog -V
yosys -V
bash scripts/run_sim.sh
bash scripts/run_synth.sh
```

Script tự tìm repo từ vị trí của nó, không cần giữ đường dẫn máy hiện tại. Công cụ dùng local đã có: Icarus Verilog 12.0, Yosys 0.52; phiên bản khác có thể cho thống kê generic khác, cần lưu phiên bản thật.

Đọc sau khi chạy:

```bash
cat evidence/local/simulation/core/simulation.log
cat evidence/local/simulation/wrapper/simulation.log
cat evidence/local/generic/core/summary.json
cat evidence/local/generic/wrapper/summary.json
gtkwave evidence/local/simulation/core/f10_core_selfcheck.vcd
```

Trong GTKWave, chọn nhóm tín hiệu như mục 8. Đừng chỉ tìm chữ PASS rồi đóng cửa sổ: kiểm có summary đúng số ca, số check >0, errors=0, và xem ca biên bạn cần giải thích. Nếu lệnh không tồn tại hoặc script dừng, ghi nguyên thông báo đầu tiên, thư mục hiện tại và phiên bản công cụ. Không tự sửa expected để mạch hiện tại PASS.

`scripts/run_sim.sh` chọn riêng top TB lõi và top TB wrapper; không ghép mọi top testbench rồi để chúng cùng `$finish`. `scripts/run_synth.sh` chỉ tổng hợp RTL. Log trong `evidence/local/` là kết quả lần **bạn vừa chạy**, có thể khác đường dẫn/time stamp với evidence lưu từ bản làm việc ban đầu.

## 13. Hoàn tất repo, CI và flow mà không tự đánh lừa mình

1. Đọc lại toàn bộ file sẽ đưa lên GitHub. Chọn public/private có chủ đích, nhất là khi báo cáo chứa họ tên/MSSV. Kho private được phép; quyền cho giảng viên cần thực hiện theo hướng dẫn lớp và tài khoản đúng.
2. Dùng lịch sử commit thật theo tiến độ M1–M5. Không lùi ngày, không giả sinh viên tự tạo những commit do công cụ làm, không tạo một dãy commit rỗng để đóng vai lịch sử học tập.
3. Sau khi repo thật có mã, workflow `.github/workflows/rtl2gds.yml` mới chạy trên Actions. Ghi URL chính lần chạy đó, commit, ngày và phiên bản công cụ. File YAML nằm trên máy không phải link CI.
4. Mở từng job, kiểm log và tải artifacts. Mô phỏng PASS không làm physical job tự PASS. Có GDS chưa chứng minh DRC/LVS sạch; metrics thiếu không được điền 0.
5. Nếu flow thất bại, lưu lỗi đầu tiên thuộc stage nào, thông báo nguyên văn, cấu hình/commit, điều đã thử và kết quả. Phân biệt lỗi cài môi trường/PDK với lỗi RTL, constraint và floorplan. Không sửa FSM để chữa lỗi hình học PDN.
6. Cập nhật PDF bằng dữ liệu thực của CI. Nếu chỉ có log thất bại, trình bày chẩn đoán có bằng chứng như charter cho phép; không bịa hình layout, area, power hay slack.

Máy local chưa chạy LibreLane, còn CI đã thực sự chạy toàn bộ flow với Sky130. Không gắn nhãn kết quả CI thành kết quả WSL. Khi xem [run40179312464](https://github.com/lechihoangcuong/eee703128-f10-24101280/actions/runs/40179312464), cần mở cả metrics và warning: job thành công nhưng còn11vi phạm slew ở các cornerSS, dùng fallbackSDC và không có vị trí nguồnVSRC_LOC_FILES thực. DRC/LVS không kiểm những điều kiện đó thay cho STA hay IR. Chi tiết và đơn vị nằm trong `docs/PHYSICAL_FLOW.md`, artifact gốc giữ nguyên trong hai ZIP.

Phân biệt các báo cáo:

| Báo cáo | Câu hỏi trả lời |
|---|---|
| Synthesis/netlist | RTL trở thành những cell nào? |
| STA | Đường timing có đạt các constraint đã khai báo, ở điều kiện phân tích đó không? |
| Power | Ước lượng công suất theo mô hình/corner/activity nào? |
| DRC | Hình học có vi phạm quy tắc công nghệ được kiểm không? |
| LVS | Connectivity layout có khớp netlist tham chiếu không? |
| GDS | Cơ sở dữ liệu hình học nào đã được sinh ra? |

F10 là tuần tự nên physical flow có clock và thường có CTS. Số cell sau layout có thể lớn hơn tổng hợp vì buffer, clock tree, tap/endcap. Không cộng/trừ hai con số từ hai stage khác nhau mà không nêu định nghĩa. Clock 10 ns hay slack dương ở một chu kỳ giả định không cho phép khẳng định đã đo Fmax hoặc “chip chạy được X MHz”.

## 14. Chuẩn bị một bài trình bày 5 phút

Đây là bố cục luyện nói, không phải câu khẳng định đã tự làm mọi việc:

- **0:00–0:45:** Khối requester làm gì; input START/ACK/N, output REQ/DONE/TIMEOUT; giả định chung clock; START trên uio1 là lựa chọn tích hợp cần xác nhận.
- **0:45–1:45:** Chỉ bốn cạnh thật 45/50/65/70 ns; phân biệt ACK lên 50 với FSM nhận 55 và DONE 75.
- **1:45–2:45:** Giải thích N=4 timeout235; ACK đúng deadline được ưu tiên; N chốt cho từng giao dịch; N=0 có nghĩa gì.
- **2:45–3:45:** Nêu bốn ca bắt buộc và ít nhất hai ca bổ sung kèm lỗi chúng bắt; chỉ log1.035ca/0lỗi, nói rõ phạm vi sweep.
- **3:45–4:30:** Phân biệt mô phỏng và tổng hợp; số thực209/22 và210/22,0latch; không bịa partition22FF.
- **4:30–5:00:** Nêu repo/CI/physical ở trạng thái thực tế lúc trình bày; các giới hạn CDC, hardware, PDK và kết luận có điều kiện.

Đừng học thuộc chữ rồi tránh mở file. Thử đổi một stimulus có dự đoán trước, chạy lại và giải thích waveform. Khi không biết nguyên nhân, câu đúng là “em chưa truy vết đủ; em sẽ kiểm netlist/log này”, không phải một lời đoán được nói chắc.

## 15. Câu hỏi tự kiểm và đáp án có lý do

Trước khi xem cột đáp án, che nó và tự viết một câu trả lời có tên tín hiệu hoặc mốc thời gian.

| Câu hỏi | Đáp án và lý do |
|---|---|
| Bốn pha có phải bốn giá trị của biến đếm không? | Không. Chúng là REQ↑, ACK↑, REQ↓, ACK↓. Trạng thái FSM/timer là cách hiện thực và ghi nhớ tiến trình. |
| ACK lên 50 ns, tại sao req không hạ 50 hoặc55 ns? | ACK được lấy mẫu55; FSM vào ACK_HIGH, vẫn req cao. Cạnh65 vào WAIT_ACK_LOW mới hạ req. |
| DONE tại75 có phải là pha4 không? | Pha4 là ACK↓70. DONE75 là kết quả đăng ký sau khi lõi lấy mẫu ACK thấp. |
| Nếu giữ clock=1, FSM tiếp tục chuyển không? | Không. `posedge` chỉ xảy ra lúc 0→1; giữ mức1 không tạo cạnh mới. |
| Kéo rst_n xuống giữa hai cạnh thì F10 xóa ngay không? | Không; reset đồng bộ, phải tới cạnh lên có rst_n=0. Lab0 từng dùng reset bất đồng bộ nên không được suy từ bài cũ. |
| START khi ACK đã cao có được xếp hàng không? | Không. Lõi ở IDLE và không bắt đầu; cần start hợp lệ tại thời điểm ACK thấp. |
| START khi bận có làm timer nạp lại không? | Không. Các nhánh bận không xử lý START; kiểm riêng để bắt lỗi nạp lại N. |
| N thay từ4 thành255 khi bận thì đợi theo số nào? | Theo4 đã chốt trong timeout_q, không theo input mới. |
| N=4 timeout tại cạnh nhận start thứ tư hay sau bốn cạnh chờ? | Sau bốn cạnh chờ; nhận195, chờ205/215/225/235, timeout235 ns. |
| ACK hợp lệ đúng deadline có bị timeout không? | Không theo contract này: ACK được ưu tiên trước nhánh timeout. |
| N=0 có đợi256 chu kỳ không? | Không. Nhánh N=0 timeout ở cạnh chờ đầu tiên nếu chưa có ACK hợp lệ; vẫn chừa cơ hội ACK đúng cạnh đó. |
| Hai pha chờ chia sẻ một N tổng cộng không? | Không. Mỗi pha bắt đầu với count0 và có ngân sách N riêng. |
| Không timeout thì điều gì hỏng? | Có thể chờ vô hạn khi đối tác không ACK hoặc giữ ACK cao; hệ thống mất tiến triển và không có báo lỗi hạn định. |
| Có1.665.218 check nghĩa là kiểm mọi trường hợp? | Không. Đó là số phép so của stimulus đã chạy; sweep đủ N×bốn kịch bản, chưa phải mọi chuỗi hoặc formal proof. |
| Tại sao mutant FAIL không có nghĩa bản nộp sai? | Mutant là bản riêng cố ý phá để kiểm sức bắt lỗi của TB; RTL đúng và log PASS được tách riêng. |
| Testbench có tổng hợp thành flip-flop không? | Không trong flow này. Synthesis chỉ nhận rtl; TB chỉ phục vụ mô phỏng. |
| Bốn trạng thái có buộc đúng4 FF không? | Không. Encoding quyết định số bit state, còn nhiều thanh ghi khác. Số FF thực phải đọc netlist; kết quả đang có22. |
| 22 FF có nghĩa chip diện tích22 đơn vị không? | Không. FF chỉ là số phần tử nhớ generic; area cần cell library và stage xác định, còn cell tổ hợp, dây và hạ tầng. |
| Wrapper làm tăng nhớ không? | Lần đo hiện tại không: vẫn22 FF, thêm1 cell tổ hợp do `ena && START`. |
| RTL mô phỏng PASS đã chứng minh phần cứng chạy không? | Chưa. Nó kiểm hành vi RTL theo stimulus/model; physical/timing/CDC/hardware là các bằng chứng khác. |
| Chưa chạy physical thì viết DRC=0 được không? | Không. Chưa có số liệu phải ghi chưa có;0 là kết quả đo có nghĩa, không phải ô trống. |
| Phần nào cần xác nhận với giảng viên? | Chân START trên uio1 chưa chốt trong charter và cách hiện thực requester với responder ở TB; nêu rõ giả định thay vì tự coi đã được duyệt. |

Nếu bạn chưa tự giải thích được ba câu ACK50/55/65, N4 timeout235 và vì sao TB không tổng hợp, hãy dừng ở chúng trước khi học thuật ngữ STA/DRC/LVS. Đó là nền để đọc phần còn lại chính xác.

## 16. Nguồn và nơi kiểm tra bằng chứng

- Charter gốc: `D:/documentary IC/p_charter_F10.html`; bản trích nội dung `reference/f10_charter_text.txt`.
- Hướng dẫn chung Canvas: https://canvas.phenikaa-uni.edu.vn/courses/30065/files/4677304?module_item_id=440828 ; nội dung nhìn thấy được lưu ở `reference/canvas/p_huong_dan_chung_visible_text.txt`.
- Mẫu CI Canvas: https://canvas.phenikaa-uni.edu.vn/courses/30065/files/4677309?module_item_id=440833 ; YAML nguồn lưu riêng `reference/canvas/rtl2gds.canvas-original.yml`.
- Danh mục Lab A/B: `output/labAB/goi/Lab_guide/B2_LAB_GUIDE_VA_80_PHIEU_DE.html`, mục F10 và bài mẫu A/B.
- Nguồn người học gửi: `reference/f10_supplied/F10_FSM_bat_tay_bon_pha_req_ack/`; bản làm việc `work/F10/`.
- Log lõi: `work/F10/05_VERIFICATION/runs/current_core/`; log wrapper: `work/F10/05_VERIFICATION/runs/wrapper/`.
- Generic/lint: `work/F10/06_GDSII/generic/`; hình có nguồn dữ liệu: `work/F10/docs/figures/`.

Các kết quả local trong hướng dẫn là lần chạy mới trên WSL bằng công cụ hỗ trợ của bộ hồ sơ; CI có log/phiên bản riêng đã lưu. Khi bạn chạy lại, ghi đúng log/commit/run mới đó; không xóa nguồn gốc hỗ trợ và không gắn nhãn kết quả local thành kết quả CI.


## Bổ sung đã đo ngày 20/10/2026

Chẩn đoán riêng đã kiểm cả hai pha chờ ở deadline: N=0 đo 3 chu kỳ, N=1 đo 3, N=255 đo 511 (135→5245 ns). Có 3 ca đối tác hợp lệ và 1 quan sát đối tác ngoài contract; 1.607 check,0 mismatch. Các số này tách khỏi bộ 1.035 ca. Ca ACK hạ sớm đo ACK↓5280 ns trước req↓5285 ns mà done vẫn lên5295 ns; đây là giới hạn thật, không gọi là PASS bốn pha. Xem `evidence/portable-validation/contract_bounds/`.

Trong repo portable, chạy `bash diagnostics/contract_bounds/run.sh` để tái lập; chạy `bash scripts/run_mutations.sh` để thấy ba bản sao cố ý sai bị bắt. Log mutation FAIL là kết quả mong đợi của thử phá, không phải RTL được chấp nhận khi sai.

Báo cáo PDF hiện tại do sinh viên chỉnh sửa ngày 27/10/2026 có 38 trang, gồm cả phụ lục, nằm trong `reports/`. Bản phụ lục mã riêng 17 trang được giữ lại từ phiên bản trước. Repo công khai lưu lịch sử thay đổi và source commit đã chạy CI. URL repo/run và GDS đã có bằng chứng; phần ôn tập trước khi nộp gồm bốn pha, timer,22FF và giới hạn physical.

Đọc physical theo ba câu hỏi. **Số ở stage nào?** Generic top210cell, Sky130mapping133cell, final454standardcell không mâu thuẫn vì định nghĩa và thư viện khác nhau; cuối cùng vẫn22cell tuần tự. **Điều kiện đo là gì?** Setup+1,314872ns ở maxSS, hold+0,109147ns ở minFF; powerTT285,402µW là ước tính vectorless với I/O fallback2ns, chưa phải đo chip. **Còn gì chưa đạt?**11pin slewSS vẫn vượt0,75ns, dù DRC/LVS0 và jobsuccess. Rà nhánh reset/buffer cần chạy lại physical; chỉ kéo dài clock không trực tiếp chữa slew.

Render2DKLayout là ảnh thật từ GDS. Hình3Dbổ sung chỉ tách lớp1304polygonmetal1–5 cấp top: x/y thực, z để minh họa; không đầy đủ child-cell/via và không thể dùng như bề dày công nghệ. Khi vấn đáp, đừng gọi mọi hình3D là mô phỏng chế tạo.
