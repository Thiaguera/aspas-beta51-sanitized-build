const crypto=require('crypto');
const fs=require('fs'),path=require('path'),zlib=require('zlib');
const root=path.resolve(__dirname,'..');
const entries=JSON.parse(fs.readFileSync(path.join(root,'source-parts/manifest.json'),'utf8'));
for(const e of entries){if(!Array.isArray(e.parts)||!e.parts.length||!e.parts.every(p=>/^source-parts\/.+\.chunk\d+$/.test(p)))throw new Error('Manifesto de partes inválido: '+e.path);const b64=e.parts.map(p=>fs.readFileSync(path.join(root,p),'utf8').trim()).join('');const out=zlib.gunzipSync(Buffer.from(b64,'base64'));if(!/^[a-f0-9]{64}$/.test(String(e.sha256||''))||crypto.createHash('sha256').update(out).digest('hex')!==e.sha256)throw new Error('Integridade inválida: '+e.path);const dest=path.join(root,e.path);fs.mkdirSync(path.dirname(dest),{recursive:true});fs.writeFileSync(dest,out);}
require('./restore-assets.cjs');
console.log('Fontes completos restaurados. Leia README.md antes de executar o aplicativo.');
