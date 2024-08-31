const fs = require('fs');

async function main() {
  const filePath = './contracts/*'; // 你的合约文件路径
  const stats = fs.statSync(filePath);
  const fileSizeInBytes = stats.size;
  const fileSizeInKilobytes = fileSizeInBytes / 1024;
  console.log(`合约文件大小：${fileSizeInBytes} bytes (${fileSizeInKilobytes} KB)`);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
