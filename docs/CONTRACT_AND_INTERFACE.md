# Contract được kiểm và giao diện

Lõi requester vận hành cùng clock với nguồn START/ACK. Peer phải giữ ACK cao cho đến khi quan sát REQ xuống; việc đồng bộ cùng clock tự nó không bảo đảm đúng thứ tự giao thức. Không có đồng bộ CDC, không có payload dữ liệu và chưa xét metastability. Bốn pha là bốn cạnh `REQ↑ → ACK↑ → REQ↓ → ACK↓`; số pha không buộc mọi triển khai phải có đúng bốn trạng thái.

## Chân top `tt_um_24101280_f10`

| Chân | Ý nghĩa |
|---|---|
| `clk` | Clock cạnh lên |
| `rst_n` | Reset **đồng bộ** mức thấp; chỉ có hiệu lực tại cạnh lên |
| `ena` | Cho phép START mới; không đóng băng giao dịch đã nhận |
| `ui_in[7:0]` | Giá trị timeout N, 0…255 |
| `uio_in[0]` | ACK, đúng charter |
| `uio_in[1]` | START, **đề xuất tích hợp** theo phương án 2 của functional_spec nguồn |
| `uio_in[7:2]` | Không dùng |
| `uo_out[0]`, `[1]`, `[2]` | REQ, DONE, TIMEOUT |
| `uo_out[6:3]` | Mã trạng thái 4 bit |
| `uo_out[7]`, `uio_out`, `uio_oe` | 0; chân hai chiều đều ở chế độ input |

## Quy tắc chức năng

- Nhận START khi IDLE và ACK thấp tại cạnh lên. START khi ACK đã cao không được xếp hàng. START trong lúc bận bị bỏ qua.
- N được chốt khi bắt đầu; đổi input N trong lúc bận không đổi deadline hiện tại.
- `IDLE=0`, `REQ_HIGH=1`, `ACK_HIGH=2`, `WAIT_ACK_LOW=3`; REQ cao ở hai trạng thái 1 và 2.
- Khi ACK lên được lấy mẫu ở REQ_HIGH, qua ACK_HIGH một chu kỳ, rồi hạ REQ và chờ ACK thấp.
- ACK_HIGH chuyển tiếp vô điều kiện; core không có bộ phát hiện peer hạ ACK quá sớm. ACK giảm trước REQ giảm vẫn có thể dẫn đến DONE. Stress PASS chỉ nói RTL khớp contract tham chiếu, không chứng minh peer đã giữ đúng bốn pha.
- Mỗi pha chờ có một ngân sách N riêng. Với N>0, timeout tại cạnh kiểm thứ N; N=0 timeout ở cạnh kiểm chờ đầu tiên. N=0 không phải chờ vô hạn hay 256 chu kỳ.
- ACK hợp lệ đúng cạnh deadline thắng timeout. DONE và TIMEOUT là hai xung một chu kỳ, loại trừ nhau. Timeout trở về IDLE; không có ERROR latch.
- Giữ START cao có thể khởi động lại khi về IDLE; không thêm bộ bắt cạnh mà không đổi đặc tả.
- Reset giữa hai cạnh chưa tác động cho đến cạnh lên tiếp theo. Đừng nhầm với reset bất đồng bộ của Lab 0.

Với N=255, hai pha chờ và chu kỳ trung gian cho bound `2N+1 = 511` chu kỳ từ nhận đến kết quả trong kịch bản chậm nhất; watchdog checker dùng 512 chu kỳ bảo thủ. DONE xác nhận ACK **được lấy mẫu thấp tại cạnh tạo DONE**; không khẳng định ACK thô sẽ thấp suốt chu kỳ sau đó.

## Đối chiếu một giao dịch thực

Từ VCD core: REQ lên 45 ns, ACK lên 50 ns, FSM nhận ACK tại 55 ns, REQ xuống 65 ns, ACK xuống 70 ns, DONE lên 75 ns. ACK có thể đổi giữa cạnh lên vì TB lái tại cạnh xuống; trạng thái chỉ cập nhật tại cạnh lên.
