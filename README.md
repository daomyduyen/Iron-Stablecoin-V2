# Iron-Stablecoin-V2

Iron Stablecoin V2 là một stablecoin phi tập trung, sử dụng ETH làm tài sản thế chấp với cơ chế thế chấp vượt mức (overcollateralization) để đảm bảo sự ổn định và tránh các vấn đề như depeg và bank run của Iron Finance.

Stablecoin thế chấp bằng ETH: Không phụ thuộc vào token dễ bị bán tháo.
Cơ chế thế chấp vượt mức (Overcollateralization): Người dùng phải thế chấp 150% giá trị stablecoin.
Thanh lý an toàn: Nếu tài sản thế chấp giảm xuống dưới 120%, hệ thống kích hoạt thanh lý. Người thanh lý nhận 50% tài sản thế chấp, phần còn lại gửi về chủ hợp đồng.
Không sử dụng thuật toán Rebase hoặc Seigniorage, tránh nguy cơ mất giá nhanh.

📜 Hợp đồng thông minh
Địa chỉ hợp đồng: 0x07fe3c7d37b4d2fb0a583d14709956a75c8c02f1

Mạng lưới triển khai: Ethereum Testnet / Mainnet

Ngôn ngữ: Solidity

Frameworks: OpenZeppelin, Hardhat

🛠 Cách chạy dự án
1️⃣ Cài đặt môi trường
Yêu cầu: Node.js, Metamask, VsCode

Chạy lệnh sau để kiểm tra Node.js:

sh
Sao chép
Chỉnh sửa
node -v
Nếu Node.js chưa được cài đặt, tải và cài đặt từ nodejs.org.

2️⃣ Khởi tạo dự án
Mở terminal và chạy:

sh
Sao chép
Chỉnh sửa
git clone https://github.com/yourusername/iron-stablecoin-v2.git
cd iron-stablecoin-v2
npm install
3️⃣ Chạy ứng dụng
sh
Sao chép
Chỉnh sửa
npm run dev
Ứng dụng sẽ chạy tại http://localhost:3000.

🌍 Tích hợp Metamask
Kết nối ví Metamask.

Gửi ETH vào hợp đồng để thế chấp.

Mint Iron Stablecoin V2 (IRONv2).

Theo dõi số dư và quản lý tài sản.

📌 Lệnh quan trọng
✅ Deploy hợp đồng (Hardhat)
sh
Sao chép
Chỉnh sửa
npx hardhat run scripts/deploy.js --network goerli
✅ Chạy thử nghiệm (Test smart contract)
sh
Sao chép
Chỉnh sửa
npx hardhat test
💡 Góp ý & Phát triển
Bạn có thể đóng góp bằng cách:

Fork dự án

Tạo Pull Request

Báo lỗi qua Issues

Mọi đóng góp đều được hoan nghênh! 🚀

📞 Liên hệ
📧 Email: daomyduyen04@gmail.com
🔗 Github: daomyduyen
