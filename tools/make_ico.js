// Creates a minimal ICO file by embedding the source PNG.
// Windows Vista+ supports PNG-compressed ICO images.
const fs = require('fs');
const path = require('path');

const srcPng = path.resolve(__dirname, '../assets/branding/roola_icon.png');
const dstIco = path.resolve(__dirname, '../windows/runner/resources/app_icon.ico');

const pngData = fs.readFileSync(srcPng);

// Read PNG dimensions from IHDR chunk (bytes 16-24)
const width = pngData.readUInt32BE(16);
const height = pngData.readUInt32BE(20);

console.log(`Source PNG: ${width}x${height}`);

// ICO format: ICONDIR(6) + ICONDIRENTRY(16) + PNG data
const header = Buffer.alloc(6);
header.writeUInt16LE(0, 0);   // reserved
header.writeUInt16LE(1, 2);   // type: 1 = ICO
header.writeUInt16LE(1, 4);   // image count

const entry = Buffer.alloc(16);
entry.writeUInt8(width > 255 ? 0 : width, 0);   // width (0 = 256)
entry.writeUInt8(height > 255 ? 0 : height, 1);  // height (0 = 256)
entry.writeUInt8(0, 2);        // color count (0 = >8bpp)
entry.writeUInt8(0, 3);        // reserved
entry.writeUInt16LE(1, 4);     // planes
entry.writeUInt16LE(32, 6);    // bits per pixel
entry.writeUInt32LE(pngData.length, 8);    // size of image data
entry.writeUInt32LE(6 + 16, 12);           // offset to image data

const ico = Buffer.concat([header, entry, pngData]);
fs.writeFileSync(dstIco, ico);
console.log(`Written: ${dstIco} (${ico.length} bytes)`);
