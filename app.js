const contractAddress = "0xa5ed79b90366ad65ef9caa0df262ccdcd23fd689"; // Địa chỉ hợp đồng của bạn
const contractABI = [ /* ABI của hợp đồng (bạn cần thay vào đây) */ ];

let provider;
let signer;
let contract;

async function connectWallet() {
    if (window.ethereum) {
        provider = new ethers.providers.Web3Provider(window.ethereum);
        await provider.send("eth_requestAccounts", []);
        signer = provider.getSigner();
        contract = new ethers.Contract(contractAddress, contractABI, signer);

        const walletAddress = await signer.getAddress();
        document.getElementById("walletAddress").innerText = walletAddress;
    } else {
        alert("Vui lòng cài đặt MetaMask!");
    }
}

async function depositCollateral() {
    const amount = document.getElementById("depositAmount").value;
    if (!amount) return alert("Nhập số ETH!");

    const tx = await signer.sendTransaction({
        to: contractAddress,
        value: ethers.utils.parseEther(amount)
    });

    await tx.wait();
    alert("Nạp ETH thành công!");
}

async function mintIron() {
    const amount = document.getElementById("mintAmount").value;
    if (!amount) return alert("Nhập số IRON!");

    const tx = await contract.mint(ethers.utils.parseUnits(amount, 18));
    await tx.wait();
    alert("Mint thành công!");
}

async function withdrawCollateral() {
    const amount = document.getElementById("withdrawAmount").value;
    if (!amount) return alert("Nhập số ETH!");

    const tx = await contract.withdrawCollateral(ethers.utils.parseEther(amount));
    await tx.wait();
    alert("Rút ETH thành công!");
}

async function burnIron() {
    const amount = document.getElementById("burnAmount").value;
    if (!amount) return alert("Nhập số IRON!");

    const tx = await contract.burn(ethers.utils.parseUnits(amount, 18));
    await tx.wait();
    alert("Burn thành công!");
}

document.getElementById("connectWallet").addEventListener("click", connectWallet);
