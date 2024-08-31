const fs = require('fs');
const path = require('path');
const { task } = require("hardhat/config");

task("flattenAll", "Flattens all Solidity files in the contracts folder")
  .setAction(async (taskArgs, hre) => {
    const contractsDir = path.join(__dirname, "../contracts");
    const outputDir = path.join(__dirname, "../flattened");
    const outputFile = path.join(outputDir, "CombinedFlattened.sol");

    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir);
    }

    // 清空输出文件
    fs.writeFileSync(outputFile, "");

    const files = fs.readdirSync(contractsDir).filter(file => file.endsWith('.sol'));

    for (const file of files) {
      const filePath = path.join(contractsDir, file);
      console.log(`Flattening ${filePath}...`);
      const flattened = await hre.run("flatten", { files: [filePath] });
      fs.appendFileSync(outputFile, flattened + '\n\n');
    }

    console.log(`All files have been flattened into ${outputFile}`);
  });

module.exports = {};
